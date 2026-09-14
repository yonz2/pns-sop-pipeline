# The Git Workflow

*How a laboratory procedure is changed, reviewed, approved and rendered.*

This repository is not a folder of documents that happens to be kept in Git. **The
repository is the document management system.** The Markdown files under `sop/` are the
documents of record; Git records who changed each one, when, why and with whose
authority; the pipeline derives the Word and PDF forms from them. Nothing else is a
source of truth.

The model is the one the Linux kernel uses, reduced to the size of one laboratory. It is
deliberately conventional: a branch per change, a pull request per branch, a review
before integration, and a linear history of reviewed, integrated commits.

---

## 1. The two kinds of thing in this repository

Every path falls into exactly one of two classes, and the whole workflow turns on the
distinction.

| Class | Paths | Mutability |
|---|---|---|
| **Sources** | `sop/*.md`, `document-pipeline/**` | Changed only by reviewed commits on `main` |
| **Derived artifacts** | `out/*.docx`, `out/*.pdf`, the `rendered` branch | Generated from the sources; never edited, never authoritative |

**A derived artifact is never committed to `main` and never edited by hand.** If a
rendered document is wrong, the fault is in its Markdown source, and that is where the
correction goes. Editing a `.docx` would fork the document from its own source and
silently diverge from the form the pipeline guarantees.

---

## 2. Branches

`main` is the **integration branch** and the source of record. It is protected
(§8). It advances only by reviewed, integrated commits.

Work is done on **topic branches** — short-lived, named for the change, forked from
`main` and deleted after integration:

```
sop/LAB-NET-accounts-revision
sop/IOT-04-power-calibration
pipeline/table-column-widths
```

The convention `<class>/<subject>` is a convenience, not a rule; the requirement is one
branch, one coherent change. A branch that rewrites an approval block and also reflows a
table is two changes and should be two branches.

Branches live for hours or days, never weeks. A long-lived branch is a branch that has
stopped being a change and started being a fork.

### Generated branches

Three names are reserved for the pipeline. They are **outputs**, not places to work, and
are described fully in §6 and §12:

| Branch | What it holds | Grows? |
|---|---|---|
| `rendered` | the Indonesian documents, the deliverable | no — force-pushed snapshot |
| `translated` | the English renderings | no — force-pushed snapshot |
| `draft-*` | one draft render each | **yes** — one branch per run |

The first two are overwritten on every run, so they never grow. `draft-*` branches
accumulate, and **retention** (§12) reaps them. No automation ever deletes a topic branch,
because it may hold unreviewed work.

---

## 3. Getting the repository and the editor

The workflow in §5 assumes one thing is already true: the repository is on the machine and
is open in an editor. That is step 0 — once per person, per machine.

### Install, then clone

1. **Install Git and VS Code.** Git for Windows, Git for macOS, or the package manager on
   Linux; VS Code from its own installer. The repository is normalised to LF line endings,
   so a Windows installation's default line-ending choice does not reach the documents.

2. **Tell Git who you are.** This is what makes each commit attributable (§10):

   ```bash
   git config --global user.name  "Nama Lengkap"
   git config --global user.email "you@example.polines.ac.id"
   ```

3. **Clone the repository.** On the GitHub page, **Code → HTTPS** copies the URL, or use
   VS Code (**Ctrl+Shift+P → Git: Clone**) and paste it. On the command line:

   ```bash
   git clone https://github.com/yonz2/pns-sop-pipeline.git
   ```

   Pushing needs either **write access** to the repository (a collaborator invite) or your
   own **fork**. Reading the documents needs neither.

4. **Open the folder in VS Code.** The repository is the unit of work, so open the folder —
   not a single file — with **File → Open Folder**. On first open VS Code offers the
   recommended extensions (§11); accept them.

### VS Code is the working environment

VS Code is the recommended editor, and the one this document assumes. It does not constrain
the documents — a file in `sop/` is plain Markdown and any editor will do — but it is what
the rest of the workflow is written against, because the GitHub extensions put the branch,
the commit and the review in one window, the Markdown extensions make front matter and
tables safe to edit, and `.devcontainer/` gives every machine the same renderer.

