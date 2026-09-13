/*
 * Builds the Polines laboratory SOP template.
 *
 * Derived from the six "II.A.12.b Menyusun SOP Pengoperasian" documents supplied by
 * Kuwat Santoso on 26 August 2026. Page setup, fonts, the header band, the activity
 * record and the approval block reproduce those documents; the one addition is the
 * document-control block, which is the management layer proposed in R1.
 */

const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, ImageRun, Table, TableRow, TableCell,
  WidthType, AlignmentType, VerticalAlign, VerticalMergeType, BorderStyle,
  HeadingLevel, TabStopType, PageNumber, Header, LineRuleType, LevelFormat,
} = require('docx');

// Resolve the crest relative to this file, so the script works both when run
// directly (from templates/) and when required by render.js (from document-pipeline/).
const LOGO = path.join(__dirname, 'logo-rgba.png');

// --------------------------------------------------------------------------
// Page geometry, read off the source documents
// --------------------------------------------------------------------------
// A4, 21.0 x 29.7 cm, margins 2.0 cm all round: Tata Naskah Dinas, the
// standard for Indonesian institutional documents.
//
// The source corpus does not follow it — it is mixed at 21.59 x 35.56, A4 and
// 21.59 x 27.94, with margins from 1.90 to 3.17 cm. This template applies the
// standard rather than carrying the inconsistency forward. See README section 2.
const PageWidth = 11906;          // 21.0 cm
const PageHeight = 16838;         // 29.7 cm
const MarginLeft = 1134;          // 2.0 cm
const MarginRight = 1134;         // 2.0 cm
const MarginTop = 1134;           // 2.0 cm
const MarginBottom = 1134;        // 2.0 cm
const HeaderDistance = 425;       // 0.75 cm, as in the source documents. The band is
                                  // taller than the top margin, so the body starts below
                                  // it — which is how the originals behave too.
const ContentWidth = PageWidth - MarginLeft - MarginRight;   // 9026

// Every table width below is a fraction of ContentWidth, never a fixed number,
// so that changing the page size above is the only edit a page-size change needs.
// Split() distributes rounding into the last column so the columns always sum
// exactly to the table width — a table whose columns do not sum is a table Word
// silently re-lays out.
const Split = (...fractions) => {
  const cols = fractions.slice(0, -1).map((f) => Math.round(ContentWidth * f));
  return [...cols, ContentWidth - cols.reduce((a, b) => a + b, 0)];
};

// Tata Naskah Dinas specifies Arial for administrative documents (Bookman Old
// Style is reserved for regulatory decrees). The existing SOP corpus uses Times
// New Roman 12 pt — see README section 2, judgement 2.
const Font = 'Arial';
const BodySize = 24;              // 12 pt, in half-points
const SmallSize = 20;             // 10 pt
const TitleSize = 28;             // 14 pt

const ThinBorder = { style: BorderStyle.SINGLE, size: 6, color: '000000' };
const AllBorders = {
  top: ThinBorder, bottom: ThinBorder, left: ThinBorder, right: ThinBorder,
  insideHorizontal: ThinBorder, insideVertical: ThinBorder,
};
const NoBorders = {
  top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE },
  left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE },
  insideHorizontal: { style: BorderStyle.NONE }, insideVertical: { style: BorderStyle.NONE },
};

// --------------------------------------------------------------------------
// Small helpers
// --------------------------------------------------------------------------
const Text = (text, opts = {}) => new TextRun({ text, font: Font, size: opts.size || BodySize, bold: !!opts.bold, italics: !!opts.italics, color: opts.color });

const Para = (runs, opts = {}) => new Paragraph({
  children: Array.isArray(runs) ? runs : [runs],
  alignment: opts.align,
  keepNext: !!opts.keepNext,
  spacing: opts.spacing || { after: 0, line: 240, lineRule: LineRuleType.AUTO },
  indent: opts.indent,
  tabStops: opts.tabStops,
  numbering: opts.numbering,
});

// A placeholder the author replaces. Grey, so an unfilled one is visible on paper.
const Fill = (hint) => new TextRun({ text: `[[${hint}]]`, font: Font, size: BodySize, color: '808080' });

