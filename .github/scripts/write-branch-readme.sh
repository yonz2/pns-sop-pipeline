#!/usr/bin/env bash
#
# write-branch-readme.sh — write the README that sits on a generated branch
# (`rendered`, `translated`, `draft-*`) and tells a reader how to obtain the
# files correctly.
#
# Usage: write-branch-readme.sh <out-dir> <branch> <heading> <blurb>
#
# Why this exists. A generated branch is browsed in GitHub's web UI, and the URL
# a reader naturally copies from the address bar is
#   https://github.com/<owner>/<repo>/blob/<branch>/<file>.docx
# That URL is the HTML *viewer page*, not the file. Saving it produces an HTML
# document, which Word then refuses to open — the "unreadable content" prompt.
# The README therefore states the two ways that do work, and links each document
# directly at raw.githubusercontent.com.
#
# The links assume the reader is signed in to GitHub when the repository is
# private; that is stated rather than assumed.
set -euo pipefail

OUT_DIR="${1:?out dir required}"
BRANCH="${2:?branch required}"
HEADING="${3:?heading required}"
BLURB="${4:?blurb required}"
REPO="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
COMMIT="${GITHUB_SHA:-unknown}"
GENERATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

docx_files=()
pdf_files=()
shopt -s nullglob
for f in "$OUT_DIR"/*.docx; do docx_files+=("$(basename "$f")"); done
for f in "$OUT_DIR"/*.pdf;  do pdf_files+=("$(basename "$f")");  done
shopt -u nullglob

{
  echo "# $HEADING"
  echo
  echo "$BLURB"
  echo
  echo "**Generated** from source commit \`$COMMIT\` on $GENERATED."
  echo "This branch is rebuilt automatically and its history is not preserved."
  echo
  echo "---"
  echo
  echo "## How to download these files"
  echo
  echo "> **Do not use the URL in the browser's address bar.** A GitHub URL"
  echo "> containing \`/blob/\` is the HTML viewer page, not the document. Saving"
  echo "> that page gives you an \`.htm\` file, and Word reports the document as"
  echo "> unreadable. Use one of the methods below instead."
  echo
  echo "### Method 1 — download a single file (recommended)"
  echo
  echo "Click a link in the tables below. Each opens the real file from"
  echo "\`raw.githubusercontent.com\`. If the repository is private, **sign in to"
  echo "GitHub first**, or GitHub returns \`404 Not Found\`."
  echo
  echo "On GitHub's page for each file there is also a **Download raw file**"
  echo "button (the download icon, top right), which fetches the same bytes."
  echo
  echo "### Method 2 — download everything at once"
  echo
  echo "Open the **Actions** tab, select the most recent successful run of the"
  echo "pipeline, and download the **artifact** (a \`.zip\`). This needs a GitHub"
  echo "account with access to the repository."
  echo
  echo "> Artifacts are deleted automatically after a retention period"
  echo "> (see *Retention* below), so download them soon after a render."
  echo
  echo "### Method 3 — clone the branch (for a complete, scripted copy)"
  echo
  echo '```bash'
  echo "git clone --branch $BRANCH --single-branch \\"
  echo "  https://github.com/$REPO.git"
  echo '```'
  echo
  echo "---"
  echo
  echo "## Documents"
  echo
  echo "### Word (.docx)"
  echo
  echo "| Document | Download |"
  echo "|---|---|"
  for f in "${docx_files[@]}"; do
    printf '| `%s` | [Download](https://raw.githubusercontent.com/%s/%s/%s) |\n' \
      "$f" "$REPO" "$BRANCH" "$f"
  done
  echo
  echo "### PDF"
  echo
  echo "| Document | Download |"
  echo "|---|---|"
  for f in "${pdf_files[@]}"; do
    printf '| `%s` | [Download](https://raw.githubusercontent.com/%s/%s/%s) |\n' \
      "$f" "$REPO" "$BRANCH" "$f"
  done
  echo
  echo "---"
  echo
  echo "## What this branch is, and is not"
  echo
  echo "- **A generated copy.** Every file here is produced by the pipeline from"
  echo "  the Markdown in \`sop/\` on \`main\`. **The Markdown is the source of"
  echo "  record**; this branch is a convenience view of it."
  echo "- **Not authoritative.** It is overwritten on each run, so do not branch"
  echo "  from it, merge it, or cite its commit hashes."
  echo "- **Not for editing.** A correction belongs in the Markdown source, not in"
  echo "  a downloaded Word file; edit the source and the next render carries the"
  echo "  change."
  echo
  echo "## Retention"
  echo
  echo "- **This branch** holds only the current set of documents. It is"
  echo "  force-pushed on every run, so it does not grow without limit."
  echo "- **Workflow artifacts** are removed after their retention period. If a"
  echo "  download link to an artifact returns \`404\`, download the current files"
  echo "  from this branch instead."
  echo "- The full policy is in \`docs/retention.md\` on \`main\`."
} > "$OUT_DIR/README.md"

echo "wrote $OUT_DIR/README.md (${#docx_files[@]} docx, ${#pdf_files[@]} pdf)"
