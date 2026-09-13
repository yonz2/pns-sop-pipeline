# pns-sop-pipeline

Laboratory standard operating procedures for Politeknik Negeri Semarang, managed as
**Documents as Code**: the Markdown files in `sop/` are the source, Git is the document
management system, and `document-pipeline/` renders them into the institutional Word
and PDF documents.

The rendered documents carry the department's own *Rekaman Kegiatan Pengelolaan
Laboratorium* form — header band, activity record and approval block — so a procedure
produced here is the document the PLP already recognise, and the one that earns
*angka kredit*.

## Layout

| Path | What it is |
|---|---|
| `sop/` | **The documents.** One Markdown file per procedure, with YAML front matter carrying its metadata (number, revision, owner, review interval). This is the source of record |
| `document-pipeline/` | The renderer: Markdown + front matter → `.docx` (the department's form) → `.pdf`. Also the deterministic translation and validation tooling |
| `out/` | Rendered output. Generated, never committed |

`sop/` holds the Indonesian procedures. **Indonesian is the source of record**; an
English rendering is generated from it, never authored, under the rules in
`document-pipeline/README.md`.

## Prerequisites

- **Docker** — the only requirement to render. Node, LibreOffice, Mermaid and the
  Arial-metric fonts are all inside the image, so Windows, Linux and macOS all produce
  the same PDF.

## Build the renderer

Run once, from the repository root:

```bash
docker build -t document-pipeline ./document-pipeline
```

## Render

The repository is mounted at `/docs` (read-only); output goes to `/out`, which maps to
`./out` on the host.

```bash
# every procedure in sop/ -> out/<name>.docx and out/<name>.pdf
docker run --rm \
  -v "$PWD:/docs:ro" -v "$PWD/out:/out" \
  document-pipeline render-all /docs/sop

# a single procedure
docker run --rm \
  -v "$PWD:/docs:ro" -v "$PWD/out:/out" \
  document-pipeline render /docs/sop/LAB-000-document-control.md
```

A rendered `.docx` opens in Word as the department's form; the `.pdf` is produced from
it by LibreOffice headless.

## Working on the documents

Git is the document management system:

1. Edit a procedure in `sop/` — correct a statement, fill a `[[PNS: ...]]` blank, or add
   a new file.
2. The file's front matter is the document's metadata. Changing `revisi` and
   `tanggal_terbit` there changes the revision printed on the rendered form.
3. Render with `render-all`, then review the `.docx` or `.pdf` in `out/`.

**The documents are the department's own.** The `sop/` files are working drafts to be
corrected and rewritten by the department; the notes in each file and in `sop/README.md`
record what is still an assumption and what has been confirmed.

## Editing in a dev container

`.devcontainer/` builds the renderer image and opens the repository inside it, so the
same tools are available locally as in CI. In VS Code: **Reopen in Container**, then
render in the integrated terminal.

```bash
./document-pipeline/entrypoint.sh render-all ./sop   # -> ./out/*.docx, ./out/*.pdf
```

## The workflow

`docs/git-workflow.md` is the full account: topic branches, review by code owners on
pull requests, integration into `main`, and the renderer running on merge. Two workflows
implement it:

- `.github/workflows/render.yml` — renders `sop/` whenever a change reaches `main`, and
  publishes the result to the `rendered` branch.
- `.github/workflows/render-draft.yml` — renders an unapproved branch on demand, for
  circulating a draft before it is approved.

## The full command set

`document-pipeline/README.md` documents every command — `render`, `render-all`,
`translate` and `validate` (the eleven deterministic checks that guard the English
rendering) — and the `glossary.yaml` that holds the closed bilingual vocabulary.