Opening the repository as a **dev container** is optional, and is needed only to *render*
locally. In VS Code: **Reopen in Container** builds the renderer image and opens the
integrated terminal with the same tools CI uses:

```bash
./document-pipeline/entrypoint.sh render-all ./sop   # -> ./out/*.docx, ./out/*.pdf
```

Docker is the only prerequisite for that, and rendering is otherwise the pipeline's job —
on the happy path nobody renders by hand (§6). Editing the Markdown needs no container at
all.

The GitHub extensions ask for authorisation on first use, and pushing over HTTPS asks for
credentials once: use the built-in VS Code GitHub sign-in or a personal access token.
Whether you may push, or should work from a fork, is decided by the repository's
permissions.

---

## 4. The unit of change is a commit

A commit is a change to the sources, with a message that states *what* changed and *why*.
The subject line is imperative and under ~72 characters; the body, when needed, explains
the reasoning — and the reasoning is the part that has value a year later.

```
sop: fill Kode Butir Kegiatan from the department's register

The activity code was left blank by the template, which refuses to guess
between II.A.12.a and II.A.12.b. The department resolved it in the drafting
session of 14 September; LAB-SAF and LAB-MNT carry the same value.
```

**Front matter is metadata, and metadata is edited like content.** A revision number, an
issue date, a review interval and an owner live in the file's YAML front matter; changing
them there is what changes the rendered form. A new revision is therefore a commit that
bumps `revisi` and `tanggal_terbit` **and** changes the text — never a change to the
renderer alone.

---

## 5. The happy path

```
   main ──o────────o────────o────────────▶   (source of record, protected)
           \        ▲        ▲
            \       │        │ integrate (merge / rebase)
             o──o──o        │
         topic branch       │
             │              │
             └── pull request ──▶ review ──▶ approve
```

1. **Fork a topic branch** from `main`.

   ```bash
   git switch -c sop/LAB-NET-accounts-revision main
   ```

2. **Commit the change** to the source file or files, with a message that gives the
   reason.

   ```bash
   git add sop/LAB-NET-network-accounts.md
   git commit -m "sop: close the account-lifecycle gap in LAB-NET"
   ```

3. **Push the branch** and **open a pull request** into `main`.

   ```bash
   git push -u origin sop/LAB-NET-accounts-revision
   gh pr create --base main --fill
   ```

4. **Review.** A pull request is the review record. A code owner (§7) reads the diff,
   and either approves it or requests changes. The review is not a formality: it is the
   point at which the department takes ownership of the wording, in the same way a
   signature does on paper.

5. **Integrate.** Once approved, the pull request is merged into `main`. The merge is
   the **authorisation** — by the time `main` advances, the decision has been made and
   is recorded in history.

6. **Render.** The merge to `main` triggers the pipeline (§6). The Word and PDF forms
   are generated from the new source and published. Nobody renders by hand on the happy
   path.

7. **Delete the branch.** The change is now on `main`; the branch has no further purpose.

   ```bash
   git branch -d sop/LAB-NET-accounts-revision
   ```

### The same path in VS Code

The command line is not required. Steps 1–5 above have a direct equivalent in VS Code,
and the GitHub Pull Requests extension brings the review into the same window. The rules
do not move: one branch, one coherent change, a review before integration. Only the
buttons do.

1. **Fork the branch.** Click the branch name in the **Status Bar** (bottom-left, it reads
   `main`), choose **Create new branch…**, type `sop/LAB-NET-accounts-revision`, and select
   `main` as the base when asked. VS Code switches to it at once. Fetch first if `main` is
   likely stale (**Source Control → … → Pull**).

2. **Edit the document.** Open `sop/LAB-NET-network-accounts.md` and make the change. Save.
   Front matter is edited here too, and it is part of the file (§4).

3. **Commit.** Open the **Source Control** view (`Ctrl+Shift+G`). The changed file is
   listed; click its **+** to stage it, type the message —
   `sop: close the account-lifecycle gap in LAB-NET` — and press `Ctrl+Enter`. Read the
   **Changes** diff before committing; the **+** is `git add`, nothing more.

