#!/usr/bin/env bash
#
# translate-main.sh — generate the English renderings of the SOP corpus.
#
# Usage:  translate-main.sh <before-sha> <after-sha> <image> [force-full]
#
# This is the pipeline of R1b-translation-pipeline.md, wired into the Git
# workflow. Indonesian is the source of record; the English rendering is
# generated from it by a language model, checked deterministically, rendered
# through the same form as the Indonesian, and published to a derived branch.
#
# It mirrors render-main.sh: only what changed is translated, the result is
# overlaid on the previous output so the `translated` branch stays a complete
# set, and the diff base is the commit recorded in `.translated-from` on that
# branch — so a cancelled or failed run is caught up by the next one.
#
# What is different, and matters more:
#
#   * VALIDATION IS A GATE (R1b section 4). Every generated document is put
#     through validate.py's eleven deterministic checks. A document that fails
#     is HELD: it is not published, any previous English rendering of it is
#     removed (it no longer corresponds to the source), it is listed in
#     HELD.md, and the job fails. A failure is never published as a warning.
#
#   * A HELD DOCUMENT DOES NOT SELF-HEAL INTO A FULL RUN. The completeness
#     check treats held documents as legitimately absent, because re-running
#     would meet the same failure.
#
#   * THE MODEL IS A CONFIGURATION VALUE (R3 section 8.1). The endpoint,
#     model and key are read from the environment and passed straight through
#     to the container. Nothing here assumes a vendor.
#
# Environment (passed through to the container)
#   LLM_ENDPOINT, LLM_MODEL, LLM_API_KEY, LLM_TIMEOUT,
#   PROMPT_VERSION, REVIEWED_BY, REVIEW_DATE
# Environment (used here)
#   GITHUB_TOKEN, GITHUB_REPOSITORY   used to build the push URL
#   REMOTE_URL                        overrides the push URL (used by tests)
#   DRY_RUN=true                      skip Docker; simulate the model and the
#                                     renderer (used by tests)

set -euo pipefail

BEFORE="${1:-}"
AFTER="${2:?after sha required}"
IMAGE="${3:-pns-sop-pipeline:ci}"
FORCE_FULL="${4:-false}"
DRY_RUN="${DRY_RUN:-false}"

REMOTE_URL="${REMOTE_URL:-https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git}"

log() { printf '[translate-main] %s\n' "$*"; }

