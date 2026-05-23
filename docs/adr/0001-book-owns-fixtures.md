# ADR 0001 — Book owns its own fixture suite, parallel to the package

- **Status:** Accepted, 2026-05-23
- **Authoritative gate:** `Rscript dev/book-gate.R`

## Context

The ggpaintr package keeps a fixture suite at `tests/testthat/fixtures/vignette-apps/<slug>/app.R`, each verbatim-equivalent to a vignette chunk and exercised by `test-e2e-vignette-examples-shinytest2.R`. The package's `helper-vignette-apps.R` uses a `>>>` marker block convention so a `diff` against the `.Rmd` is reviewable.

The book is a separate repository covering a strict superset of the vignettes: it absorbs `ggpaintr-customization`, `ggpaintr-llm`, `ggpaintr-safety` in full plus expanded use-case / gallery material plus topics that never had a vignette (extension topics, custom render, LLM features). The package's vignettes shrink to minimal `ggpaintr-use-cases` + `ggpaintr-gallery`.

We needed to decide where the canonical, executable form of every book code chunk lives. Three real alternatives were on the table.

## Decision

**The book owns its own fixture suite at `tests/fixtures/book-apps/<slug>/app.R`, mirroring the package's discipline.** Each `.qmd` chunk that depicts a running app tags itself with `#| fixture: <slug>` and is byte-identical to a `>>>` / `<<<` marker block inside the fixture. The book's CI (`Rscript dev/book-gate.R`) boots every fixture, diffs every marker block, and stamps each screenshot with the SHA-256 of its fixture.

Fixtures for content that overlaps with package vignettes (`use-cases`, `gallery`, `customization`) are **copied** from the package to the book during the vignette migration, then maintained in the book. The package keeps only the fixtures backing its surviving minimal vignettes.

## Alternatives considered

- **Package owns canonical app.R; book lifts at build time** (via include shortcode or sync script). Rejected because (a) the package would have to host fixtures for content the user explicitly placed in the book — fixtures for LLM, safety, customization details that no longer exist as vignettes there; (b) every book-only edit would require a package PR; (c) two-way repo dependence is operationally painful.
- **Book owns canonical .qmd; package fixtures mirror the book.** Rejected because the package's existing fixture + e2e infrastructure is already proven; making it downstream of the book demands a syncing tool that doesn't exist and inverts the natural direction (library is upstream of its book).
- **Hybrid (overlap pulled from package, book-only owned locally).** Rejected because maintaining two parallel mechanisms (pull-from-package + own-locally) doubles the surface area and means contributors must know which path applies to a given chapter. A single mechanism with a one-time copy at migration is simpler.

## Consequences

- The book's gate is fully self-contained: it does not read the package's working tree at run time, only its installed/pinned form.
- Temporary duplication of fixtures across repos for the overlap (`use-cases`, `gallery`, `customization` content) until the package's matching fixtures are deleted in the paired vignette-retirement PR.
- Book chapter authors have a single, local mental model: every chunk that depicts an app has a sibling fixture under `tests/fixtures/book-apps/`.
- The package can evolve its fixture suite freely without coordinating with the book; only the pin bump in `DESCRIPTION` couples the two.