4. **Publish the branch.** The Status Bar shows **Publish Branch** (a cloud with an
   up-arrow). Click it once; this is `git push -u origin …`. It becomes **Sync Changes**
   for later commits.

5. **Open the pull request.** With the GitHub Pull Requests extension, the **Source
   Control** view offers **Create Pull Request**, or use **GitHub → Create Pull Request**
   in the Activity Bar. Set `main` as the base, give the title and the reason in the body,
   and create it. The same button appears on github.com for the freshly pushed branch.

Review and integration (steps 4–6 above) happen in the extension's **Pull Requests** list
or on GitHub; either way the merge to `main` is the authorisation, and the merge triggers
the pipeline (§6). The render is the one step with no button — it is a consequence of the
merge, not an action to take. Delete the branch from the same list once it is merged
(step 7).

---

**Merging, precisely.** A merge that preserves the pull request as one point of history —
a true merge commit (`--no-ff`) or a squashed commit — is preferred over a fast-forward,
because it keeps the *review* visible as an event in the log. A fast-forward erases the
fact that the change was reviewed at all. `main` is therefore not one long line; it is a
line of reviewed integration points, each traceable to the pull request that produced it.

---

## 6. What the pipeline does, and when

The pipeline is `document-pipeline/`. It does two jobs, and they run as **separate**
workflows for a reason: the Indonesian documents are rendered mechanically, while the
English renderings are generated by a language model, which is a different kind of step
with a different failure mode. A translation outage must never block the documents that
are actually in force, so the two never share a job.

| Workflow | Trigger | Produces |
|---|---|---|
| `render.yml` | merge to `main` | Indonesian `.docx`/`.pdf` → `rendered` branch |
| `translate.yml` | merge to `main`, or on demand | English `.docx`/`.pdf` → `translated` branch |
| `render-draft.yml` | on demand | a draft's `.docx`/`.pdf` → `draft-*` branch |

### On merge to `main` — the source of record is rendered

The workflow `.github/workflows/render.yml` runs whenever a push to `main` touches
`sop/**` or `document-pipeline/**`. It:

1. builds the renderer image,
2. renders the procedures the push actually changed — **not the whole corpus** —
3. uploads the complete current set as workflow artifacts (downloadable from the Actions
   run), and
4. force-pushes it to a derived branch, **`rendered`**, so the current documents are
   always reachable at a stable URL.

#### Only the changed procedures are rendered

The work is **incremental**, and the reasoning is worth stating because it is not only an
optimisation. The `rendered` branch must always hold the *complete* set of documents, so
the changed procedures are re-rendered and then **overlaid on the previous output**,
rather than the branch being regenerated from nothing. The result is identical to a full
render; the work is not.

The diff base is **the commit recorded in `.rendered-from` on the `rendered` branch** —
the commit that last successfully produced the branch — not the push's `before` sha. That
one choice makes the render idempotent and self-catching-up: **if a previous run was
cancelled or failed, the next run diffs from the last successful render and picks up
everything it missed.** A marker that is absent, or no longer an ancestor of the pushed
commit (after a force-push or history rewrite), is ignored in favour of the `before` sha;
if that too is unusable, a full render is done.

A full render is forced whenever:

- **anything under `document-pipeline/` changed** — the renderer, the form template or the
  glossary, any of which can change every document the pipeline produces;
- there is **no `rendered` branch** yet, or no usable diff base;
- the **completeness check** fails: after the incremental pass, the rendered set is
  compared against the sources, and a missing document or an output with no source
  triggers a full render. This makes the mechanism self-healing rather than merely fast.

A document that is deleted on `main` has its rendered output removed on the next run, so
the `rendered` branch never carries a document that no longer exists.

**The `rendered` branch carries no authority.** It is overwritten on every merge and its
history is not preserved. The Markdown on `main` is the source of record; `rendered` is a
convenience view of it. Do not branch from it, do not merge it, do not cite its commit
hashes. (`.rendered-from` is internal bookkeeping for the incremental render; it is not
part of the document set.)

