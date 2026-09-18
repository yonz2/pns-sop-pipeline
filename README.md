# Rendered SOP documents

The Word and PDF forms of the laboratory procedures, rendered from the Markdown sources in `sop/` on `main`.

**Generated** from source commit `14d1c24b84c31448952fbfe083a1970768d3495a` on 2026-09-18T08:10:36Z.
This branch is rebuilt automatically and its history is not preserved.

---

## How to download these files

> **Do not use the URL in the browser's address bar.** A GitHub URL
> containing `/blob/` is the HTML viewer page, not the document. Saving
> that page gives you an `.htm` file, and Word reports the document as
> unreadable. Use one of the methods below instead.

### Method 1 — download a single file (recommended)

Click a link in the tables below. Each opens the real file from
`raw.githubusercontent.com`. If the repository is private, **sign in to
GitHub first**, or GitHub returns `404 Not Found`.

On GitHub's page for each file there is also a **Download raw file**
button (the download icon, top right), which fetches the same bytes.

### Method 2 — download everything at once

Open the **Actions** tab, select the most recent successful run of the
pipeline, and download the **artifact** (a `.zip`). This needs a GitHub
account with access to the repository.

> Artifacts are deleted automatically after a retention period
> (see *Retention* below), so download them soon after a render.

### Method 3 — clone the branch (for a complete, scripted copy)

```bash
git clone --branch rendered --single-branch \
  https://github.com/yonz2/pns-sop-pipeline.git
```

---

## Documents

### Word (.docx)

| Document | Download |
|---|---|
| `IOT-02-raspberry-pi-golden-image.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/IOT-02-raspberry-pi-golden-image.docx) |
| `LAB-000-document-control.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-000-document-control.docx) |
| `LAB-ACC-access-authorisation.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-ACC-access-authorisation.docx) |
| `LAB-CMP-competence-induction.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-CMP-competence-induction.docx) |
| `LAB-EQP-equipment-lifecycle.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-EQP-equipment-lifecycle.docx) |
| `LAB-INC-incident-change.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-INC-incident-change.docx) |
| `LAB-MNT-maintenance-calibration.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-MNT-maintenance-calibration.docx) |
| `LAB-NET-network-accounts.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-NET-network-accounts.docx) |
| `LAB-PRC-practicum-operation.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-PRC-practicum-operation.docx) |
| `LAB-SAF-safety-emergency.docx` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-SAF-safety-emergency.docx) |

### PDF

| Document | Download |
|---|---|
| `IOT-02-raspberry-pi-golden-image.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/IOT-02-raspberry-pi-golden-image.pdf) |
| `LAB-000-document-control.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-000-document-control.pdf) |
| `LAB-ACC-access-authorisation.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-ACC-access-authorisation.pdf) |
| `LAB-CMP-competence-induction.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-CMP-competence-induction.pdf) |
| `LAB-EQP-equipment-lifecycle.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-EQP-equipment-lifecycle.pdf) |
| `LAB-INC-incident-change.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-INC-incident-change.pdf) |
| `LAB-MNT-maintenance-calibration.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-MNT-maintenance-calibration.pdf) |
| `LAB-NET-network-accounts.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-NET-network-accounts.pdf) |
| `LAB-PRC-practicum-operation.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-PRC-practicum-operation.pdf) |
| `LAB-SAF-safety-emergency.pdf` | [Download](https://raw.githubusercontent.com/yonz2/pns-sop-pipeline/rendered/LAB-SAF-safety-emergency.pdf) |

---

## What this branch is, and is not

- **A generated copy.** Every file here is produced by the pipeline from
  the Markdown in `sop/` on `main`. **The Markdown is the source of
  record**; this branch is a convenience view of it.
- **Not authoritative.** It is overwritten on each run, so do not branch
  from it, merge it, or cite its commit hashes.
- **Not for editing.** A correction belongs in the Markdown source, not in
  a downloaded Word file; edit the source and the next render carries the
  change.

## Retention

- **This branch** holds only the current set of documents. It is
  force-pushed on every run, so it does not grow without limit.
- **Workflow artifacts** are removed after their retention period. If a
  download link to an artifact returns `404`, download the current files
  from this branch instead.
- The full policy is in `docs/retention.md` on `main`.
