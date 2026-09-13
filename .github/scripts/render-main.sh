#!/usr/bin/env bash
#
# render-main.sh — render the SOP corpus on a push to `main`, touching only what
# changed.
#
# Usage:  render-main.sh <before-sha> <after-sha> <image> [force-full]
#
# How it stays correct, and why it is not merely an optimisation
#   The `rendered` branch must always hold the *complete* current set of
#   documents. So the changed procedures are re-rendered and then overlaid on the
#   previous output, rather than the branch being regenerated from nothing.
#
#   The diff base is the commit recorded in `.rendered-from` on the `rendered`
#   branch — the commit that last produced the branch — not the push's `before`
#   sha. That makes the render idempotent and self-catching-up: if a previous run
#   was cancelled or failed, the next run diffs from the last successful render
#   and picks up everything it missed. Where the marker is absent or unusable,
#   the provided <before-sha> is used; where that too is unusable, a full render
#   is done.
#
#   A completeness check then compares the rendered set against the sources and
#   falls back to a full render on any mismatch. Self-healing, not optimisation.
#
# The `rendered` branch is generated and force-pushed: its history is not
# preserved by design, and the Markdown on `main` remains the source of record.
#
# Environment
#   GITHUB_TOKEN, GITHUB_REPOSITORY   used to build the push URL
#   REMOTE_URL                        overrides the push URL (used by tests)
#   DRY_RUN=true                      skip Docker; create placeholder outputs
#                                     instead (used by tests)

set -euo pipefail

BEFORE="${1:-}"
AFTER="${2:?after sha required}"
IMAGE="${3:-pns-sop-pipeline:ci}"
FORCE_FULL="${4:-false}"
DRY_RUN="${DRY_RUN:-false}"

REMOTE_URL="${REMOTE_URL:-https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git}"

log() { printf '[render-main] %s\n' "$*"; }

# The documents renderable from sop/: every *.md except the README.
expected_basenames() {
  local f
  for f in sop/*.md; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "README.md" ] && continue
    basename "$f" .md
  done
}

render_all() {
  rm -rf out
  mkdir -p out
  if [ "$DRY_RUN" = "true" ]; then
    log "DRY-RUN: rendering every procedure"
    local b
    while read -r b; do touch "out/$b.docx" "out/$b.pdf"; done < <(expected_basenames)
    return
  fi
  log "rendering every procedure under sop/"
  docker run --rm -v "$PWD:/docs:ro" -v "$PWD/out:/out" "$IMAGE" render-all /docs/sop
}

render_one() {
  if [ "$DRY_RUN" = "true" ]; then
    log "DRY-RUN: rendering sop/$1.md"
    touch "out/$1.docx" "out/$1.pdf"
    return
  fi
  log "rendering sop/$1.md"
  docker run --rm -v "$PWD:/docs:ro" -v "$PWD/out:/out" "$IMAGE" render "/docs/sop/$1.md"
}

# --- fetch the previous output, and the commit it was built from -----------

mode="incremental"
[ "$FORCE_FULL" = "true" ] && mode="full"

base="$BEFORE"
have_rendered=false

if git ls-remote --exit-code --heads "$REMOTE_URL" rendered >/dev/null 2>&1; then
  log "fetching the existing 'rendered' branch"
  rm -rf out
  git clone -q --depth 1 --branch rendered "$REMOTE_URL" out
  rm -rf out/.git
  have_rendered=true

  marker="$(cat out/.rendered-from 2>/dev/null || true)"
  if [ -n "$marker" ] && git cat-file -e "${marker}^{commit}" 2>/dev/null \
     && git merge-base --is-ancestor "$marker" "$AFTER"; then
    log "diff base is the last rendered commit: $marker"
    base="$marker"
  else
    log "'.rendered-from' is absent or not an ancestor of $AFTER"
  fi
else
  log "no 'rendered' branch yet"
fi

# Fall back to a full render if there is no usable base.
if [ "$mode" = "incremental" ]; then
  if ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
    log "no usable diff base — full render"
    mode="full"
  fi
fi

# --- compute the change set ------------------------------------------------

to_render=()
to_remove=()

if [ "$mode" = "incremental" ]; then
  pipeline_changed=false
  while IFS=$'\t' read -r status path; do
    [ -n "${status:-}" ] || continue
    case "$status" in
      D)
        case "$path" in
          document-pipeline/*) pipeline_changed=true ;;
          sop/*.md)
            [ "$path" = "sop/README.md" ] && continue
            to_remove+=("$(basename "$path" .md)") ;;
        esac ;;
      A|M|C|T|R*)
        case "$path" in
          document-pipeline/*) pipeline_changed=true ;;
          sop/*.md)
            [ "$path" = "sop/README.md" ] && continue
            to_render+=("$(basename "$path" .md)") ;;
        esac ;;
    esac
  done < <(git diff --no-renames --name-status "$base" "$AFTER")

  if [ "$pipeline_changed" = "true" ]; then
    log "document-pipeline/ changed — full render"
    mode="full"
  fi
fi

if [ "$mode" = "full" ] || [ "$have_rendered" != "true" ]; then
  render_all
else
  for b in "${to_remove[@]:-}"; do
    [ -n "$b" ] || continue
    log "removing output for deleted sop/$b.md"
    rm -f "out/$b.docx" "out/$b.pdf"
  done
  if [ "${#to_render[@]}" -gt 0 ]; then
    for b in "${to_render[@]}"; do render_one "$b"; done
  else
    log "no procedure changed"
  fi

  # --- completeness check (self-healing) -----------------------------------
  complete=true
  while read -r b; do
    [ -f "out/$b.docx" ] || { complete=false; log "missing out/$b.docx"; }
    [ -f "out/$b.pdf" ]  || { complete=false; log "missing out/$b.pdf"; }
  done < <(expected_basenames)

  for f in out/*.docx; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .docx)"
    if ! expected_basenames | grep -qx "$b"; then
      complete=false
      log "out/$b.docx has no source"
    fi
  done

  if [ "$complete" != "true" ]; then
    log "rendered set does not match sources — full render"
    render_all
  fi
fi

# --- publish ---------------------------------------------------------------

printf '%s\n' "$AFTER" > out/.rendered-from

cd out
git init -q
git config user.name  "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add -A
if git diff --cached --quiet; then
  log "no change to publish"
  exit 0
fi
git commit -qm "Render from ${AFTER}"
git branch -M rendered
git remote add origin "$REMOTE_URL"
git push -f origin rendered
log "published to the 'rendered' branch"