### On merge to `main` — the English rendering is generated

The workflow `.github/workflows/translate.yml` generates the **English rendering** of each
document, under the rules of `R1b-translation-pipeline.md`. **Indonesian is the source of
record; the English document is generated from it, never authored**, and it is never
stored in `sop/`. On merge, or on demand, it:

1. runs the Indonesian source through a language model,
2. puts the result through the **eleven deterministic checks** of `validate.py` — no model
   is involved in deciding whether the model's output is safe,
3. renders the accepted rendering through the same institutional form as the Indonesian,
   and
4. publishes the set to a derived branch, **`translated`**, with the English Markdown
   alongside the `.docx` and `.pdf`.

It mirrors the render workflow exactly in its incremental behaviour — only changed
procedures are translated, overlaid on the previous output, with the diff base recorded in
`.translated-from` so a cancelled run is caught up by the next, and a completeness check
that self-heals. Three properties are specific to it and matter more than the mechanics:

- **A document that fails validation is held, not published.** It is removed from the
  branch, listed in `HELD.md`, and the job fails. **A failure holds; it never publishes a
  warning** — an English procedure with a caveat at the top would be read as a procedure
  and the caveat would not be read at all. A held document does not trigger a self-healing
  full run, because re-running would meet the same failure.
- **The model is a configuration value, not a redesign** (R3 §8.1). The endpoint, model and
  key are read from repository variables and a secret, never hard-coded: a local model
  runner on campus or a cloud service, as the institution decides.
- **An unconfigured endpoint warns and skips on merge.** The endpoint may not be chosen yet
  — it is open question 4 in `R1b` — and an untranslated document must not fail the
  Indonesian documents that are in force. A manual run is explicit intent, so there an
  unconfigured endpoint is an error. The `dry_run` input exercises the whole orchestration
  without a model; **a dry run never publishes to the branch**, because placeholder output
  that looks like generated documents would be mistaken for them.

**The `translated` branch carries no authority either.** It is derived, overwritten on each
run, and the Indonesian Markdown on `main` remains the source of record. Where the two
disagree, the Indonesian document is the one in force.

### On demand — the draft exception

The happy path renders only what has been approved. But a procedure is often circulated
for comment *before* it is ready to be approved, and the reviewer wants to read the Word
form rather than the Markdown.

The workflow `.github/workflows/render-draft.yml` is the exception. It is started by hand
(**Actions → Render draft (unapproved) → Run workflow**), takes a branch name, and:

1. checks out that branch — which need **not** be reviewed, need **not** be `main` and
   may be mid-edit,
2. renders it exactly as `main` would be rendered,
3. uploads the output as an artifact, and
4. force-pushes it to a derived branch named **`draft-*`**.

The rules of the exception are firm:

- **A draft render never touches `main` and never advances it.** Approval remains the
  merge; nothing here substitutes for it.
- **A `draft-*` branch is stamped with `DRAFT-README.md`** stating the branch and commit
  it came from. A draft that loses that stamp is indistinguishable from an approved
  document and must not be circulated.
- **A `draft-*` branch is disposable.** It is force-pushed on each run and may be deleted
  at any time without consequence. It is evidence of a draft, not a record of one.

The exception exists so the review can happen on the rendered form. It is not a way to
publish without review.

---

## 7. Roles, and who may approve

Three roles, which one person may hold in more than one combination:

| Role | May |
|---|---|
| **Author** | fork branches, commit, push, open pull requests |
| **Reviewer / Code owner** | read a pull request, approve it or request changes |
| **Maintainer** | integrate approved pull requests into `main`, manage protection and settings |

**A pull request is approved by a code owner and by someone other than its author.**
GitHub will not let an author approve their own pull request, and the branch protection
rule requires at least one approval (§8) — so the gate is real. The reviewers are named
in `.github/CODEOWNERS`; a change to any file under `sop/` or `document-pipeline/` is
owned by the laboratory's code owners.

