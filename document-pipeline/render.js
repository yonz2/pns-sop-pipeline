#!/usr/bin/env node
/*
 * render.js — fills the Rekaman Kegiatan Pengelolaan Laboratorium template
 * with a procedure's Markdown + YAML front matter, and produces .docx and .pdf.
 *
 * The template (templates/build-sop-template.js) IS the form: header band,
 * eleven-row activity record, approval block, section headings. This script
 * reuses those building blocks and injects the procedure's own values and
 * body sections, so the rendered document carries the form exactly — the
 * acceptance test of R1a section 2.
 *
 * Usage:
 *   node render.js <input.md> <output.docx> [--out-dir <dir>]
 *
 * The .pdf is produced by LibreOffice headless from the .docx.
 */

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const YAML = require('yaml');
const T = require('./templates/build-sop-template.js');

// --------------------------------------------------------------------------
// Markdown helpers
// --------------------------------------------------------------------------

// Split a markdown file into { front: <yaml object|null>, body: <string> }.
function parseFrontMatter(src) {
  const m = src.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!m) return { front: null, body: src };
  let front = null;
  try { front = YAML.parse(m[1]); } catch (e) { front = null; }
  return { front, body: src.slice(m[0].length) };
}

// Split the body into sections by "## " headings.
// Returns [{ level, title, lines }] where lines are the raw lines under the heading.
function splitSections(body) {
  const sections = [];
  let cur = null;
  for (const raw of body.split('\n')) {
    const h = raw.match(/^(#{1,6})\s+(.*)$/);
    if (h && h[1].length === 2) {
      cur = { level: 2, title: h[2].trim(), lines: [] };
      sections.push(cur);
    } else if (cur) {
      cur.lines.push(raw);
    }
  }
  return sections;
}

// Render a ```mermaid ... ``` block to a PNG via mermaid-cli, return the path.
//
// The puppeteer config is passed explicitly. mermaid-cli otherwise defaults to
// `headless: "shell"`, which launches `chrome-headless-shell` — a separate
// build from the full Chromium the image installs — and fails with "Could not
// find chrome-headless-shell". The config also adds --no-sandbox, required when
// the browser runs as root inside a container.
function renderMermaid(code, workDir, index) {
  const mmd = path.join(workDir, `_mermaid-${index}.mmd`);
  const png = path.join(workDir, `_mermaid-${index}.png`);
  fs.writeFileSync(mmd, code);
  const args = ['-i', mmd, '-o', png, '-b', 'white'];
  const config = process.env.PUPPETEER_CONFIG_FILE
    || path.join(__dirname, 'puppeteer-config.json');
  if (fs.existsSync(config)) args.push('-p', config);
  execFileSync('mmdc', args, { stdio: 'inherit' });
  return png;
}

// Convert a run of markdown lines into docx paragraphs. Handles:
//   - blockquotes ("> ")
//   - bullet / numbered lists
//   - tables (| ... |)
//   - mermaid fenced blocks (rendered to images)
//   - plain paragraphs with **bold** and *italic* inline
// Returns an array of docx children.
function linesToChildren(lines, workDir, mermaidCounter) {
  const out = [];
  let i = 0;
  const inline = (text) => {
    const runs = [];
    // Recursive inline parser. Handles bold/italic that may contain code spans
    // and nested emphasis (e.g. **`[C]` text with *italic* inside**), and code
    // spans that may contain asterisks. Returns {text, bold, italics, code}.
    function parse(s, bold, italics) {
      const out = [];
      let i = 0;
      while (i < s.length) {
        const c = s[i];
        if (c === '`') {
          const end = s.indexOf('`', i + 1);
          if (end !== -1) {
            out.push({ text: s.slice(i + 1, end), code: true, bold, italics });
            i = end + 1;
            continue;
          }
        }
        if (s.startsWith('**', i)) {
          const end = s.indexOf('**', i + 2);
          if (end !== -1) {
            out.push(...parse(s.slice(i + 2, end), true, italics));
            i = end + 2;
            continue;
          }
        }
        if (c === '*' && s[i + 1] !== '*') {
          const end = s.indexOf('*', i + 1);
          if (end !== -1) {
            out.push(...parse(s.slice(i + 1, end), bold, true));
            i = end + 1;
            continue;
          }
        }
        // accumulate a run of plain text
        let j = i;
        while (j < s.length && s[j] !== '`' && !s.startsWith('**', j) && !(s[j] === '*' && s[j + 1] !== '*')) j++;
        if (j > i) {
          out.push({ text: s.slice(i, j), bold, italics });
          i = j;
        } else {
          out.push({ text: s[i], bold, italics });
          i++;
        }
      }
      return out;
    }
    for (const r of parse(text, false, false)) {
      if (r.code) runs.push(new T.D.TextRun({ text: r.text, font: 'Courier New', size: T.BodySize }));
      else runs.push(T.Text(r.text, { bold: r.bold, italics: r.italics }));
    }
    return runs.length ? runs : [T.Text('')];
  };

  while (i < lines.length) {
    const line = lines[i];

    // sub-heading (### and deeper). Without this branch the hashes print
    // literally, which they did in every management procedure — those carry
    // "### 7.1 The register itself" and similar inside a "## " section.
    const sub = line.match(/^(#{3,6})\s+(.*)$/);
    if (sub) {
      out.push(new T.D.Paragraph({
        children: [T.Text(sub[2].trim(), { bold: true })],
        keepNext: true,
        spacing: { before: 200, after: 60, line: 240, lineRule: T.LineRuleType.AUTO },
      }));
      i++;
      continue;
    }

    // mermaid fenced block
    if (/^```mermaid\s*$/.test(line.trim())) {
      const code = [];
      i++;
      while (i < lines.length && !/^```/.test(lines[i].trim())) { code.push(lines[i]); i++; }
      i++; // closing fence
      const png = renderMermaid(code.join('\n'), workDir, mermaidCounter.n++);
      out.push(new T.D.Paragraph({
        alignment: T.AlignmentType.CENTER,
        spacing: { before: 120, after: 120, line: 240, lineRule: T.LineRuleType.AUTO },
        children: [new T.D.ImageRun({
          type: 'png', data: fs.readFileSync(png),
          transformation: { width: 500, height: 300 },
        })],
      }));
      continue;
    }

    // table
    if (/^\|/.test(line) && /^\|[\s:-]+\|/.test(lines[i + 1] || '')) {
      const cut = (l) => l.trim().replace(/^\||\|$/g, '').split('|').map((s) => s.trim());
      const rows = [cut(line)];
      i += 2;
      while (i < lines.length && /^\|/.test(lines[i])) { rows.push(cut(lines[i])); i++; }
      const nCols = rows[0].length;
      // Column widths proportional to the longest cell in each column, not an
      // equal split. An equal split turns a nine-column register into columns
      // four characters wide, which breaks every word and is unreadable on
      // paper. Each column is guaranteed a floor of half its equal share so a
      // short column never collapses.
      const longest = rows[0].map((_, j) =>
        Math.max(...rows.map((r) => (r[j] || '').replace(/[*`_]/g, '').length), 1));
      const floor = (T.ContentWidth / nCols) * 0.5;
      const spare = T.ContentWidth - floor * nCols;
      const totalLen = longest.reduce((a, b) => a + b, 0);
      const widths = longest.map((len) => Math.round(floor + (spare * len) / totalLen));
      out.push(new T.D.Table({
        width: { size: T.ContentWidth, type: T.D.WidthType.DXA },
        columnWidths: widths,
        rows: rows.map((cells, r) => new T.D.TableRow({
          tableHeader: r === 0,
          cantSplit: true,
          children: cells.map((c, j) => new T.D.TableCell({
            width: { size: widths[j] || widths[0], type: T.D.WidthType.DXA },
            margins: { top: 40, bottom: 40, left: 90, right: 90 },
            children: [new T.D.Paragraph({ children: inline(c) })],
          })),
        })),
      }));
      out.push(new T.D.Paragraph({ children: [T.Text('')] }));
      continue;
    }

    // blockquote
    if (/^>\s?/.test(line)) {
      const block = [];
      while (i < lines.length && /^>\s?/.test(lines[i])) { block.push(lines[i].replace(/^>\s?/, '')); i++; }
      const text = block.join(' ').trim();
      if (text) {
        out.push(new T.D.Paragraph({
          indent: { left: 400 },
          spacing: { before: 60, after: 60, line: 240, lineRule: T.LineRuleType.AUTO },
          border: { left: { style: T.D.BorderStyle.SINGLE, size: 12, color: '888888', space: 12 } },
          children: inline(text),
        }));
      }
      continue;
    }

    // bullet / numbered list
    if (/^(\s*)([-*]|\d+\.)\s+/.test(line)) {
      const items = [];
      while (i < lines.length && /^(\s*)([-*]|\d+\.)\s+/.test(lines[i])) {
        let t = lines[i].replace(/^(\s*)([-*]|\d+\.)\s+/, '');
        i++;
        // join indented continuation lines (a code span may cross a soft line break)
        while (i < lines.length && /^\s{2,}\S/.test(lines[i]) && !/^(\s*)([-*]|\d+\.)\s/.test(lines[i])) {
          t += ' ' + lines[i].trim();
          i++;
        }
        items.push(t);
      }
      const isNum = /^\d+\./.test(line);
      items.forEach((t) => {
        out.push(new T.D.Paragraph({
          numbering: { reference: isNum ? 'numlist' : 'bullets', level: 0 },
          spacing: { before: 40, after: 40, line: 240, lineRule: T.LineRuleType.AUTO },
          children: inline(t),
        }));
      });
      continue;
    }

    // thematic rule (---)
    if (/^\s*---\s*$/.test(line)) {
      out.push(new T.D.Paragraph({
        spacing: { before: 160, after: 160, line: 240, lineRule: T.LineRuleType.AUTO },
        border: { bottom: { style: T.D.BorderStyle.SINGLE, size: 4, color: 'BBBBBB', space: 1 } },
        children: [T.Text('')],
      }));
      i++;
      continue;
    }

    // Correction rule — a code span of underscores (the "Correction:" line).
    // Rendered as a bordered empty paragraph, not a monospace run that wraps
    // into two mismatched lines.
    if (/^`_+`\s*$/.test(line.trim())) {
      out.push(new T.D.Paragraph({
        spacing: { before: 60, after: 60, line: 240, lineRule: T.LineRuleType.AUTO },
        border: { bottom: { style: T.D.BorderStyle.SINGLE, size: 4, color: 'BBBBBB', space: 1 } },
        children: [T.Text('')],
      }));
      i++;
      continue;
    }

    // blank line
    if (/^\s*$/.test(line)) { i++; continue; }

    // plain paragraph (may span until a blank line)
    const buf = [line];
    i++;
    while (i < lines.length && !/^\s*$/.test(lines[i]) && !/^#{1,6}\s/.test(lines[i])
           && !/^```/.test(lines[i].trim()) && !/^\|/.test(lines[i])
           && !/^(\s*)([-*]|\d+\.)\s+/.test(lines[i]) && !/^>\s?/.test(lines[i])
           && !/^`_+`\s*$/.test(lines[i].trim())) {
      buf.push(lines[i]); i++;
    }
    const text = buf.join(' ').trim();
    if (text) out.push(new T.D.Paragraph({ spacing: { before: 60, after: 120, line: 240, lineRule: T.LineRuleType.AUTO }, children: inline(text) }));
  }
  return out;
}

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------
function main() {
  const args = process.argv.slice(2);
  const input = args[0];
  const outDocx = args[1];
  if (!input || !outDocx) {
    console.error('usage: node render.js <input.md> <output.docx>');
    process.exit(2);
  }

  const src = fs.readFileSync(input, 'utf8');
  const { front, body } = parseFrontMatter(src);
  const sections = splitSections(body);
  const workDir = fs.mkdtempSync(path.join('/tmp', 'docpipe-'));

  // Map front-matter keys to activity-record values.
  const rec = {
    kode_kegiatan: front && front.kode_kegiatan,
    waktu_pelaksanaan: front && front.waktu_pelaksanaan,
    angka_kredit_acuan: front && front.angka_kredit,
    volume_kegiatan: front && front.volume_kegiatan,
    angka_kredit_dihitung: front && front.angka_kredit_dihitung,
    nama_kegiatan: (String((front && front.kelas) || 'peralatan').toLowerCase().startsWith('manaj'))
      ? '[[PNS: Nama Kegiatan untuk prosedur pengelolaan laboratorium]]'
      : undefined,
    nama_laboratorium: front && front.laboratorium,
    nama_plp: front && front.nama_plp,
    jumlah_plp_terlibat: front && front.jumlah_plp_terlibat,
  };

  // Header band values. Edisi/Revisi comes from the front matter (revisi: 0),
  // so it prints "0" rather than the template's placeholder.
  const headerValues = {
    no_formulir: front && front.no_formulir,
    edisi_revisi: front && front.revisi,
    tgl_berlaku: front && front.tanggal_terbit,
  };

  // Which family this procedure belongs to. See the title block below.
  const kelasEarly = String((front && front.kelas) || 'peralatan').toLowerCase();
  const managementFamily = kelasEarly.startsWith('manaj');
  if (managementFamily) {
    headerValues.form_subtitle = 'SOP PENGELOLAAN LABORATORIUM';
  }

  const mermaidCounter = { n: 0 };
  const bodyChildren = [];

  // Title block.
  //
  // The template is the OPERATING form (II.A.12.b, "Menyusun SOP
  // Pengoperasian Peralatan"). A management procedure is not an operating
  // procedure, so printing "SOP PENGOPERASIAN ALAT" above LAB-000 states
  // something untrue on the face of the document. The family comes from the
  // front-matter `kelas` key; see templates/README.md section 4, which records
  // this as the open follow-up it is.
  //
  // `[A]` "SOP PENGELOLAAN LABORATORIUM" is assembled from the department's
  // own words — it is the value of the Unsur row in their own form — and is
  // NOT an invented term of art. It still needs confirming: glossary
  // open_questions item 3.
  const kelas = (front && front.kelas) || 'peralatan';
  const isManagement = String(kelas).toLowerCase().startsWith('manaj');
  const formTitle = isManagement ? 'SOP PENGELOLAAN LABORATORIUM' : 'SOP PENGOPERASIAN ALAT';

  const title = (front && front.title) || path.basename(input, '.md');
  bodyChildren.push(new T.D.Paragraph({
    children: [T.Text(formTitle, { bold: true, size: T.TitleSize })],
    alignment: T.AlignmentType.CENTER, spacing: { before: 300, after: 0, line: 240, lineRule: T.LineRuleType.AUTO },
  }));
  bodyChildren.push(new T.D.Paragraph({
    children: [T.Text(title, { bold: true, size: T.TitleSize })],
    alignment: T.AlignmentType.CENTER, spacing: { after: 240, line: 240, lineRule: T.LineRuleType.AUTO },
  }));

  // Body sections. The markdown headings already carry their own numbers
  // ("## 1. Tujuan / Purpose"), so strip a leading "N. " and let SectionHeading
  // renumber consistently.
  let sectionNo = 1;
  for (const s of sections) {
    const title = s.title.replace(/^\d+\.\s*/, '');
    bodyChildren.push(T.SectionHeading(sectionNo, title));
    bodyChildren.push(...linesToChildren(s.lines, workDir, mermaidCounter));
    sectionNo++;
  }

  // Document control block (the one addition, R1 section 4)
  bodyChildren.push(new T.D.Paragraph({
    children: [T.Text('Pengendalian Dokumen', { bold: true })],
    keepNext: true, spacing: { before: 320, after: 60, line: 240, lineRule: T.LineRuleType.AUTO },
  }));
  bodyChildren.push(T.DocumentControl);

  // Approval block
  bodyChildren.push(new T.D.Paragraph({ children: [], spacing: { before: 320, after: 0 } }));
  bodyChildren.push(T.ApprovalBlock);

  // Document default language, from the front matter (id or en). The template
  // defaults to Indonesian; a translation (lang: en) is set to English.
  const lang = (front && front.lang) || 'id';
  const langValue = lang === 'en' ? 'en-GB' : 'id-ID';

  const doc = new T.D.Document({
    creator: 'Politeknik Negeri Semarang',
    title: title,
    styles: {
      default: {
        document: { run: { font: T.Font, size: T.BodySize, language: { value: langValue } }, paragraph: { spacing: { after: 0, line: 240, lineRule: T.LineRuleType.AUTO } } },
      },
    },
    numbering: {
      config: [
        { reference: 'bullets', levels: [{ level: 0, format: T.D.LevelFormat.BULLET, text: '•',
          style: { paragraph: { indent: { left: 440, hanging: 240 } } } }] },
        { reference: 'numlist', levels: [{ level: 0, format: T.D.LevelFormat.DECIMAL, text: '%1.',
          style: { paragraph: { indent: { left: 440, hanging: 240 } } } }] },
      ],
    },
    sections: [{
      properties: {
        page: {
          size: { width: T.PageWidth, height: T.PageHeight },
          margin: { top: T.MarginTop, right: T.MarginRight, bottom: T.MarginBottom, left: T.MarginLeft, header: T.HeaderDistance },
        },
      },
      headers: { default: new T.D.Header({ children: [T.buildHeaderBand(headerValues), T.Blank()] }) },
      children: [
        T.buildActivityRecord(rec),
        ...bodyChildren,
      ],
    }],
  });

  T.D.Packer.toBuffer(doc).then((buf) => {
    fs.writeFileSync(outDocx, buf);
    console.log('written', outDocx, buf.length, 'bytes');

    // PDF via LibreOffice headless
    const outPdf = outDocx.replace(/\.docx$/i, '.pdf');
    execFileSync('soffice', ['--headless', '--convert-to', 'pdf', '--outdir', path.dirname(outDocx), outDocx], { stdio: 'inherit' });
    console.log('written', outPdf);
  });
}

main();
