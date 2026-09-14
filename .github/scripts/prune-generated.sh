#!/usr/bin/env bash
#
# prune-generated.sh — enforce the retention policy for generated content.
#
# Usage: prune-generated.sh <draft-days> <translated-days> [dry-run]
#
# The policy (docs/retention.md) distinguishes three kinds of generated branch,
# because they behave differently:
#
#   draft-*     one branch per draft render. Each is a complete copy of the
#               document set, and a new one is created on every run, so they
#               accumulate. Deleted after <draft-days>.
#
#   translated  the English renderings. Force-pushed, so it is a single
#               snapshot and does not grow — but it can go STALE: if the
#               translation workflow stops running (an endpoint that is no
#               longer configured, for instance), it keeps serving English
#               documents that no longer match the Indonesian sources. A stale
#               rendering is worse than none, because it will be acted on.
#               Deleted after <translated-days> of being behind `main`. It is
#               generated content and can always be rebuilt.
#
#   rendered    the Indonesian documents — the actual deliverable. Force-pushed
#               and always current. NEVER deleted automatically; if it is stale,
#               the pipeline is broken and this script reports it loudly and
#               leaves it alone.
#
# Environment
#   GITHUB_REPOSITORY   owner/repo (set by Actions)
#   GH_TOKEN            token with contents:write (set by Actions)
#   DRY_RUN=true        report only, delete nothing (used by tests)
set -euo pipefail

DRAFT_DAYS="${1:?draft retention in days required}"
TRANSLATED_DAYS="${2:?translated retention in days required}"
REPO="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
DRY_RUN="${DRY_RUN:-false}"

log() { printf '[retention] %s\n' "$*"; }

for v in "$DRAFT_DAYS" "$TRANSLATED_DAYS"; do
  if ! [[ "$v" =~ ^[0-9]+$ ]]; then
    log "retention values must be whole numbers of days, got: $v"
    exit 2
  fi
done

api() { gh api "$@"; }

# committer_date <branch> -> ISO-8601 timestamp of the branch tip
committer_date() {
  api "repos/$REPO/commits/$1" --jq '.commit.committer.date' 2>/dev/null || true
}

# age_days <iso-date> -> whole days since that date (large number on failure)
age_days() {
  local ts now
  ts="$(date -u -d "$1" +%s 2>/dev/null || echo 0)"
  [ "$ts" -gt 0 ] || { echo 999999; return; }
  now="$(date -u +%s)"
  echo $(( (now - ts) / 86400 ))
}

# branch_marker <branch> <file> -> contents of <file> on <branch>, or empty
branch_marker() {
  api "repos/$REPO/contents/$2?ref=$1" --jq '.content' 2>/dev/null \
    | tr -d '\n' | base64 -d 2>/dev/null | tr -d '\r\n' || true
}

delete_branch() {
  local branch="$1" reason="$2"
  if [ "$DRY_RUN" = "true" ]; then
    log "WOULD DELETE $branch — $reason"
  else
    api -X DELETE "repos/$REPO/git/refs/heads/$branch" >/dev/null
    log "DELETED $branch — $reason"
  fi
}

main_sha="$(api "repos/$REPO/branches/main" --jq '.commit.sha')"
log "main is at $main_sha"
log "policy: draft-* older than ${DRAFT_DAYS}d; translated behind main for more than ${TRANSLATED_DAYS}d"

# --- draft-* branches ------------------------------------------------------

log "--- draft branches ---"
refs="$(api "repos/$REPO/git/matching-refs/heads/draft-" --jq '.[].ref' 2>/dev/null || true)"

if [ -z "$refs" ]; then
  log "no draft-* branches"
else
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    branch="${ref#refs/heads/}"
    date_str="$(committer_date "$branch")"
    if [ -z "$date_str" ]; then
      log "SKIP  $branch (cannot read commit date)"
      continue
    fi
    age="$(age_days "$date_str")"
    if [ "$age" -gt "$DRAFT_DAYS" ]; then
      delete_branch "$branch" "draft, last commit ${age}d ago"
    else
      log "keep  $branch (${age}d old)"
    fi
  done <<< "$refs"
fi

# --- translated branch -----------------------------------------------------

log "--- translated branch ---"
if ! api "repos/$REPO/branches/translated" >/dev/null 2>&1; then
  log "no translated branch"
else
  marker="$(branch_marker translated .translated-from)"
  date_str="$(committer_date translated)"
  age="$(age_days "$date_str")"

  if [ -z "$marker" ]; then
    log "translated has no .translated-from marker; treating as stale"
    if [ "$age" -gt "$TRANSLATED_DAYS" ]; then
      delete_branch translated "no marker and ${age}d old"
    else
      log "keep  translated (recent, ${age}d old)"
    fi
  elif [ "$marker" = "$main_sha" ]; then
    log "keep  translated (current: built from main $marker)"
  elif [ "$age" -gt "$TRANSLATED_DAYS" ]; then
    delete_branch translated "behind main for ${age}d (built from ${marker:0:8}, main is ${main_sha:0:8})"
  else
    log "keep  translated (${age}d behind main; under the ${TRANSLATED_DAYS}d threshold)"
  fi
fi

# --- rendered branch -------------------------------------------------------

log "--- rendered branch ---"
if ! api "repos/$REPO/branches/rendered" >/dev/null 2>&1; then
  log "no rendered branch (nothing to check)"
else
  marker="$(branch_marker rendered .rendered-from)"
  if [ "$marker" = "$main_sha" ]; then
    log "rendered is current (built from main $marker)"
  else
    # Never delete: this is the deliverable. A stale rendered branch means the
    # pipeline did not run, which is a failure to fix, not to clean up.
    log "::warning::rendered is NOT current (built from ${marker:0:8}, main is ${main_sha:0:8}) — the render workflow may have failed; not deleting"
  fi
fi

log "retention pass complete"