**For the department, the mapping is direct.** The author is a PLP drafting or revising a
procedure. The code owner is the **Head of the Laboratory** — the same office that
approves the SOP on the form — or a PLP they name. The maintainer is whoever administers
the repository. **The Git approval and the signature on the form are the same act in two
media**; the signature block that the renderer prints is what the approval record refers
to.

---

## 8. Protecting `main`

The approval requirement does not exist until it is configured. On `main` the following
are set:

- **Require a pull request before merging** — no direct pushes.
- **Require review from Code Owners** — this is what gives `CODEOWNERS` force.
- **Dismiss stale approvals when new commits are pushed** — an approval refers to a
  specific revision of the diff, not to the branch in general.
- **Require conversation resolution** — no open review thread may be left unresolved.
- **No force-pushes, no deletions.**
- **Required approvals: 0 at present.** Raise this to **1** as soon as a second account
  with write access exists. It is 0 only because the repository currently has a single
  collaborator and GitHub forbids approving one's own pull request — with 1 required
  and one account, no pull request could ever be merged. **A gate that cannot be passed
  is not a gate**; the setting is deliberately at the value that lets the repository
  function until a reviewer is added.
- **Administrators may bypass.** `enforce_admins` is off, so an administrator can push
  directly and can force-push. **Do not rely on this**: it is an escape hatch for
  recovery, not a working method. Turn it on once the repository is handed over and the
  administrator is no longer also the author.

Until these are set, `main` is unprotected and the workflow is only a convention. With
them set, **Git enforces the review** rather than relying on anyone's discipline. The
one setting that is currently below full strength is the number of required approvals,
and it is documented above rather than allowed to look complete.

---

## 9. The full lifecycle of one document

A single procedure, end to end:

1. A PLP forks `sop/LAB-INC-incident-change` off `main` and edits the source file.
2. They push the branch and open a pull request: *"LAB-INC: add the escalation
   contacts."*
3. Before the review, they want the department to see the Word form. They run the
   **Render draft** workflow against their branch. It publishes `draft-sop-lab-inc-...`
   with a `DRAFT-README.md`. They circulate the artifact. Comments come back as pull
   request review comments.
4. The Head of the Laboratory, as code owner, reviews the diff and approves.
5. The maintainer integrates the pull request into `main`.
6. The merge triggers `render.yml`. The approved document is rendered to `.docx` and
   `.pdf`, uploaded as an artifact, and pushed to `rendered`.
7. The branch is deleted. The approved revision is now what `render.yml` produces from
   `main`, and the pull request remains in history as the record of the review.

---

## 10. What Git guarantees here, and what it does not

**Guaranteed.** Every change to a document is attributable to a commit, an author and a
review, and every rendered document is reproducible from the commit it came from. An
approval refers to a specific revision. History is append-only: a superseded procedure is
replaced by a new revision, never rewritten in place.

**Not guaranteed by Git.** Git records *that* a review happened and *who* approved; it
does not record the substance of the discussion — that lives in the pull request. Git
does not decide whether a procedure is technically correct; the code owner does. And a
`draft-*` or `rendered` branch, being force-pushed, is not a durable citation — cite the
commit on `main`.

---

## 11. Recommended VS Code extensions

The workflow in §5 needs nothing beyond VS Code and Git, but a few kinds of task recur here
— writing Markdown, editing front matter and workflow YAML, watching a run, reading history
and blame, and opening a pull request — and there is a well-known extension for each. They
are recommendations, not requirements: a change made in any editor is the same change.

| Extension | ID | For |
|---|---|---|
| **Markdown All in One** | `yzhang.markdown-all-in-one` | Editing the sources: shortcuts, list continuation, table of contents, a live preview (`Ctrl+K V`) beside the text |
| **markdownlint** | `DavidAnson.vscode-markdownlint` | Flags malformed Markdown as you type — the check a rendered document would otherwise reveal |
| **YAML** | `redhat.vscode-yaml` | Front matter and `.github/workflows/*.yml`: schema validation and completion, instead of discovering a typo at render time |
| **GitHub Pull Requests and Issues** | `GitHub.vscode-pull-request-github` | The review in §7 without leaving the window: create a pull request, read the diff, approve or request changes |
| **GitHub Actions** | `github.vscode-github-actions` | Watching `render.yml` and `translate.yml` runs (§6) and reading their logs from the editor |
| **GitLens** | `eamodio.gitlens` | Inline blame and file history — who changed this line, in which revision; the attribution §10 promises |
| **Code Spell Checker** | `streetsidesoftware.code-spell-checker` | Typos in a procedure that would otherwise reach the signed form |

