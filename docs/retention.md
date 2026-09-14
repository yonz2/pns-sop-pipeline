# Retention

*How long generated content is kept, and why. This is the policy; the
implementation is `.github/workflows/retention.yml` and the scripts it calls.
A short summary for workflow participants is in `docs/git-workflow.md` §12.*

## 1. The problem, stated with real numbers

The pipeline is deliberately conservative about storage, but three things grow
anyway if nothing bounds them:

| What | Growth behaviour | Observed |
|---|---|---|
| **Workflow artifacts** | One set per run, per workflow. GitHub's default retention is **90 days**. | **28 artifacts** had accumulated within days of the repository being created — `sop-rendered`, `sop-rendered-pdf`, `sop-translated`, `sop-draft-*`, and an implicit Docker build-cache artifact per build |
| **`draft-*` branches** | One new branch per draft render. Nothing deleted them. Each is a **complete copy** of the document set. | A branch per run, forever, until reaped |
| **Docker build cache** | One `…dockerbuild` artifact per image build | Kept as long as the default retention allows |

Everything else is *bounded* by construction, which is the important part:

- **`rendered` and `translated` do not grow.** Both are **force-pushed
  snapshots** — one commit, replaced on every run. Ten years of renders leave
  both branches the same size as today. (Verified: the `rendered` branch carries
  a single commit.)
- **Markdown sources are tiny.** The whole repository is about 1.3 MB.

So the storage risk is **artifacts and draft branches**, not the documents.
That is what this policy bounds.

## 2. The policy

| Asset | Retention | Set by | Rationale |
|---|---|---|---|
| **`rendered` branch** | **Never deleted** | — | It is the deliverable. If it is stale, the pipeline is broken; that is fixed, not cleaned up |
| **`translated` branch** | Deleted after **30 days** behind `main` | `vars.TRANSLATED_RETENTION_DAYS` | Generated, rebuildable — and **stale is worse than absent** (see §3) |
| **`draft-*` branches** | Deleted after **7 days** | `vars.DRAFT_RETENTION_DAYS` | Disposable by design (`docs/git-workflow.md` §6). A week is generous for circulating a draft |
| **Workflow artifacts** | **14 days** | `vars.ARTIFACT_RETENTION_DAYS` | A convenience, not the archive; the branch always holds the current set |
| **Draft-run artifacts** | **7 days** | workflow | A draft is superseded or discarded within days |
| **Docker build cache** | **7 days** | retention workflow | Speeds up builds; worthless after a week |
| **Topic branches** (`sop/…`, `ci/…`) | **Never deleted by automation** | — | May hold unreviewed work. Deleting someone's branch for them is not automation's job |

All three variables are **repository variables** (*Settings → Secrets and
variables → Actions → Variables*), so a maintainer tunes them without editing a
workflow. The fallbacks in the workflows are the values above.

## 3. Why `translated` has a different rule from `rendered`

`draft-*` branches are removed purely on **age** — they are disposable and
nothing depends on them.

`translated` is removed on **staleness**: it is deleted only when it has been
behind `main` for longer than the threshold. The distinction matters, because
the English rendering has a failure mode the Indonesian documents do not:

> **A stale English rendering is more dangerous than no English rendering.**
> It says, in English, that it is the current procedure — while the Indonesian
> source of record has moved on. A reader who cannot read the Indonesian has no
> way to tell. `R1b` §8 makes `source_content_hash` visible for exactly this
> reason: the pipeline can report a rendering as out of date without anyone
> having to notice.

So `translated` is deleted when it can no longer be trusted, and regenerated on
the next run. **It is never deleted while it is current.**

`rendered` is the opposite case and is **never deleted automatically.** If it is
behind `main`, that means the render workflow failed — a problem to surface, not
to paper over by removing the evidence. The retention run emits a warning:

```
::warning::rendered is NOT current (built from a1b2c3d4, main is e5f6a7b8)
— the render workflow may have failed; not deleting
```

## 4. What this means in practice

- **The download links stay valid, with one caveat.** The links in the
  branch README point at `raw.githubusercontent.com`, so they resolve as long as
  the branch exists. `rendered` always does. A `translated` link can stop
  working if the renderings went stale and were reaped — in which case they were
  no longer accurate anyway.
- **Artifact links expire.** If a link to an artifact returns `404`, that is the
  retention policy working, not a fault. Download from the branch instead.
- **Nothing load-bearing is ever deleted.** The Markdown sources on `main`, the
  `rendered` branch, and the history of `main` itself are outside this policy
  entirely.

## 5. Running it by hand

The retention workflow runs **weekly** (Mondays, 03:17 UTC) and can be started
from **Actions → Retention → Run workflow**. That is worth doing after a burst
of draft renders, rather than waiting for Monday.

The script is safe to run in report-only mode — it lists what it *would* delete:

```bash
DRY_RUN=true GITHUB_REPOSITORY=yonz2/pns-sop-pipeline \
  bash .github/scripts/prune-generated.sh 7 30
```

## 6. If the repository is ever made public

The calculation changes, because a public repository has unlimited free Actions
storage while a private one is metered. The policy stays correct either way —
bounded artifacts are simply good practice — but the urgency of the artifact
retention drops. Branch retention is unaffected: it is about keeping the
repository and its generated branches tidy and trustworthy, not only about cost.
