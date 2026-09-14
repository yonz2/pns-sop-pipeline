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
# chromium:           headless browser required by @mermaid-js/mermaid-cli,
#                     installed below from the xtradeb PPA (see next block)
#
# NOTE: Ubuntu 26.04 has no real Chromium in its own archive. `chromium-browser`
# is a TRANSITIONAL package that installs a snap stub, which cannot run inside a
# container — a build that installed it appeared to succeed and then failed at
# render time with "requires the chromium snap to be installed". Chromium is
# therefore installed from the xtradeb PPA, which ships a native .deb.
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
        ca-certificates \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

# --- chromium (native .deb, from the xtradeb PPA) ----------------------
# The repository is added by hand rather than with `add-apt-repository`. That
# command resolves api.launchpad.net, which is reachable over IPv6 only; on a
# host without IPv6 it hangs and the build never finishes. Fetching the signing
# key directly from the keyserver and writing the sources line avoids the
# dependency, so the same Dockerfile builds on a CI runner and on an IPv4-only
# local VM.
#
# The key is pinned by full fingerprint, not by a short ID, and the PPA is
# restricted to this repository by `signed-by`, so the key cannot authenticate
# any other package source.
RUN set -eux; \
    . /etc/os-release; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL --retry 3 --max-time 120 \
        "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x5301FA4FD93244FBC6F6149982BB6851C64F6880" \
        | gpg --dearmor -o /etc/apt/keyrings/xtradeb.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/xtradeb.gpg] https://ppa.launchpadcontent.net/xtradeb/apps/ubuntu/ ${VERSION_CODENAME} main" \
        > /etc/apt/sources.list.d/xtradeb.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends chromium; \
    rm -rf /var/lib/apt/lists/*

# The Chromium version is printed at build time so a silent substitution to the
# snap stub — or a PPA that stops publishing for this release — is visible in
# the build log rather than only at render time.
RUN chromium --version

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

# puppeteer must NOT download its own browser: the image uses the system
# Chromium installed above. Both variable names are set because the name
# changed across puppeteer versions. Setting this BEFORE the install also
# keeps it from fetching a ~150 MB browser that would never be used.
ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# package-lock.json is copied and `npm ci` is used, not `npm install`. With
# `npm install` and `^` ranges in package.json, the same commit builds with
# whatever version of the docx library is newest on the day it is built — so two
# renders of the same document can differ, and a new upstream release can change
# the output without any change in this repository. `npm ci` installs exactly
# the locked versions and fails if package.json and the lock disagree, which is
# the behaviour a document pipeline wants: reproducible output, and a loud
# failure rather than a silent drift.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# --- python tooling ----------------------------------------------------
# requests: LLM endpoint calls from translate.py. Ubuntu 26.04 enforces PEP 668
# (externally-managed environment), so install into a virtualenv and put it on PATH.
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir requests pyyaml
ENV PATH="/opt/venv/bin:${PATH}"

# --- application -------------------------------------------------------
COPY render.js translate.py validate.py entrypoint.sh glossary.yaml ./
COPY templates/ ./templates/
COPY puppeteer-config.json ./

# Two things mermaid-cli needs, both of which were wrong before and both of
# which only show up at render time:
#
#   1. `mmdc` is installed to node_modules/.bin and is NOT placed on PATH by
#      `npm install`. Without this the renderer dies with "spawnSync mmdc
#      ENOENT" on the first document that contains a mermaid block.
#   2. Puppeteer must be told which browser to launch. It defaults to a bundled
#      download, which is disabled above, so the system Chromium is named here.
#      This previously pointed at /usr/bin/chromium-browser — the snap stub —
#      which is not a browser at all.
ENV PATH="/opt/document-pipeline/node_modules/.bin:${PATH}" \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# The mounted repository. Read-only by convention; output goes to /out.
RUN mkdir -p /docs /out && chmod +x /opt/document-pipeline/entrypoint.sh

# --- runtime -----------------------------------------------------------
# The repository is bind-mounted at /docs, e.g.
#   docker run --rm -v /path/to/repo:/docs:ro -v /path/to/out:/out \
#     document-pipeline render /docs/preparation/D-deliverable-drafts/R1-drafts/IOT-02-raspberry-pi-golden-image.md
ENTRYPOINT ["/opt/document-pipeline/entrypoint.sh"]