Two notes on the list. **Markdown All in One and markdownlint are the ones that matter for
writing the documents**; the rest are conveniences around the same Git workflow. And a
linter **flags**, it does not fix: the extension is a second reader, not an approver, and
it never substitutes for the review in §7.

The same list is declared in `.vscode/extensions.json`, so on first opening the repository
VS Code offers to install them. Accepting is the whole setup. If the file is absent, install
them by **Extensions** (`Ctrl+Shift+X`) and the ID above.

---

## 12. Retention — how long generated content is kept

The pipeline produces content on every run. Left alone, some of it accumulates. This
section states what is bounded, how, and why. **The full policy and its reasoning are in
`docs/retention.md`**; this is the summary a workflow participant needs.

### What grows, and what does not

- **`rendered` and `translated` do not grow.** Both are force-pushed snapshots — one
  commit, replaced each run. A decade of renders leaves them the same size as today.
- **`draft-*` branches do grow.** One new branch per draft render, each a complete copy of
  the document set.
- **Workflow artifacts do grow.** One set per run per workflow; GitHub's default is a
  **90-day** retention, far longer than a downloaded convenience warrants. (At the time of
  writing, 28 had accumulated within days — including an implicit Docker build-cache
  artifact per build.)

### The policy

| Asset | Kept | Why |
|---|---|---|
| `rendered` branch | **never deleted** | It is the deliverable. Stale means the pipeline broke — fix it, do not delete the evidence |
| `translated` branch | until **30 days** behind `main` | Generated and rebuildable, and **stale is worse than absent** (see below) |
| `draft-*` branches | **7 days** | Disposable by design (see §6, the draft exception) |
| Workflow artifacts | **14 days** | A convenience; the branch always holds the current set |
| Draft-run artifacts | **7 days** | A draft is superseded within days |
| Docker build cache | **7 days** | Speeds builds; worthless after a week |
| Topic branches | **never deleted by automation** | May hold unreviewed work |

The three numeric limits are **repository variables** — `DRAFT_RETENTION_DAYS`,
`TRANSLATED_RETENTION_DAYS`, `ARTIFACT_RETENTION_DAYS` (*Settings → Secrets and variables →
Actions → Variables*) — so a maintainer tunes them without editing a workflow.

### Why `translated` is treated differently from `draft-*`

A `draft-*` branch is removed purely on **age**. The `translated` branch is removed on
**staleness**: only when it has been behind `main` longer than the threshold. That
distinction is deliberate, because the English rendering has a failure mode the Indonesian
does not:

> **A stale English rendering is more dangerous than no English rendering.** It states, in
> English, that it is the current procedure — while the Indonesian source of record has
> moved on. A reader who cannot read the Indonesian cannot tell. So `translated` is deleted
> when it can no longer be trusted, and regenerated on the next run. It is never deleted
> while current.

`rendered` is the opposite case and is **never deleted.** If it is behind `main`, the render
workflow failed; the retention run emits a warning and leaves it alone.

### Running retention

The workflow `.github/workflows/retention.yml` runs **weekly** (Mondays, 03:17 UTC) and can
be started by hand from **Actions → Retention → Run workflow** — worth doing after a burst
of draft renders rather than waiting for Monday. It is always safe to run, and the script
supports a report-only mode:

```bash
DRY_RUN=true GITHUB_REPOSITORY=<owner>/<repo> \
  bash .github/scripts/prune-generated.sh 7 30
```

### What retention does *not* touch

The Markdown sources on `main`, the `rendered` branch, and the history of `main` are outside
this policy entirely. **Nothing load-bearing is ever deleted** — only content that is
regenerable from those, and only once it has served its purpose.
