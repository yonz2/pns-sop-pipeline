# SOP template — `SOP-Pengoperasian-Template.dotx`

*Draft, 1 September 2026. Derived from the department's own documents; for correction, not for
adoption.*

The Word template for an operating procedure in the *Rekaman Kegiatan Pengelolaan Laboratorium*
form. **This is the reference document `R1a-documentation-architecture.md` §2 sets the acceptance
test for**: if a rendered procedure does not carry this band and this approval block, the PLP have
no reason to adopt any of the authoring method, and they would be right.

| File | What it is |
|---|---|
| `SOP-Pengoperasian-Template.dotx` | The template. Double-click to start a new procedure |
| `build-sop-template.js` | How it was built. **Edit this, not the `.dotx`** |
| `logo-rgba.png` | The crest the header band embeds |

---

## 1. What it was derived from

The six `.docx` files in `input-Poloines/from_Kuwat_260826/II.A.12.b. Menyusun SOP Pengoperasian`,
read directly rather than described. Everything below is measured from them:

| Element | Source |
|---|---|
| Header distance 0.75 cm | The three *Menyusun SOP Pengoperasian* documents proper |
| 12 pt body text, single line spacing | The `Normal` style of the same three, and Tata Naskah Dinas |
| The header band, 5 lines, repeated on every page | `header2.xml` — it is a page header, not body text, which is why it repeats |
| *No. Formulir · Edisi/Revisi · Tgl berlaku · Halaman n dari m* | The same band |
| The eleven-row activity record, and its three pre-filled values | Identical in all six |
| *Angka Kredit Acuan* 0,32 | Identical in all six |
| The approval block: **Verifikator · Disahkan Oleh · Dibuat Oleh**, each with role, date, signature space, name and NIP | The Access Point and Cloud Switch documents |
| The step table *No · Langkah Kerja · Penjelasan* | The Tang Krimping document |
| Section order: Tujuan · Ruang Lingkup · Referensi/Rujukan · Prinsip Kerja · Cara Pengoperasian | The Access Point document |

**`Halaman` is a real field pair**, not typed text: it counts pages by itself and stays correct when
a procedure grows.

---

## 2. Where the template does not copy the originals

**Everything in section 1 is measured from the department's documents. The five points below are
not** — each is a deliberate choice, each is stated here rather than left to be noticed, and each is
cheap to reverse.

### Page setup and typography follow Tata Naskah Dinas

**A4, 210 × 297 mm. Margins 2.0 cm on all four sides. Arial, 12 pt, single spacing.**

The source corpus follows none of this: it is mixed across three page sizes (21.59 × 35.56 cm, A4
and 21.59 × 27.94), margins run from 1.90 to 3.17 cm, and the body font is Times New Roman.
**A template is where a standard is applied, not where an inconsistency is carried forward** — so
the template applies the standard and this section records the divergence.

> **One judgement worth taking with the department rather than from an adviser.** Tata Naskah Dinas
> governs **official correspondence** — outgoing letters, memoranda, invitations, certificates,
> reports. An SOP recorded on the national *Rekaman Kegiatan Pengelolaan Laboratorium* form is
> arguably a **record on a prescribed form** rather than correspondence, and a prescribed form
> normally carries its own conventions. **If the form is prescribed centrally in Times New Roman,
> the form wins and `Font` at the top of the build script goes back.** The department will know
> which; an outsider cannot.

The other Tata Naskah Dinas provisions are noted and not enforced by the template, because they are
properties of printing rather than of the file: **white HVS paper, 80 g/m²**, 70 g/m² tolerated for
drafts. Bookman Old Style is reserved for regulatory decrees and does not apply to an SOP.

### Four smaller judgements

1. **`Verivikasi` → `Verifikasi`.** The source documents carry the misspelling in the approval
   block's title row. A typo in a template propagates into every document made from it, so the
   template spells it correctly. **Say so rather than let it be noticed** — and revert it if the
   form is prescribed centrally and must match.

2. **The crest.** The header in the source documents embeds a 103 × 105 pixel image, which prints
   soft. The template uses the 600 × 600 version from the department's own published material —
   the same mark, at a resolution that survives printing.

3. **`Kode Butir Kegiatan` is left blank.** The file names say `II.A.12.b`; the content of every
   document says `II.A.12.a.` The template does not guess between them. **This is worth resolving
   before the drafting sessions**, since it is the field the credit claim rests on.

4. **The header distance stays at 0.75 cm**, as in the originals, rather than being pushed to the
   2.0 cm margin. The band is taller than the top margin, so the body begins below it — which is
   how the source documents behave as well.

---

## 3. The one addition

**`Pengendalian Dokumen` — three rows: owner, next review date, records produced.**

That block is the whole management layer proposed in `R1-SOP-wireframe.md` §4, and it is the only
structural change to a form that otherwise stays exactly as it is. `[C]` The existing corpus has no
version history, no review interval and no document register; three fields on an existing form close
that, and nothing else about the document changes.

**Delete the block if the department does not want it.** The rest of the template is still faithful.

---

## 4. What the template does not decide

- **Step table or flowchart.** Both are used in the corpus — the Tang Krimping procedure uses a
  numbered step table, others use flowcharts with *Ya/Tidak* branches. The template offers the step
  table and says in its own instructional note that a flowchart is equally correct. **Use whichever
  suits the procedure**; a linear task is clearer as a table, a branching one as a flowchart.
- **Language.** This is the **Indonesian** source document, and it is the version that is signed and
  that earns the credit. The English rendering is generated from it, never authored — see
  `R1b-translation-pipeline.md`.
- **Maintenance procedures.** This template is for `II.A.12.b` operating procedures. The
  `II.A.13.a.b` maintenance form differs only in the activity-record values; a second template is a
  ten-minute change to the build script.

---

## 5. Using it

Grey `[[...]]` text is a placeholder; italic grey text is an instruction to be deleted. **An
unfilled placeholder is visible on paper**, which is deliberate — a blank looks finished, and a
grey `[[tanggal]]` does not.

## 6. Rebuilding it

The `.dotx` is a generated artefact.

```bash
node build-sop-template.js          # writes the .docx
cd pkg && unzip -q ../SOP-Pengoperasian-Template.docx
# flip one content type: ...wordprocessingml.document.main+xml -> ...template.main+xml
zip -Xrq ../SOP-Pengoperasian-Template.dotx .
```

That single content-type declaration is the whole difference between a document and a template — it
is what makes double-clicking create a new file instead of editing the template itself.

**Page size is a single edit.** `PageWidth` and `PageHeight` at the top of the script are the only
numbers to change; every table column is a fraction of the resulting content width, and `Split()`
puts the rounding into the last column so the columns always sum exactly to the table width. A table
whose columns do not sum is one Word silently re-lays out.

**Two things the build script records because they cost an afternoon to find:**

- Every paragraph sets `lineRule: AUTO`. Without it a fixed `line` value is treated as *exact* by
  some renderers, and an inline image is clipped to the height of one line of text — the crest
  appears as a thin sliver.
- The header band avoids vertically merged cells. Renderers disagree about the height of a merged
  cell; a nested table for the metadata lines gives the same appearance and no disagreement.
