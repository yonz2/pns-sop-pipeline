# document-pipeline

Renders the laboratory SOP corpus as **Documents as Code** (`R1a-documentation-architecture.md`):
Markdown procedures with YAML front matter become the institutional Word and PDF documents, and
the Indonesian source can be rendered into English under strict rules (`R1b-translation-pipeline.md`).

The Word template in `templates/` **is** the *Rekaman Kegiatan Pengelolaan Laboratorium* form —
header band, eleven-row activity record, approval block, section headings. The renderer fills that
template directly (the same `docx` library the template was built with), so the rendered document
carries the form exactly. This is the acceptance test of `R1a` §2: a rendered procedure must be
indistinguishable from the department's own.

## Build

```bash
docker build -t document-pipeline ./document-pipeline
```

## Run

The repository is bind-mounted at `/docs` (read-only by convention); output goes to `/out`.

```bash
# render one procedure to .docx + .pdf
docker run --rm \
  -v "$PWD:/docs:ro" -v "$PWD/out:/out" \
  document-pipeline render /docs/sop/IOT-02-raspberry-pi-golden-image.md

# render every procedure in a directory
docker run --rm \
  -v "$PWD:/docs:ro" -v "$PWD/out:/out" \
  document-pipeline render-all /docs/sop

# generate the English rendering (R1b) — needs an LLM endpoint
docker run --rm \
  -e LLM_ENDPOINT=http://host.docker.internal:11434/v1 \
  -e LLM_MODEL=llama3 \
  -v "$PWD:/docs:ro" -v "$PWD/out:/out" \
  document-pipeline translate /docs/sop/IOT-02-raspberry-pi-golden-image.md

# run the 11 deterministic validation checks (R1b section 6)
docker run --rm \
  -v "$PWD:/docs:ro" \
  document-pipeline validate /docs/source.md /docs/translated.md
```

## Commands

| Command | What it does |
|---|---|
| `render <file.md> [<out.docx>]` | Fill the template with the procedure's front matter and body; write `.docx` and `.pdf` |
| `render-all [<dir>]` | Render every `*.md` (except `README.md`) in a directory |
| `translate <file.md> [<out.md>]` | Generate the English rendering via the configured LLM endpoint |
| `validate <source.md> <translated.md>` | Run the 11 deterministic checks of `R1b` §6 |

## Configuration

| Variable | Used by | Meaning |
|---|---|---|
| `LLM_ENDPOINT` | translate | Base URL of an OpenAI-compatible chat-completions endpoint |
| `LLM_MODEL` | translate | Model name |
| `LLM_API_KEY` | translate | API key (optional for a local runner) |
| `LLM_TIMEOUT` | translate | Seconds (default 120) |
| `PROMPT_VERSION` | translate | Version recorded in the output front matter (default 1.0) |
| `REVIEWED_BY`, `REVIEW_DATE` | translate | Sign-off recorded in the output front matter |
| `DOCS_DIR`, `OUT_DIR` | entrypoint | Defaults `/docs` and `/out` |

The translation endpoint is a **configuration value, not a redesign** (`R3` §8.1): a local model
runner on campus or a cloud service, chosen per task and reversible. Validation never involves a
model — a model must never decide whether its own output is safe (`R1b` §4).

## Layout

| Path | What it is |
|---|---|
| `Dockerfile` | `ubuntu:26.04`; Node + `docx` + mermaid-cli, LibreOffice headless, Python 3 |
| `render.js` | Template-fill renderer (`.docx`), then LibreOffice for `.pdf` |
| `translate.py` | R1b §5 prompt + provenance front matter (R1b §8) |
| `validate.py` | The 11 deterministic checks of R1b §6 |
| `entrypoint.sh` | The CLI |
| `glossary.yaml` | The closed vocabulary (R1b §3.1); protected tokens for checks 4 & 5 |
| `templates/` | The `.dotx` form, its build script, and the crest |

## The glossary — `glossary.yaml`

`glossary.yaml` is the **closed vocabulary** of the SOP corpus, as `R1b` §3.1 defines it: the fixed
set of section headings, form-field names, the approval block, status values, positions and units
that are rendered bilingually in the template and therefore **never reach a translator**. It is the
single source of truth for how the pipeline treats these terms.

### What it holds

- **`terms`** — each entry has an `id` (the Indonesian, as it appears in the corpus), an `en`
  rendering, a `group`, and a `status` (`confirmed` / `provisional` / `needs_pns`). A `needs_pns`
  entry is a term of art in the PLP credit system that the department must supply — the value shown
  is a placeholder to make the blank visible, never an adviser's invention.
- **`protected_patterns`** — regexes for identifiers with no bilingual pair (activity codes like
  `II.A.12.b`, document IDs like `LAB-000` / `IOT-02`, NIP numbers).
- **`protected_literals`** — proper names of the institution and its units (`Politeknik Negeri
  Semarang`, `UPT TIK`, …).
- **`open_questions`** — the decisions the department still has to make (which approval chain, the
  `II.A.12.a` vs `II.A.12.b` code, the English rendering of the PLP terms of art).

### How the pipeline uses it

| Step | Use |
|---|---|
| **`render.js`** | Emits section headings and form-field labels from the glossary's `id`/`en` pairs, so the fixed vocabulary is bilingual in the document itself and never depends on a translator. |
| **`translate.py`** | Injects the glossary and protected tokens into the R1b §5 prompt, so the model copies them verbatim and uses the agreed English renderings. |
| **`validate.py`** | Check 4 (every protected token present, unchanged) and check 5 (no protected term rendered in English where the source had the Indonesian) are driven directly from `glossary.yaml`. |

Because the glossary is the authority, **editing it is a change to the document set**: a term added
or re-rendered here changes every document the pipeline produces. It is baked into the image but can
be overridden by bind-mounting a revised copy over `/opt/document-pipeline/glossary.yaml`.

## Notes

- **Management procedures (Tier 1)** use a different section structure (`Pemilik dokumen`, `Tinjauan`,
  `Rekaman`, `Pengesahan`) than the operating template (`Prinsip Kerja`, `Cara Pengoperasian`). The
  renderer maps sections generically; a dedicated management template is a documented follow-up
  (`templates/README.md` §4).
- The template and glossary are baked into the image but can be overridden by bind-mounting a
  revised copy over `/opt/document-pipeline/templates` or `/opt/document-pipeline/glossary.yaml`.
- The `.dotx` is a generated artefact; edit `templates/build-sop-template.js` and rebuild it
  (`templates/README.md` §6).
