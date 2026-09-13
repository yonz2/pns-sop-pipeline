#!/usr/bin/env python3
"""
validate.py — the eleven deterministic checks of R1b-translation-pipeline.md section 6.

Every check is arithmetic or string comparison. No model is involved: a model must
never be the thing that decides whether its own output is safe (R1b section 4, R3
section 8.1). Any failure holds the document.

Usage:
  validate.py <source.md> <translated.md> [--glossary <glossary.yaml>]

Exit status: 0 if all checks pass, 1 if any check fails (each failure is printed).
"""

import json
import re
import sys
import urllib.parse

import yaml


# --------------------------------------------------------------------------
# Parsing helpers
# --------------------------------------------------------------------------

def split_front_matter(src):
    m = re.match(r"^---\r?\n([\s\S]*?)\r?\n---\r?\n?", src)
    if not m:
        return {}, src
    try:
        front = yaml.safe_load(m.group(1)) or {}
    except Exception:
        front = {}
    return front, src[m.end():]


def headings(text):
    """List of (level, title) in order."""
    return [(len(m.group(1)), m.group(2).strip())
            for m in re.finditer(r"^(#{1,6})\s+(.*)$", text, re.MULTILINE)]


def list_items(text):
    """List of (indent, marker) for bullet/numbered list items, in order."""
    items = []
    for m in re.finditer(r"^(\s*)([-*]|\d+\.)\s+", text, re.MULTILINE):
        items.append((len(m.group(1)), m.group(2)))
    return items


def tables(text):
    """List of (n_rows, n_cols) for each markdown table."""
    out = []
    lines = text.split("\n")
    i = 0
    while i < len(lines):
        if re.match(r"^\s*\|", lines[i]) and i + 1 < len(lines) and re.match(r"^\s*\|[\s:\-|]+\|?\s*$", lines[i + 1]):
            rows = 0
            cols = 0
            while i < len(lines) and re.match(r"^\s*\|", lines[i]):
                cells = [c for c in lines[i].strip().strip("|").split("|")]
                cols = max(cols, len(cells))
                rows += 1
                i += 1
            out.append((rows, cols))
        else:
            i += 1
    return out


def numeric_literals(text):
    """Multiset of numeric literals (integers, decimals, with comma or dot separators)."""
    return sorted(re.findall(r"\d+(?:[.,]\d+)?", text))


def code_blocks(text):
    """List of fenced code/diagram block contents, verbatim."""
    return re.findall(r"```[^\n]*\n([\s\S]*?)```", text)


def urls(text):
    return re.findall(r"https?://[^\s)\]]+", text)


def load_glossary(path):
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    ids = set()
    ens = set()
    for t in data.get("terms", []):
        if t.get("id"):
            ids.add(t["id"])
        if t.get("en") and not str(t["en"]).startswith("[["):
            ens.add(t["en"])
    patterns = [p["pattern"] for p in data.get("protected_patterns", []) if p.get("pattern") and not str(p["pattern"]).startswith("[[")]
    literals = data.get("protected_literals", [])
    return ids, ens, patterns, literals


# --------------------------------------------------------------------------
# The checks
# --------------------------------------------------------------------------

def check_1_headings(src, out):
    a, b = headings(src), headings(out)
    if a != b:
        return "check 1: heading structure differs\n  source: %s\n  output: %s" % (a, b)
    return None


def check_2_list_items(src, out):
    a, b = list_items(src), list_items(out)
    if a != b:
        return "check 2: list item structure differs\n  source: %s\n  output: %s" % (a, b)
    return None


def check_3_tables(src, out):
    a, b = tables(src), tables(out)
    if a != b:
        return "check 3: table structure differs\n  source: %s\n  output: %s" % (a, b)
    return None


def check_4_protected_tokens(src, out, glossary):
    ids, ens, patterns, literals = glossary
    problems = []
    for lit in literals:
        if src.count(lit) != out.count(lit):
            problems.append("literal %r: %d in source, %d in output" % (lit, src.count(lit), out.count(lit)))
    for p in patterns:
        try:
            sa, oa = re.findall(p, src), re.findall(p, out)
        except re.error:
            continue
        if sa != oa:
            problems.append("pattern %r: %s in source, %s in output" % (p, sa, oa))
    for tid in ids:
        if src.count(tid) != out.count(tid):
            problems.append("glossary id %r: %d in source, %d in output" % (tid, src.count(tid), out.count(tid)))
    return ("check 4: protected tokens changed\n  " + "\n  ".join(problems)) if problems else None