// A grey text run, for values that are still placeholders (e.g. a front-matter
// value that is itself a [[PNS: ...]] blank). Same colour as Fill, so an unfilled
// field reads as a placeholder rather than as content.
const Grey = (text) => new TextRun({ text, font: Font, size: BodySize, color: '808080' });

// An editorial instruction, deleted when the document is finished.
const Note = (text) => new Paragraph({
  children: [new TextRun({ text, font: Font, size: SmallSize, italics: true, color: '808080' })],
  spacing: { before: 40, after: 120, line: 240, lineRule: LineRuleType.AUTO },
});

const Cell = (children, opts = {}) => new TableCell({
  children,
  width: { size: opts.width, type: WidthType.DXA },
  columnSpan: opts.span,
  verticalMerge: opts.merge,
  verticalAlign: opts.vAlign || VerticalAlign.CENTER,
  margins: { top: 40, bottom: 40, left: 90, right: 90 },
});

const Blank = () => new Paragraph({ children: [], spacing: { after: 0, line: 240, lineRule: LineRuleType.AUTO } });

// --------------------------------------------------------------------------
// The header band — repeated on every page
// --------------------------------------------------------------------------
const [HeadLogo, HeadTitle, HeadMeta] = Split(2100 / 9360, 3540 / 9360, 3720 / 9360);

// The metadata lines are a nested 4 x 1 table rather than four rows of the outer
// table with a vertically merged logo cell. Same appearance, and it does not depend
// on vertical-merge height calculation, which renderers disagree about.
const MetaLine = (label, valueRuns) => new TableRow({ children: [
  new TableCell({
    width: { size: HeadMeta, type: WidthType.DXA },
    margins: { top: 30, bottom: 30, left: 90, right: 90 },
    verticalAlign: VerticalAlign.CENTER,
    children: [new Paragraph({
      children: [
        Text(label, { bold: true, size: SmallSize }),
        new TextRun({ text: '\t', font: Font }),
        Text(': ', { size: SmallSize }),
        ...valueRuns,
      ],
      tabStops: [{ type: TabStopType.LEFT, position: Math.round(HeadMeta * 0.38) }],
      spacing: { after: 0, line: 240, lineRule: LineRuleType.AUTO },
    })],
  }),
]});

// values: { no_formulir, edisi_revisi, tgl_berlaku }
// A value that is present is printed as text; one that is absent is a grey
// [[...]] placeholder, so an unfilled field is visible on paper.
const buildMetaTable = (values = {}) => new Table({
  width: { size: HeadMeta, type: WidthType.DXA },
  columnWidths: [HeadMeta],
  borders: {
    top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE },
    left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE },
    insideHorizontal: ThinBorder, insideVertical: { style: BorderStyle.NONE },
  },
  rows: [
    MetaLine('No. Formulir', [values.no_formulir ? Text(String(values.no_formulir), { size: SmallSize }) : Fill('No. Formulir')]),
    MetaLine('Edisi/Revisi', [values.edisi_revisi != null ? Text(String(values.edisi_revisi), { size: SmallSize }) : Fill('0')]),
    MetaLine('Tgl berlaku', [values.tgl_berlaku ? Text(String(values.tgl_berlaku), { size: SmallSize }) : Fill('tanggal')]),
    MetaLine('Halaman', [
      new TextRun({ children: [PageNumber.CURRENT], font: Font, size: SmallSize }),
      Text(' dari ', { size: SmallSize }),
      new TextRun({ children: [PageNumber.TOTAL_PAGES], font: Font, size: SmallSize }),
    ]),
  ],
});

const buildHeaderBand = (values = {}) => new Table({
  width: { size: ContentWidth, type: WidthType.DXA },
  columnWidths: [HeadLogo, HeadTitle, HeadMeta],
  borders: AllBorders,
  rows: [
    new TableRow({ children: [
      Cell([new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 0 },
        children: [new ImageRun({
          type: 'png',
          data: fs.readFileSync(LOGO),
          transformation: { width: 84, height: 84 },   // px at 96 dpi ~ 2.2 cm
        })],
      })], { width: HeadLogo }),
      Cell([
        Para(Text('REKAMAN KEGIATAN', { bold: true }), { align: AlignmentType.CENTER }),
        Para(Text('PENGELOLAAN', { bold: true }), { align: AlignmentType.CENTER }),
        Para(Text('LABORATORIUM', { bold: true }), { align: AlignmentType.CENTER }),
      ], { width: HeadTitle }),
      new TableCell({
        width: { size: HeadMeta, type: WidthType.DXA },
        margins: { top: 0, bottom: 0, left: 0, right: 0 },
        verticalAlign: VerticalAlign.CENTER,
        children: [buildMetaTable(values), Blank()],
      }),
    ]}),
    new TableRow({ children: [
      Cell([Para(Text(values.form_subtitle || 'SOP PENGOPERASIAN PERALATAN KATEGORI 2',
        { bold: true, size: SmallSize }), { align: AlignmentType.CENTER })],
        { width: ContentWidth, span: 3 }),
    ]}),
  ],
});

