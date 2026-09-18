# Findings: the translation pipeline, run against a real model

*Written 2026-09-18, after exercising `translate.py` and `validate.py` end to end
against a live model endpoint for the first time. Six defects were fixed; one is
left open here because it is a change to the `R1b` §6 contract and that is the
department's decision, not an implementation detail.*

---

## 1. Why none of this was visible before

The translation pipeline had **never run against a model**. Three facts agree:

- there is no `translated` branch in the repository;
- every `Translate SOP corpus` workflow run has finished in 10–28 seconds, which
  is the "model endpoint not configured" skip path;
- the first real run failed six of the eleven checks at once.

This is not a criticism of the design. `translate.py` and `validate.py` are
careful, and the *safety* property they exist for held up perfectly under every
failure below: nothing unverified was ever published, and the Indonesian source
of record was never touched. What had not been tested was everything around that
property.

---

## 2. Fixed

| # | Defect | Consequence |
|---|---|---|
| 1 | `validate.py` ran every check on the **raw file**, including the provenance front matter `translate.py` had just added | Checks 4 and 6 were **unpassable by construction**. A byte-identical translation failed both: `source_document: LAB-ACC` added a third occurrence of a protected pattern, and the sha256 `source_content_hash` added digits the source cannot contain. Checks now compare document *bodies*; check 7, which exists to validate front matter, still receives the whole file |
| 2 | No `FLAGS` block was ever produced or stored | The prompt asked for "exactly two blocks"; `translate.py` wrote the entire reply as the body; `check_11` then searched that body for `FLAGS:`. Had a model complied, `render.js` would have printed a JSON array **into the signed procedure**. Flags are now parsed out and stored in the front matter as `translation_flags`; `check_11` validates each object's shape |
| 3 | Models intermittently wrap the whole reply in a ```` ```markdown ```` fence | Written out verbatim, the entire procedure became one code block. Observed on one reply in three. `strip_outer_fence()` removes only a fence spanning the whole reply, leaving the document's own fences alone |
| 4 | An empty completion was written out and validated | Produced a **two-character document** that then failed seven checks — output that describes the symptom accurately and hides the cause completely. An empty or truncated completion is a *model* failure and now fails at the translate step, reporting `finish_reason` and `completion_tokens` |
| 5 | Configuration errors surfaced as raw `urllib` tracebacks | A wrong model name gave nine lines ending in `HTTP Error 404: Not Found`, which does not say whether the endpoint or the model is wrong. 404, 401/403 and `URLError` now name `LLM_ENDPOINT` and `LLM_MODEL` and explain the likely cause |
| 6 | — | *(see `scripts/` for the local runner added alongside these)* |

---

## 3. Open: the eleven checks can be passed without translating anything

**This is the finding that matters, and it is a contract question, not a bug.**

`qwen3.5:397b-cloud` passed **all eleven checks** on `LAB-ACC` in 149 seconds.
The rendered `.docx` and `.pdf` were produced and would have been published to
the `translated` branch. The body it produced reads:

> Menetapkan siapa yang boleh memasuki **laboratory**, dengan pengawasan seperti
> apa, pada waktu apa, dan bagaimana hal itu dicatat — sehingga selalu dapat
> dinyatakan siapa yang memiliki akses terhadap peralatan dan kapan.

That is the Indonesian source with a handful of nouns swapped. It is not a
translation, and it passed.

### Why it passed

`check_4` compares raw substring counts — `src.count(term) != out.count(term)` —
over a glossary of 68 terms. Those terms include:

```
'dari'   (= "from" / "of", a preposition; 5 occurrences in this document)
'No', 'Orang', 'Tanggal', 'Kegiatan'
'1', '2', '3', '4', '5', '6', '7'        <- bare digits, as glossary ids
```

Preserving `'dari'` five times requires the prose to stay Indonesian. Preserving
every digit is required anyway by check 6. Check 1 requires headings to be
*identical*. Check 9 requires the length to stay within 0.7–1.6×.

Taken together, **the eleven checks are satisfied by copying the source and
violated by translating it.** A model doing its best finds that local optimum.

`'No'` is also matched inside *Nomor*, *November* and *Note*, since the
comparison is substring-based rather than word-boundary-based.

### And nothing checks for English

No check verifies that the output is in the target language. Every check asks
"did you preserve X"; none asks "did you translate". The two failure modes —
*translated too freely* and *did not translate at all* — are not distinguished,
and only the first is caught.

### Why this is more dangerous than a failing check

`docs/retention.md` §3 already makes the argument, about stale renderings:

> A stale English rendering is more dangerous than no English rendering. It says,
> in English, that it is the current procedure — while the Indonesian source of
> record has moved on. A reader who cannot read the Indonesian has no way to tell.

An untranslated rendering published as the English document is the same hazard
arriving by a different route, and with a green pipeline behind it.

### What was deliberately *not* done

An earlier attempt reframed the prompt's rule 5 — telling the model that glossary
terms are protected tokens to be copied verbatim rather than substituted. It
resolves a genuine contradiction (rule 5 instructs the model to do exactly what
checks 4 and 5 reject), but on its own it makes the copy-instead-of-translate
outcome *more* likely, turning a loud failure into a silent pass. **It has been
reverted**, and rule 5 still contradicts checks 4 and 5. That contradiction is
real and unresolved; it is listed below rather than patched, because every
available patch changes the `R1b` §6 contract.

### Options for the department

1. **Narrow check 4.** Match on word boundaries, and enforce only distinctive
   multi-word terms — form-field labels and section headings, which is what the
   closed vocabulary was described as in `document-pipeline/README.md`. Drop
   prepositions and bare digits, which check 6 already covers.
2. **Add a deterministic language check.** A stopword-ratio test over the body
   distinguishes Indonesian from English without a model, satisfying `R1b` §4's
   requirement that no model judges its own output.
3. **Resolve rule 5 against checks 4 and 5.** Decide whether glossary terms are
   translated or preserved, and make the prompt and the validator agree. They
   currently cannot both be satisfied.

Items 1 and 3 must be decided together: they are the same question asked of the
validator and of the prompt.

---

## 4. Observations on model behaviour

Not defects, but they bear on which endpoint the department configures.

- **Latency varied enormously for byte-identical input**: 61 s, 149 s, 835 s and
  ~13 min across runs. `LLM_TIMEOUT` defaults to 120 s in `translate.py`, which
  is too short; the local runner sets 900 s.
- **Empty completions correlated with the slow runs.** The cause is not settled.
  Ollama's proxy was separately observed returning `502 Bad Gateway` with
  `dial tcp: lookup ollama.com: no such host` and `An established connection was
  aborted by the software in your host machine`, so a dropped upstream connection
  surfacing as an empty `200` is at least as plausible as anything about the
  model. Defect 4 above now reports `finish_reason` and `completion_tokens`, which
  is the evidence needed to settle it next time.
- **Model naming is route-dependent.** Through a local Ollama a cloud model needs
  its cloud suffix (`gpt-oss:120b-cloud`); called directly at `https://ollama.com/v1`
  it is the bare name, and a key is required there but not locally.
- **`gpt-oss:120b-cloud`** failed only checks 4 and 5 — the glossary contradiction
  above — in 21 seconds. Of the models tried it came closest to translating while
  respecting the form.

---

## 5. What is safe to rely on today

The Indonesian half of the pipeline is sound and is in production use: `render.js`
produces the department's form, and the output is byte-identical between CI and a
local workstation apart from the embedded render timestamp.

The English half should be treated as **not yet in service** until section 3 is
resolved. The workflow's current behaviour — skipping when `LLM_ENDPOINT` is
unconfigured, and holding any document that fails validation — is the correct
posture in the meantime, and no configuration change is needed to maintain it.
