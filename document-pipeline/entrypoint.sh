#!/usr/bin/env bash
# entrypoint.sh — CLI for the document pipeline.
#
# Commands:
#   render <file.md> [<out.docx>]   render one procedure to .docx + .pdf
#   render-all [<dir>]              render every *.md in a directory (default /docs)
#   translate <file.md> [<out.md>]  generate the English rendering (R1b)
#   validate <source.md> <out.md>   run the 11 deterministic checks (R1b section 6)
#
# The repository is bind-mounted at /docs (read-only by convention); output goes
# to /out unless an explicit path is given.

set -euo pipefail

PIPE_DIR="${PIPE_DIR:-/opt/document-pipeline}"
DOCS_DIR="${DOCS_DIR:-/docs}"
OUT_DIR="${OUT_DIR:-/out}"

usage() {
  echo "usage:"
  echo "  render <file.md> [<out.docx>]"
  echo "  render-all [<dir>]"
  echo "  translate <file.md> [<out.md>]"
  echo "  validate <source.md> <translated.md>"
  exit 2
}

cmd="${1:-}"
shift || true

case "$cmd" in
  render)
    [ $# -ge 1 ] || usage
    input="$1"
    if [ $# -ge 2 ]; then
      out="$2"
    else
      base="$(basename "$input" .md)"
      out="$OUT_DIR/$base.docx"
    fi
    mkdir -p "$(dirname "$out")"
    node "$PIPE_DIR/render.js" "$input" "$out"
    ;;
  render-all)
    dir="${1:-$DOCS_DIR}"
    [ -d "$dir" ] || { echo "not a directory: $dir" >&2; exit 1; }
    count=0
    mkdir -p "$OUT_DIR"
    while IFS= read -r f; do
      base="$(basename "$f" .md)"
      out="$OUT_DIR/$base.docx"
      echo "==> $f"
      node "$PIPE_DIR/render.js" "$f" "$out"
      count=$((count + 1))
    done < <(find "$dir" -name '*.md' -not -name 'README.md' | sort)
    echo "rendered $count document(s) to $OUT_DIR"
    ;;
  translate)
    [ $# -ge 1 ] || usage
    input="$1"
    if [ $# -ge 2 ]; then
      out="$2"
    else
      base="$(basename "$input" .md)"
      out="$OUT_DIR/${base}.en.md"
    fi
    mkdir -p "$(dirname "$out")"
    python3 "$PIPE_DIR/translate.py" "$input" "$out"
    ;;
  validate)
    [ $# -ge 2 ] || usage
    python3 "$PIPE_DIR/validate.py" "$1" "$2"
    ;;
  *)
    usage
    ;;
esac