const HeaderBand = buildHeaderBand();

// --------------------------------------------------------------------------
// The activity record — the angka kredit form. Reproduced exactly.
// --------------------------------------------------------------------------
const [RecLabel, RecValue] = Split(3000 / 9360, 6360 / 9360);

// A value for a form cell. Numbers are printed with the Indonesian decimal comma
// (0.32 -> "0,32", [C] identical in all six source documents). A string that is
// itself a [[PNS: ...]] placeholder is printed grey, like the template's own
// unfilled fields, so it reads as a blank rather than as content.
const cellValue = (value, fallback) => {
  if (value === undefined || value === null || value === '') return Fill(fallback);
  if (typeof value === 'number') return Text(String(value).replace('.', ','));
  const s = String(value);
  if (/^\[\[.*\]\]$/.test(s.trim())) return Grey(s);
  return Text(s);
};

const RecordRow = (label, value, prefilled) => new TableRow({ children: [
  Cell([Para(Text(label, { bold: true }))], { width: RecLabel, vAlign: VerticalAlign.TOP }),
  Cell([Para(prefilled ? Text(value) : cellValue(value, label))], { width: RecValue, vAlign: VerticalAlign.TOP }),
]});

// values: { kode_kegiatan, waktu_pelaksanaan, angka_kredit_acuan, volume_kegiatan,
//           angka_kredit_dihitung, nama_laboratorium, nama_plp, jumlah_plp_terlibat }
// A value that is present is printed as text; one that is absent is a grey [[...]]
// placeholder, so an unfilled field is visible on paper.
const buildActivityRecord = (values = {}) => new Table({
  width: { size: ContentWidth, type: WidthType.DXA },
  columnWidths: [RecLabel, RecValue],
  borders: AllBorders,
  rows: [
    RecordRow('Unsur', 'Pengelolaan Laboratorium', true),
    RecordRow('Jenis Kegiatan', 'Perancangan kegiatan Laboratorium', true),
    // "Menyusun SOP Pengoperasian Peralatan" is the OPERATING activity and is
    // wrong on a management procedure. values.nama_kegiatan carries the family's
    // own wording; for the management family it is a visible [[PNS: ...]] blank,
    // because the correct Nama Kegiatan is a PLP term of art and an outsider
    // must not invent it. glossary open_questions item 3.
    RecordRow('Nama kegiatan', values.nama_kegiatan || 'Menyusun SOP Pengoperasian Peralatan',
      !(values.nama_kegiatan && /^\[\[.*\]\]$/.test(String(values.nama_kegiatan).trim()))),
    RecordRow('Kode Butir Kegiatan', values.kode_kegiatan, false),
    RecordRow('Waktu Pelaksanaan', values.waktu_pelaksanaan, false),
    RecordRow('Angka Kredit Acuan', values.angka_kredit_acuan, false),
    RecordRow('Volume Kegiatan', values.volume_kegiatan, false),
    RecordRow('Angka Kredit Dihitung', values.angka_kredit_dihitung, false),
    RecordRow('Nama Laboratorium', values.nama_laboratorium, false),
    RecordRow('Nama PLP', values.nama_plp, false),
    RecordRow('Jumlah PLP Terlibat', values.jumlah_plp_terlibat, false),
  ],
});

// --------------------------------------------------------------------------
// Document control — the one addition to the form (R1 §4)
// --------------------------------------------------------------------------
const [CtlLabel, CtlValue] = Split(3000 / 9360, 6360 / 9360);

const ControlRow = (label, hint) => new TableRow({ children: [
  Cell([Para(Text(label, { bold: true }))], { width: CtlLabel, vAlign: VerticalAlign.TOP }),
  Cell([Para(Fill(hint))], { width: CtlValue, vAlign: VerticalAlign.TOP }),
]});

