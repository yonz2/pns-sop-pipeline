#!/usr/bin/env bash
#
# translate-local.sh — translate, validate and render ONE procedure on this
# machine, without GitHub Actions and without touching any branch.
#
# Usage:
#   source scripts/llm-env.sh          # once per shell
#   scripts/translate-local.sh sop/LAB-000-document-control.md
#
#   IMAGE=... scripts/translate-local.sh <file.md>      # override the image
#
# This is the local counterpart of .github/scripts/translate-main.sh. It runs
# the same three steps in the same order and enforces the same gate —
#
#     translate  ->  validate  ->  render
#
# — but it writes only to ./out and never publishes. Validation is a GATE, not
# a warning (R1b §4): a rendering that fails the eleven deterministic checks is
# removed rather than left on disk, because a bad English procedure that exists
# will be read as a procedure.
#
# The Indonesian document remains the source of record. Nothing here writes to
# sop/.

set -euo pipefail

IMAGE="${IMAGE:-document-pipeline:latest}"

input="${1:-}"
if [ -z "$input" ]; then
  echo "usage: scripts/translate-local.sh <sop/file.md>" >&2
  exit 2
fi
[ -f "$input" ] || { echo "not a file: $input" >&2; exit 1; }

if [ -z "${LLM_ENDPOINT:-}" ] || [ -z "${LLM_MODEL:-}" ]; then
  echo "LLM_ENDPOINT and LLM_MODEL are not set." >&2
  echo "Run:  source scripts/llm-env.sh" >&2
  exit 2
fi

# Docker needs a path in the HOST's own notation. Git Bash / MSYS rewrites
# arguments that look like absolute unix paths, which turns "$PWD" into
# C:/Program Files/Git/... and /docs into a Windows path — so conversion is done
# explicitly here and MSYS's own rewriting is switched off for the run.
host_path() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'

repo_host="$(host_path "$PWD")"
mkdir -p out
out_host="$(host_path "$PWD/out")"

base="$(basename "$input" .md)"
rel="${input#./}"

# Only variables that are actually SET are passed through. `docker run -e VAR`
# with an empty value sets it to the empty string inside the container, which
# overrides translate.py's own defaults — an empty LLM_TIMEOUT is not 120, it is
# a ValueError. Same rule as translate-main.sh.
env_args=()
for v in LLM_ENDPOINT LLM_MODEL LLM_API_KEY LLM_TIMEOUT \
         PROMPT_VERSION REVIEWED_BY REVIEW_DATE; do
  if [ -n "${!v:-}" ]; then env_args+=(-e "$v"); fi
done

run_pipe() {
  docker run --rm \
    --add-host=host.docker.internal:host-gateway \
    "${env_args[@]}" \
    -v "${repo_host}:/docs:ro" -v "${out_host}:/out" \
    "$IMAGE" "$@"
}

echo "==> translating $rel  (model: $LLM_MODEL)"
run_pipe translate "/docs/$rel" "/out/$base.en.md"

echo "==> validating against the source (the eleven checks of R1b §6)"
if ! run_pipe validate "/docs/$rel" "/out/$base.en.md"; then
  echo
  echo "VALIDATION FAILED — $base is HELD and its output removed." >&2
  echo "The rendering did not correspond to the source; it is not kept." >&2
  rm -f "out/$base.en.md" "out/$base.en.docx" "out/$base.en.pdf"
  exit 1
fi

echo "==> rendering the English document through the institutional form"
run_pipe render "/out/$base.en.md" "/out/$base.en.docx"

echo
echo "done:"
ls -l "out/$base.en.md" "out/$base.en.docx" "out/$base.en.pdf" 2>/dev/null || true
