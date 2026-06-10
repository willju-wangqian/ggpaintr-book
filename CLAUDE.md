# CLAUDE.md — ggpaintr book

This file is the harness contract for Claude (and other agents) working in this repository. The authoritative process doc is [`dev/plans/book-workflow.md`](dev/plans/book-workflow.md); this file gives the agent the minimum it needs to act safely.

## What this repo is

A Quarto book that documents ggpaintr from the user's perspective: how to use it, how to extend it, no design ideas. Structured after the ggplot2 book; ships to GitHub Pages. **Separate** from the ggpaintr package (`../ggpaintr/` on this machine); depends on it via `DESCRIPTION` Remotes pinned to a SHA or tag.

## Authoritative gate

```sh
Rscript dev/book-gate.R
```

Expected output on a truthful book:

```
Boot:        N/N fixtures booted
Verbatim:    M/M chunks match fixture markers
Symbols:     K ptr_* refs resolve
Screenshots: N/N pair-hashes match
Shinylive:   H/H hero demos compile
BOOK GATE: PASS
```

**Proxy traps — do not substitute for the gate:**

- `quarto render` succeeding. Quarto will happily render stale chunks and stale screenshots.
- `devtools::test()` — this is not an R package; there are no devtools tests here.
- A green CI badge alone, without confirming the CI ran the gate against the *currently pinned* ggpaintr SHA.

When you change anything that touches a fixture, a chunk, prose mentioning a `ptr_*` symbol, or `DESCRIPTION`'s Remotes line, run the gate before declaring done.

## Source-of-truth rules

- Book owns its own fixtures at `tests/fixtures/book-apps/<slug>/app.R`. See [ADR 0001](docs/adr/0001-book-owns-fixtures.md).
- Each `app.R` carries a `>>>` / `<<<` marker block (convention stolen from the package's `helper-vignette-apps.R`). The chunk body in the matching `.qmd` chunk tagged `#| fixture: <slug>` must be byte-identical to the marker block.
- Screenshots live at `images/<slug>.png` with a sidecar `images/<slug>.png.sha` containing the SHA-256 of the fixture's `app.R`. To regenerate after editing a fixture: `Rscript dev/book-shoot.R <slug>`.
- The book repo never edits files in `../ggpaintr/`. Cross-repo work happens as paired PRs (see [`dev/plans/book-workflow.md`](dev/plans/book-workflow.md) § "Cross-repo vignette migration").

## Pin policy

`DESCRIPTION` pins ggpaintr to a specific SHA or tag in `Remotes:`. Floating `main` or `HEAD` references are rejected by the gate (and break the reader's install snippet). To bump the pin: edit `DESCRIPTION`'s Remotes line, update the version banner in `index.qmd`, run the gate, open a PR. See [ADR 0002](docs/adr/0002-hybrid-display.md) and [`dev/plans/book-workflow.md`](dev/plans/book-workflow.md) § "Pin policy & reader-facing version".

## Conventions

- `book-conventions.md` documents chunk-level rules: `#| eval: false` is the default, `#| fixture: <slug>` is how a chunk binds to its fixture, static-output chunks may set `#| eval: true`.
- Tidyverse style in R scripts under `dev/`. Snake_case, 2-space indent.
- Do not hard-wrap prose in `.md` / `.qmd` files. One paragraph = one line; let the editor soft-wrap.
- ADRs are numbered and live under `docs/adr/`. New ADRs only when a decision is hard-to-reverse, surprising without context, and the result of a real trade-off.

## Display modes

- Default: verbatim code chunk + screenshot/GIF (`book-conventions.md` § "The Shiny rendering problem").
- Shinylive heroes are deferred (NO-GO, see `dev/notes/2026-06-10-shinylive-spike.md`): ggpaintr has no wasm distribution channel, so no chapter sets `shinylive: true` and the gate truthfully reports `Shinylive: 0/0`. The would-be heroes (`getting-started.qmd`, `formula-language.qmd`) are authored screenshot-only under [ADR 0002](docs/adr/0002-hybrid-display.md)'s fallback rule; revisit only if ggpaintr ships wasm builds (CRAN or r-universe).

## Out of scope

- Internals / design ideas. The book is purely user-facing. The "Internals" part previously in `_quarto.yml` is deleted; safety content moved to the user-facing "Advanced topics" part. If you find yourself writing about *how* ggpaintr does something internally, the chapter does not belong in this book — it belongs in the package's `dev/` notes.
- Behavioral regression testing of ggpaintr. That lives in the package's own e2e suite. The book gate only verifies boot, prose-fixture correspondence, and symbol existence.

## Pointer documents

- [`dev/plans/book-workflow.md`](dev/plans/book-workflow.md) — full workflow with Success Criteria, Constraints, BDD scenarios, Definition of Done.
- [`docs/adr/0001-book-owns-fixtures.md`](docs/adr/0001-book-owns-fixtures.md) — fixture ownership decision.
- [`docs/adr/0002-hybrid-display.md`](docs/adr/0002-hybrid-display.md) — display-mode decision.
- [`book-conventions.md`](book-conventions.md) — chunk-level authoring rules.