const DocumentControl = new Table({
  width: { size: ContentWidth, type: WidthType.DXA },
  columnWidths: [CtlLabel, CtlValue],
  borders: AllBorders,
  rows: [
    ControlRow('Pemilik dokumen', 'jabatan pemilik — sebuah jabatan, bukan nama orang'),
    ControlRow('Tinjauan berikutnya', 'tanggal tinjauan berikutnya'),
    ControlRow('Rekaman yang dihasilkan', 'rekaman apa yang dihasilkan prosedur ini, disimpan oleh siapa, di mana, berapa lama'),
  ],
});

// --------------------------------------------------------------------------
// The step table used in section 5
// --------------------------------------------------------------------------
const [StepNo, StepWork, StepExpl] = Split(800 / 9360, 4600 / 9360, 3960 / 9360);

const StepRow = (n) => new TableRow({ cantSplit: true, children: [
  Cell([Para(Text(String(n)), { align: AlignmentType.CENTER })], { width: StepNo, vAlign: VerticalAlign.TOP }),
  Cell([Para(Fill('langkah kerja'))], { width: StepWork, vAlign: VerticalAlign.TOP }),
  Cell([Para(Fill('penjelasan / gambar'))], { width: StepExpl, vAlign: VerticalAlign.TOP }),
]});

const StepTable = new Table({
  width: { size: ContentWidth, type: WidthType.DXA },
  columnWidths: [StepNo, StepWork, StepExpl],
  borders: AllBorders,
  rows: [
    new TableRow({
      tableHeader: true,
      children: [
        Cell([Para(Text('No', { bold: true }), { align: AlignmentType.CENTER })], { width: StepNo }),
        Cell([Para(Text('Langkah Kerja', { bold: true }), { align: AlignmentType.CENTER })], { width: StepWork }),
        Cell([Para(Text('Penjelasan', { bold: true }), { align: AlignmentType.CENTER })], { width: StepExpl }),
      ],
    }),
    StepRow(1), StepRow(2), StepRow(3),
  ],
});

// --------------------------------------------------------------------------
// The approval block
// --------------------------------------------------------------------------
const [AppColA, AppColB, AppColC] = Split(1 / 3, 1 / 3, 1 / 3);

const ApprovalCell = (role, position, width) => Cell([
  Para(Text(role, { bold: true })),
  Para(Text(position)),
  new Paragraph({ children: [Text('Tanggal : '), Fill('tanggal')], spacing: { after: 0, line: 240, lineRule: LineRuleType.AUTO } }),
  Blank(), Blank(), Blank(),
  Para(Fill('nama, gelar'), { align: AlignmentType.CENTER }),
  Para(Fill('NIP'), { align: AlignmentType.CENTER }),
], { width, vAlign: VerticalAlign.TOP });

const ApprovalBlock = new Table({
  width: { size: ContentWidth, type: WidthType.DXA },
  columnWidths: [AppColA, AppColB, AppColC],
  borders: AllBorders,
  rows: [
    new TableRow({ children: [
      Cell([Para(Text('Verifikasi', { bold: true }), { keepNext: true })], { width: ContentWidth, span: 3, vAlign: VerticalAlign.TOP }),
    ], cantSplit: true}),
    new TableRow({ cantSplit: true, children: [
      ApprovalCell('Verifikator', 'Ahli Muda', AppColA),
      ApprovalCell('Disahkan Oleh', 'Ka. Lab Laboratorium', AppColB),
      ApprovalCell('Dibuat Oleh', 'PLP Pertama', AppColC),
    ]}),
  ],
});

// --------------------------------------------------------------------------
// Body sections
// --------------------------------------------------------------------------
const SectionHeading = (n, title) => new Paragraph({
  children: [Text(`${n}. ${title}`, { bold: true })],
  keepNext: true,
  spacing: { before: 200, after: 60, line: 240, lineRule: LineRuleType.AUTO },
});