def check_5_no_translated_protected(src, out, glossary):
    ids, ens, patterns, literals = glossary
    problems = []
    for e in ens:
        if e in out and e not in src:
            problems.append("English rendering %r appears in output but not source (a field name was translated)" % e)
    return ("check 5: protected term rendered in English\n  " + "\n  ".join(problems)) if problems else None


def check_6_numeric_multiset(src, out):
    a, b = numeric_literals(src), numeric_literals(out)
    if a != b:
        return "check 6: numeric multiset differs\n  source: %s\n  output: %s" % (a, b)
    return None


def check_7_front_matter(src, out):
    sf, _ = split_front_matter(src)
    of, _ = split_front_matter(out)
    problems = []
    for key in ("sop_id", "kode_kegiatan", "angka_kredit", "revisi"):
        if sf.get(key) != of.get(key):
            problems.append("%r: %r in source, %r in output" % (key, sf.get(key), of.get(key)))
    for key in ("tanggal_terbit", "tinjauan_berikutnya"):
        if sf.get(key) != of.get(key):
            problems.append("%r: %r in source, %r in output" % (key, sf.get(key), of.get(key)))
    if of.get("lang") != "en":
        problems.append("lang must be 'en' in a translation")
    if of.get("role") != "translation":
        problems.append("role must be 'translation' in a translation")
    return ("check 7: front matter\n  " + "\n  ".join(problems)) if problems else None


def check_8_urls(src, out):
    a, b = set(urls(src)), set(urls(out))
    if not b.issubset(a):
        return "check 8: URL in output not in source: %s" % (b - a)
    return None


def check_9_length(src, out):
    a, b = len(src), len(out)
    if not (0.7 * a <= b <= 1.6 * a):
        return "check 9: output length %.0f outside 0.7-1.6x of source %.0f" % (b, a)
    return None


def check_10_code_blocks(src, out):
    a, b = code_blocks(src), code_blocks(out)
    if a != b:
        return "check 10: code/diagram blocks differ"
    return None


def check_11_flags(out):
    m = re.search(r"FLAGS\s*:\s*(\[[\s\S]*\])", out)
    if not m:
        return "check 11: FLAGS block missing"
    try:
        json.loads(m.group(1))
    except json.JSONDecodeError as e:
        return "check 11: FLAGS is not valid JSON: %s" % e
    return None


# --------------------------------------------------------------------------

def main():
    if len(sys.argv) < 3:
        sys.stderr.write("usage: validate.py <source.md> <translated.md> [--glossary <glossary.yaml>]\n")
        sys.exit(2)
    src_path, out_path = sys.argv[1], sys.argv[2]
    glossary_path = None
    if "--glossary" in sys.argv:
        glossary_path = sys.argv[sys.argv.index("--glossary") + 1]
    if not glossary_path:
        import os
        glossary_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "glossary.yaml")

    src = open(src_path, "r", encoding="utf-8").read()
    out = open(out_path, "r", encoding="utf-8").read()
    glossary = load_glossary(glossary_path)

    checks = [
        check_1_headings, check_2_list_items, check_3_tables,
        lambda s, o: check_4_protected_tokens(s, o, glossary),
        lambda s, o: check_5_no_translated_protected(s, o, glossary),
        check_6_numeric_multiset, check_7_front_matter, check_8_urls,
        check_9_length, check_10_code_blocks, check_11_flags,
    ]

    failures = []
    for fn in checks:
        if fn.__name__ == "check_11_flags":
            err = fn(out)
        else:
            err = fn(src, out)
        if err:
            failures.append(err)

    if failures:
        print("VALIDATION FAILED — document held:")
        for f in failures:
            print("  - " + f.replace("\n", "\n    "))
        sys.exit(1)
    print("VALIDATION PASSED — all 11 checks OK")


if __name__ == "__main__":
    main()