# Every document renderable from sop/: *.md except the README.
declare -A EXPECTED=()
collect_expected() {
  EXPECTED=()
  local f b
  for f in sop/*.md; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .md)"
    [ "$b" = "README" ] && continue
    EXPECTED["$b"]=1
  done
}

# Held documents, accumulated as translation or validation fails.
declare -A HELD=()
held_reasons=()

# A single container invocation. The repository is read-only at /docs; all
# generated files go to /out, which is the repository's own ./out directory.
#
# Only variables that are actually set are passed through. `docker run -e VAR`
# with an empty value sets the variable to the empty string, which would
# override translate.py's own defaults (an empty LLM_TIMEOUT is not 120; it is
# a ValueError). An unset variable is left unset instead.
run_pipe() {
  local env_args=()
  local v
  for v in LLM_ENDPOINT LLM_MODEL LLM_API_KEY LLM_TIMEOUT \
           PROMPT_VERSION REVIEWED_BY REVIEW_DATE; do
    if [ -n "${!v:-}" ]; then env_args+=(-e "$v"); fi
  done

  docker run --rm \
    --add-host=host.docker.internal:host-gateway \
    "${env_args[@]}" \
    -v "$PWD:/docs:ro" -v "$PWD/out:/out" \
    "$IMAGE" "$@"
}

# Translate one procedure to out/<base>.en.md, then validate it against the
# source. Returns non-zero and marks the document held on any failure.
translate_and_validate() {
  local base="$1"

  if [ "$DRY_RUN" = "true" ]; then
    # Simulate the model. A source whose name contains HOLD simulates a
    # validation failure, so the hold path can be exercised in tests.
    log "DRY-RUN: translating sop/$base.md"
    printf -- '---\nlang: en\nrole: translation\n---\n\n# %s (EN)\n' "$base" > "out/$base.en.md"
    if printf '%s' "$base" | grep -qi 'hold'; then
      log "DRY-RUN: simulating validation failure for $base"
      return 1
    fi
    return 0
  fi

  log "translating sop/$base.md"
  if ! run_pipe translate "/docs/sop/$base.md" "/out/$base.en.md"; then
    log "translation failed for $base"
    return 1
  fi

  log "validating $base against the source (R1b section 6)"
  if ! run_pipe validate "/docs/sop/$base.md" "/out/$base.en.md"; then
    log "validation FAILED for $base — document held"
    return 1
  fi
  return 0
}

# Render an English Markdown rendering to the institutional form.
render_en() {
  local base="$1"
  if [ "$DRY_RUN" = "true" ]; then
    touch "out/$base.en.docx" "out/$base.en.pdf"
    return 0
  fi
  log "rendering out/$base.en.md"
  run_pipe render "/out/$base.en.md" "/out/$base.en.docx"
}

hold() {
  local base="$1" reason="$2"
  HELD["$base"]=1
  held_reasons+=("$base — $reason")
  rm -f "out/$base.en.md" "out/$base.en.docx" "out/$base.en.pdf"
}

collect_expected

# --- fetch the previous output, and the commit it was built from -----------

mode="incremental"
[ "$FORCE_FULL" = "true" ] && mode="full"

base="$BEFORE"
have_translated=false

if git ls-remote --exit-code --heads "$REMOTE_URL" translated >/dev/null 2>&1; then
  log "fetching the existing 'translated' branch"
  rm -rf out
  git clone -q --depth 1 --branch translated "$REMOTE_URL" out
  rm -rf out/.git
  have_translated=true

  marker="$(cat out/.translated-from 2>/dev/null || true)"
  if [ -n "$marker" ] && git cat-file -e "${marker}^{commit}" 2>/dev/null \
     && git merge-base --is-ancestor "$marker" "$AFTER"; then
    log "diff base is the last translated commit: $marker"
    base="$marker"
  else
    log "'.translated-from' is absent or not an ancestor of $AFTER"
  fi
else
  log "no 'translated' branch yet"
fi

if [ "$mode" = "incremental" ]; then
  if ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
    log "no usable diff base — full run"
    mode="full"
  fi
fi

# --- compute the change set ------------------------------------------------

to_process=()
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
            to_process+=("$(basename "$path" .md)") ;;
        esac ;;
    esac
  done < <(git diff --no-renames --name-status "$base" "$AFTER")

  if [ "$pipeline_changed" = "true" ]; then
    log "document-pipeline/ changed — full run"
    mode="full"
  fi
fi

# --- translate and validate ------------------------------------------------

if [ "$mode" = "full" ] || [ "$have_translated" != "true" ]; then
  rm -rf out
  mkdir -p out
  log "processing every procedure under sop/"
  for b in "${!EXPECTED[@]}"; do
    if translate_and_validate "$b"; then render_en "$b"; else hold "$b" "translation or validation failed"; fi
  done
else
  for b in "${to_remove[@]:-}"; do
    [ -n "$b" ] || continue
    log "removing English output for deleted sop/$b.md"
    rm -f "out/$b.en.md" "out/$b.en.docx" "out/$b.en.pdf"
  done
  if [ "${#to_process[@]}" -gt 0 ]; then
    for b in "${to_process[@]}"; do
      if translate_and_validate "$b"; then render_en "$b"; else hold "$b" "translation or validation failed"; fi
    done
  else
    log "no procedure changed"
  fi

  # --- completeness check (self-healing), held documents excepted ----------
  complete=true
  for b in "${!EXPECTED[@]}"; do
    [ -n "${HELD[$b]:-}" ] && continue
    [ -f "out/$b.en.docx" ] || { complete=false; log "missing out/$b.en.docx"; }
    [ -f "out/$b.en.pdf" ]  || { complete=false; log "missing out/$b.en.pdf"; }
  done
  for f in out/*.en.docx; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .en.docx)"
    if [ -z "${EXPECTED[$b]:-}" ]; then
      complete=false
      log "out/$b.en.docx has no source"
    fi
  done

  if [ "$complete" != "true" ]; then
    log "translated set does not match sources — full run"
    rm -rf out
    mkdir -p out
    for b in "${!EXPECTED[@]}"; do
      if translate_and_validate "$b"; then render_en "$b"; else hold "$b" "translation or validation failed"; fi
    done
  fi
fi

# --- publish ---------------------------------------------------------------

# A dry run exercises the orchestration without a model, so its output is
# placeholder text. It must never reach the `translated` branch: a branch that
# looks like a set of generated English documents would be read as one. The
# artifact is enough for a dry run; publishing is for real renderings only.
#
# TRANSLATE_TEST_PUBLISH exists for the local test harness alone, which drives
# this script against a throwaway bare repository to verify the branch mechanics
# (overlay, marker, self-heal). It is never set in CI. If it is set, REMOTE_URL
# must not be the real repository.
if [ "$DRY_RUN" = "true" ] && [ "${TRANSLATE_TEST_PUBLISH:-false}" != "true" ]; then
  log "DRY-RUN: not publishing to the 'translated' branch (output is simulated)"
  log "dry run complete: ${#EXPECTED[@]} document(s), ${#HELD[@]} held"
  exit 0
fi

printf '%s\n' "$AFTER" > out/.translated-from

# A README that tells a reader how to download the files correctly. A GitHub
# `/blob/` URL is the HTML viewer page, not the document.
bash "$(dirname "$0")/write-branch-readme.sh" \
  out translated \
  "English renderings of the SOP documents" \
  "The English Word and PDF renderings, generated from the Indonesian Markdown sources in \`sop/\` on \`main\` and validated deterministically. **The Indonesian document is the source of record**; where the two differ, the Indonesian one is in force."

if [ "${#HELD[@]}" -gt 0 ]; then
  {
    echo "# Held documents"
    echo
    echo "The following documents were **not** published. A generated document"
    echo "that fails validation is held rather than published with a warning"
    echo "(R1b section 4). They are absent from this branch until they pass."
    echo
    for r in "${held_reasons[@]}"; do echo "- \`$r\`"; done
  } > out/HELD.md
else
  rm -f out/HELD.md
fi

cd out
git init -q
git config user.name  "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add -A
if git diff --cached --quiet; then
  log "no change to publish"
else
  git commit -qm "Translation from ${AFTER}"
  git branch -M translated
  git remote add origin "$REMOTE_URL"
  git push -f origin translated
  log "published to the 'translated' branch"
fi

if [ "${#HELD[@]}" -gt 0 ]; then
  log "${#HELD[@]} document(s) held — see HELD.md"
  exit 1
fi

log "all documents translated and validated"