const Body = [
  // The angka kredit form, first — as in every source document
  buildActivityRecord(),

  // Title block
  new Paragraph({ children: [Text('SOP PENGOPERASIAN ALAT', { bold: true, size: TitleSize })],
    alignment: AlignmentType.CENTER, spacing: { before: 300, after: 0, line: 240, lineRule: LineRuleType.AUTO } }),
  new Paragraph({ children: [new TextRun({ text: '[[NAMA PERALATAN]]', font: Font, size: TitleSize, bold: true, color: '808080' })],
    alignment: AlignmentType.CENTER, spacing: { after: 240, line: 240, lineRule: LineRuleType.AUTO } }),

  SectionHeading(1, 'Tujuan'),
  Para(Fill('apa yang dijamin prosedur ini — satu kalimat')),
  Note('Satu kalimat. Apa yang dijamin prosedur ini, bukan apa isinya.'),

  SectionHeading(2, 'Ruang Lingkup'),
  Para(Fill('peralatan mana, ruang mana, siapa yang menggunakannya')),
  Note('Sebutkan juga apa yang TIDAK termasuk, bila itu bisa disalahpahami.'),

  SectionHeading(3, 'Referensi / Rujukan'),
  Para(Fill('manual peralatan, SOP terkait, standar institusi')),

  SectionHeading(4, 'Prinsip Kerja'),
  Para(Fill('cara kerja peralatan, secukupnya agar langkah di bawah dapat dipahami')),
  Note('Secukupnya untuk memahami langkah-langkahnya — bukan bab teori.'),

  SectionHeading(5, 'Cara Pengoperasian'),
  Note('Gunakan tabel langkah di bawah, atau diagram alir bila prosedurnya memiliki percabangan Ya/Tidak. Kedua bentuk dipakai di laboratorium ini.'),
  StepTable,

  new Paragraph({ children: [Text('Pengendalian Dokumen', { bold: true })], keepNext: true, spacing: { before: 320, after: 60, line: 240, lineRule: LineRuleType.AUTO } }),
  Note('Tiga baris berikut adalah satu-satunya tambahan pada formulir yang sudah berjalan: pemilik, tanggal tinjauan, dan rekaman yang dihasilkan. Lihat R1 §4.'),
  DocumentControl,

  new Paragraph({ children: [], spacing: { before: 320, after: 0 } }),
  ApprovalBlock,
];

// --------------------------------------------------------------------------
// Assemble
// --------------------------------------------------------------------------
const doc = new Document({
  creator: 'Politeknik Negeri Semarang',
  title: 'SOP Pengoperasian Peralatan — template',
  description: 'Template SOP pengoperasian peralatan laboratorium, formulir Rekaman Kegiatan Pengelolaan Laboratorium',
  styles: {
    default: {
      document: { run: { font: Font, size: BodySize, language: { value: 'id-ID' } }, paragraph: { spacing: { after: 0, line: 240, lineRule: LineRuleType.AUTO } } },
    },
  },
  sections: [{
    properties: {
      page: {
        size: { width: PageWidth, height: PageHeight },
        margin: { top: MarginTop, right: MarginRight, bottom: MarginBottom, left: MarginLeft, header: HeaderDistance },
      },
    },
    headers: { default: new Header({ children: [HeaderBand, Blank()] }) },
    children: Body,
  }],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync('SOP-Pengoperasian-Template.docx', buf);
  console.log('written: SOP-Pengoperasian-Template.docx', buf.length, 'bytes');
});

// --------------------------------------------------------------------------
// Exports for the renderer (render.js). The renderer fills the same form with
// a procedure's own values and body sections, so it reuses these building
// blocks rather than re-deriving the form.
// --------------------------------------------------------------------------
module.exports = {
  // geometry / style
  PageWidth, PageHeight, MarginLeft, MarginRight, MarginTop, MarginBottom,
  HeaderDistance, ContentWidth, Font, BodySize, SmallSize, TitleSize,
  // primitives
  Text, Para, Fill, Grey, Note, Cell, Blank, SectionHeading,
  // form blocks
  HeaderBand, buildHeaderBand, buildMetaTable, buildActivityRecord, DocumentControl, StepTable, ApprovalBlock,
  // assembly
  Document, Packer, Header, AlignmentType, PageNumber, LineRuleType,
  // docx classes, exposed as a namespace for the renderer
  D: { Document, Packer, Header, AlignmentType, PageNumber, LineRuleType,
       Paragraph, TextRun, ImageRun, Table, TableRow, TableCell,
       WidthType, BorderStyle, LevelFormat },
};
