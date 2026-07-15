# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single self-contained HTML file, `tutorial-openspec-todolist.html`, that is an
interactive, slide-based tutorial (in **Spanish**) teaching the **OpenSpec**
workflow with Claude Code by building a TodoList app. There is no build step, no
package manager, and no test suite in this repo — the entire tutorial (markup,
CSS, and JS) lives inline in that one file.

Note: `.gitignore` (`node_modules/`, `dist/`, `server/db.sqlite*`) describes the
*student's* TodoList project that the tutorial has them build with Bun + SQLite
(`bun:sqlite`) — not this repo. This repo produces no such artifacts.

## Working with the file

- Open it directly in a browser to preview: `open tutorial-openspec-todolist.html`.
- It has no dependencies to install and nothing to compile. Edits are immediately
  visible on reload.
- Fonts load from Google Fonts via CDN; everything else is inline. Keep it
  self-contained — do not split out separate CSS/JS/asset files.

## Structure of the tutorial (inside the one file)

- **CSS** (`<style>` in `<head>`): design tokens are CSS custom properties on
  `:root` (`--papel`, `--tinta`, `--azul-plano`, etc.). There is a print
  stylesheet (`@media print`) using `data-print-titulo`. Reuse the existing
  tokens and utility classes (e.g. `.bloque-codigo` for code blocks, `.c` for
  code comments) rather than introducing new colors or styles.
- **Content**: each slide is an `<article class="step">` inside `#contenido`.
  Slides are grouped and titled entirely through data attributes:
  `data-grupo` (sidebar section), `data-titulo` (nav + header label), and
  `data-print-titulo` (print header). The nav and progress bar are **generated
  at runtime** from these attributes — there is no separate list of steps to
  keep in sync.
- **JS** (`<script>` at end of `<body>`, one IIFE): reads all `article.step`
  elements, builds `#nav-pasos`, and drives navigation via `ir(i)` (Prev/Next
  buttons, sidebar links, and arrow-key handlers). It updates the progress bar
  and step counter.

### To add or reorder a slide

Insert or move an `<article class="step" data-grupo="…" data-titulo="…"
data-print-titulo="…">` block in document order within `#contenido`. Order in the
DOM is the slide order; the nav, progress, and counters follow automatically. No
JS or index needs editing.

## Content conventions

- All learner-facing prose is in Spanish — match that.
- The tutorial is organized as: **Inicio** (prerequisites, base repo, the
  OpenSpec cycle) → **Módulo 1/2/3** (each repeating the OpenSpec loop:
  propose → read/fix → build → test → archive) → **Final**.
- The workflow it teaches centers on Claude Code `/opsx:*` slash commands and the
  OpenSpec propose→build→archive loop; keep terminology consistent with the
  existing slides when editing.
