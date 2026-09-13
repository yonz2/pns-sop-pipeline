# =====================================================================
# document-pipeline — renders the laboratory SOP corpus
# =====================================================================
#
# Implements the workflow in preparation/D-deliverable-drafts/
#   R1a-documentation-architecture.md  (Documents as Code)
#   R1b-translation-pipeline.md         (Indonesian source, English rendering)
#   R1-SOP-wireframe.md                 (framework and register)
#
# The .dotx template in templates/ IS the Rekaman Kegiatan Pengelolaan
# Laboratorium form. The renderer fills that template directly (Node docx
# library, the same library the template was built with) rather than
# Pandoc-converting, because Pandoc's --reference-doc carries only styles,
# not the form content — the header band, activity record and approval
# block would be dropped, failing the acceptance test of R1a section 2.
#
# PDF is produced by LibreOffice headless, which renders the Word form
# faithfully (header band, page-number fields, tables).
#
# The translation step (R1b) calls a language-model endpoint that is a
# configuration value (R3 section 8.1): a local model runner on campus or
# a cloud service, chosen per task and reversible. Validation (R1b section
# 6) is deterministic — arithmetic and string comparison, no model involved.

FROM ubuntu:26.04

# --- non-interactive, no recommends -----------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# --- system packages ---------------------------------------------------
# libreoffice-writer: .docx -> .pdf (renders the Word form faithfully)
# fonts-liberation:   Arial substitute. The template sets Arial throughout, per
#                     Tata Naskah Dinas. --no-install-recommends drops the font
#                     packages LibreOffice would otherwise pull in, and with no
#                     Arial and no substitute it falls back to DejaVu Serif -
#                     the .docx is correct and the .pdf comes out in a serif
#                     face. Liberation Sans is METRIC-COMPATIBLE with Arial, so
#                     line breaks and the page count match what the department
#                     sees in Word. That matters beyond appearance: 'Halaman n
#                     dari m' is a computed field and has to agree.
# fontconfig:         provides fc-match, used by the font guard below
# nodejs npm:         the renderer (docx library) and mermaid-cli
# python3 pip:        translate.py and validate.py
# git:                read the mounted repository
# curl:               LLM endpoint calls
# chromium:           headless browser required by @mermaid-js/mermaid-cli
RUN apt-get update && apt-get install -y --no-install-recommends \
        libreoffice-writer \
        fonts-liberation \
        fontconfig \
        nodejs \
        npm \
        python3 \
        python3-pip \
        python3-yaml \
        python3-venv \
        git \
        curl \
        chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# --- font guard --------------------------------------------------------
# A missing font does not fail a conversion; LibreOffice substitutes silently
# and the defect only shows up in the rendered PDF. Fail the BUILD instead.
RUN fc-match Arial | grep -q 'LiberationSans' \
    && fc-match 'Arial:bold' | grep -q 'LiberationSans-Bold' \
    || (echo 'FATAL: Arial does not resolve to Liberation Sans' >&2; exit 1)

# --- node tooling ------------------------------------------------------
# docx: the library the template was built with (templates/build-sop-template.js)
# @mermaid-js/mermaid-cli: renders ```mermaid blocks to images
WORKDIR /opt/document-pipeline
COPY package.json ./
RUN npm install --omit=dev

# --- python tooling ----------------------------------------------------
# requests: LLM endpoint calls from translate.py. Ubuntu 26.04 enforces PEP 668
# (externally-managed environment), so install into a virtualenv and put it on PATH.
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir requests pyyaml
ENV PATH="/opt/venv/bin:${PATH}"

# --- application -------------------------------------------------------
COPY render.js translate.py validate.py entrypoint.sh glossary.yaml ./
COPY templates/ ./templates/

# mermaid-cli needs to know where Chromium lives
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# The mounted repository. Read-only by convention; output goes to /out.
RUN mkdir -p /docs /out && chmod +x /opt/document-pipeline/entrypoint.sh

# --- runtime -----------------------------------------------------------
# The repository is bind-mounted at /docs, e.g.
#   docker run --rm -v /path/to/repo:/docs:ro -v /path/to/out:/out \
#     document-pipeline render /docs/preparation/D-deliverable-drafts/R1-drafts/IOT-02-raspberry-pi-golden-image.md
ENTRYPOINT ["/opt/document-pipeline/entrypoint.sh"]
