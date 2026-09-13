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
(§7). It advances only by reviewed, integrated commits.

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

---

## 3. The unit of change is a commit

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

## 4. The happy path

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

4. **Review.** A pull request is the review record. A code owner (§6) reads the diff,
   and either approves it or requests changes. The review is not a formality: it is the
   point at which the department takes ownership of the wording, in the same way a
   signature does on paper.

5. **Integrate.** Once approved, the pull request is merged into `main`. The merge is
   the **authorisation** — by the time `main` advances, the decision has been made and
   is recorded in history.

6. **Render.** The merge to `main` triggers the pipeline (§5). The Word and PDF forms
   are generated from the new source and published. Nobody renders by hand on the happy
   path.

7. **Delete the branch.** The change is now on `main`; the branch has no further purpose.

   ```bash
   git branch -d sop/LAB-NET-accounts-revision
   ```

**Merging, precisely.** A merge that preserves the pull request as one point of history —
a true merge commit (`--no-ff`) or a squashed commit — is preferred over a fast-forward,
because it keeps the *review* visible as an event in the log. A fast-forward erases the
fact that the change was reviewed at all. `main` is therefore not one long line; it is a
line of reviewed integration points, each traceable to the pull request that produced it.

---

## 5. What the pipeline does, and when

The renderer is `document-pipeline/`. It is run two ways, for two different purposes.

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

## 6. Roles, and who may approve

Three roles, which one person may hold in more than one combination:

| Role | May |
|---|---|
| **Author** | fork branches, commit, push, open pull requests |
| **Reviewer / Code owner** | read a pull request, approve it or request changes |
| **Maintainer** | integrate approved pull requests into `main`, manage protection and settings |

**A pull request is approved by a code owner and by someone other than its author.**
GitHub will not let an author approve their own pull request, and the branch protection
rule requires at least one approval (§7) — so the gate is real. The reviewers are named
in `.github/CODEOWNERS`; a change to any file under `sop/` or `document-pipeline/` is
owned by the laboratory's code owners.

**For the department, the mapping is direct.** The author is a PLP drafting or revising a
procedure. The code owner is the **Head of the Laboratory** — the same office that
approves the SOP on the form — or a PLP they name. The maintainer is whoever administers
the repository. **The Git approval and the signature on the form are the same act in two
media**; the signature block that the renderer prints is what the approval record refers
to.

---

## 7. Protecting `main`

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

## 8. The full lifecycle of one document

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

## 9. What Git guarantees here, and what it does not

**Guaranteed.** Every change to a document is attributable to a commit, an author and a
review, and every rendered document is reproducible from the commit it came from. An
approval refers to a specific revision. History is append-only: a superseded procedure is
replaced by a new revision, never rewritten in place.

**Not guaranteed by Git.** Git records *that* a review happened and *who* approved; it
does not record the substance of the discussion — that lives in the pull request. Git
does not decide whether a procedure is technically correct; the code owner does. And a
`draft-*` or `rendered` branch, being force-pushed, is not a durable citation — cite the
commit on `main`.
