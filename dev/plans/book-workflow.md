# Book authoring workflow

> Status: **LOCKED 2026-05-23** (grill-with-docs). Encodes the nine decisions from the 2026-05-23 grilling session. Supersedes the looser commitments in `book-conventions.md` (which now defers to this doc for the gate definition + chunk-binding convention).

## Goal

Guarantee that every code chunk, screenshot, and prose claim in the rendered book truthfully represents what the pinned ggpaintr actually delivers — without manual eyeballing of the TOC at every release.

## Success Criteria

1. The authoritative command `Rscript dev/book-gate.R` exits 0 with the line `BOOK GATE: PASS` iff *every* chunk-fixture pair in the book holds the five gate properties (boot, verbatim, symbol, screenshot pair-hash, shinylive).
2. Every chunk marked `#| fixture: <slug>` is byte-identical to the `>>>` / `<<<` marker block inside `tests/fixtures/book-apps/<slug>/app.R`.
3. Every `ptr_*` token in book prose or chunks resolves to a symbol exported by the pinned ggpaintr's NAMESPACE.
4. Every `images/<slug>.png` carries a sidecar `images/<slug>.png.sha` whose contents equal the SHA-256 of its fixture's `app.R`; a fixture edit without `Rscript dev/book-shoot.R <slug>` causes the gate to fail.
5. The book's `DESCRIPTION` Remotes line names a specific ggpaintr SHA or tag; floating `main` references are rejected by the gate.
6. CI runs `Rscript dev/book-gate.R` on every push and every PR; merging to `main` requires a green run.

## Constraints

- **No package-side coupling required.** The book repo does not modify or read from the ggpaintr package repo's working tree at gate time. It depends only on the pinned ggpaintr being installable.
- **No behavioral e2e assertions.** Boot is the only runtime check. A behavioral regression where ggpaintr silently changes semantics under an unchanged call shape is **not** caught; this is acknowledged.
- **No pixel-level image diff.** Pair-hash is the only screenshot-staleness check.
- **Book is downstream.** A vignette in the package must be e2e-green + drift-audit clean before the book absorbs it.
- **Cross-repo cutover is paired.** Removing a vignette from the package and absorbing it into the book happen as paired PRs in the same logical change; never a window where neither has the content.

## The nine locked decisions

| # | Decision | Locked value | Source |
|---|---|---|---|
| 1 | Truth source | Book owns its own fixture suite at `tests/fixtures/book-apps/<slug>/app.R` | [ADR 0001](../../docs/adr/0001-book-owns-fixtures.md) |
| 2 | Display mode | Hybrid: shinylive on 1-2 hero demos, screenshots elsewhere | [ADR 0002](../../docs/adr/0002-hybrid-display.md) |
| 3 | Gate | Boot + Verbatim + Symbol existence + Screenshot pair-hash + Shinylive | This doc |
| 4 | Pin policy | SHA today; bump to tag at next ggpaintr release | This doc |
| 5 | Chunk binding | Chunk option `#\| fixture: <slug>` | This doc |
| 6 | Tooling | R scripts in `dev/`; authoritative command `Rscript dev/book-gate.R` → `BOOK GATE: PASS` | This doc |
| 7 | TOC | `_quarto.yml` reflects the post-grill structure (Foundations / Use cases & gallery / Composition / Embedding / Extension / Advanced topics) | `_quarto.yml` |
| 8 | Cutover | Lead with book; paired package PR drops vignette + fixtures + e2e once chapter ships | This doc |
| 9 | Precondition | Per-vignette package e2e green + drift audit clean before book absorbs it | This doc |

## BDD

```gherkin
Feature: Book stays truthful as ggpaintr evolves

Scenario: Chunk drifts from its fixture
  Given a chunk in placeholders.qmd tagged `#| fixture: app-basic`
  And tests/fixtures/book-apps/app-basic/app.R carries a `>>>` marker block
  When the .qmd chunk body is edited without updating the fixture's marker block
  Then `Rscript dev/book-gate.R` exits non-zero with `Verbatim: FAIL`
  And the diff is printed showing chunk-vs-marker-block divergence

Scenario: ggpaintr removes a symbol the book references
  Given the pinned ggpaintr no longer exports ptr_module_server
  And use-cases.qmd contains the token "ptr_module_server"
  When `Rscript dev/book-gate.R` runs
  Then it exits non-zero with `Symbols: FAIL`
  And the report lists every (file, line) reference to the missing symbol

Scenario: Fixture edited without re-shoot
  Given tests/fixtures/book-apps/app-basic/app.R is modified
  And images/app-basic.png.sha is not regenerated
  When `Rscript dev/book-gate.R` runs
  Then it exits non-zero with `Screenshots: FAIL`
  And the report says: run `Rscript dev/book-shoot.R app-basic`

Scenario: Vignette migration from package to book
  Given the package's ggpaintr-customization vignette is e2e-green and drift-audit clean
  When I open paired PRs: book PR absorbs the chapter + ports fixtures; package PR drops the vignette + fixtures + e2e cases
  Then `Rscript dev/book-gate.R` passes on the book PR
  And `devtools::check(document = FALSE, manual = FALSE, args = c("--as-cran","--no-manual"))` passes on the package PR
  And the package PR's diff removes vignettes/ggpaintr-customization.Rmd, the corresponding tests/testthat/fixtures/vignette-apps/, and the matching cases in test-e2e-vignette-examples-shinytest2.R

Scenario: Bumping the pin
  Given DESCRIPTION currently pins ggpaintr to SHA A
  When the pin is bumped to SHA B (or to tag v0.X) in a PR
  Then CI re-installs ggpaintr at SHA B and runs `Rscript dev/book-gate.R`
  And the gate must pass before merge
  And the front-matter version banner in index.qmd is updated to reference SHA B (or tag v0.X)
```

## Definition of Done

The single authoritative command, copy-pasteable:

```sh
Rscript dev/book-gate.R
```

Expected output on a clean tree, against the pinned ggpaintr:

```
Boot:        N/N fixtures booted
Verbatim:    M/M chunks match fixture markers
Symbols:     K ptr_* refs resolve
Screenshots: N/N pair-hashes match
Shinylive:   H/H hero demos compile
BOOK GATE: PASS
```

Known proxy traps:

- **`quarto render` succeeding is NOT the gate.** Quarto can render a book whose chunks are silently stale (verbatim disagreement) and whose screenshots are months out of date.
- **`devtools::test()` is NOT the gate.** The book is not an R package; there are no devtools tests in this repo.
- **A green CI badge by itself is NOT the gate** unless that CI ran `Rscript dev/book-gate.R` against the *currently pinned* ggpaintr SHA, not a stale cache.

## Authoring loop

**New chapter from scratch (no vignette migration):**

1. Scaffold the chapter file under the appropriate part in `_quarto.yml`.
2. Author chunks. For each chunk that mirrors a running app, write `#| fixture: <slug>` and create `tests/fixtures/book-apps/<slug>/app.R` with a `>>>` / `<<<` marker block whose contents equal the chunk body.
3. `Rscript dev/book-shoot.R <slug>` — boots the fixture in shinytest2, captures `images/<slug>.png`, writes `images/<slug>.png.sha`.
4. `Rscript dev/book-gate.R` — must print `BOOK GATE: PASS`.
5. `quarto preview` — visually inspect.
6. PR.

**Updating an existing chapter after a ggpaintr change:**

1. Identify what changed by running the gate first: `Rscript dev/book-gate.R` will report Symbols / Boot / Verbatim failures pointing at the affected chunks.
2. Edit chunk + fixture together (marker block in `app.R` must equal new chunk body).
3. Re-shoot any fixture whose `app.R` changed: `Rscript dev/book-shoot.R <slug>`.
4. Re-run the gate to green.

## Cross-repo vignette migration (per-vignette)

For each of `ggpaintr-customization`, `ggpaintr-llm`, `ggpaintr-safety`:

1. **Wait** for package-side precondition: that vignette's fixtures are e2e-green under `test-e2e-vignette-examples-shinytest2.R`, and the drift audit (`dev/audit/` in the package) reports zero wrong/stale claims for that vignette.
2. **Book PR**: create the target book chapter; copy `tests/testthat/fixtures/vignette-apps/<slug>/app.R` from the package to `tests/fixtures/book-apps/<slug>/app.R`; transplant relevant chunks from the vignette `.Rmd` into the chapter `.qmd` with `#| fixture: <slug>`; `Rscript dev/book-shoot.R` per slug; `Rscript dev/book-gate.R` to green; merge.
3. **Paired package PR**: delete `vignettes/<slug>.Rmd`, delete the migrated fixtures under `tests/testthat/fixtures/vignette-apps/`, delete the matching cases in `test-e2e-vignette-examples-shinytest2.R`; package `devtools::check(...)` green; merge.
4. Order: both PRs target the same week; ship the book one first, then the package one within ~24h.

The package retains minimal `ggpaintr-use-cases.Rmd` + `ggpaintr-gallery.Rmd`. Book chapters `use-cases.qmd` + `gallery.qmd` + `customization.qmd` carry the detailed/advanced material; the package vignettes stay deliberately thin.

## Pin policy & reader-facing version

`DESCRIPTION` declares the pin:

```
Remotes:
    willju-wangqian/ggpaintr@<sha-or-tag>
```

Today (no post-ADR-0006 tag exists): `willju-wangqian/ggpaintr@beec43259ef3df7490e08944bb4a79cd8655b0c5`. When the package cuts a tagged release containing ADR 0006 + ADR 0010, the pin advances to `willju-wangqian/ggpaintr@v0.X.Y` in a PR.

`index.qmd` carries a reader-facing version banner near the top: "This book documents ggpaintr `<short-sha-or-tag>`. Install with `remotes::install_github('willju-wangqian/ggpaintr@<short-sha-or-tag>')`." The banner is updated in the same PR that bumps `DESCRIPTION`'s Remotes line; the gate could later be extended to verify the two strings agree.

## CI

`.github/workflows/book-gate.yml` (to be written) runs on every push and pull_request to `main`:

1. Install R + Quarto + Chromium (for shinytest2).
2. `Rscript -e 'install.packages("remotes"); remotes::install_deps(dependencies = TRUE)'`.
3. `Rscript dev/book-gate.R`.
4. `quarto render` (verifies the book actually builds; not a gate but worth checking).

The existing `publish.yml` continues to publish to `gh-pages` on push to `main`, but is moved behind the gate (gate must pass first; publish only runs if gate is green).

## Honest gaps

- **No behavioral regression detection.** If ggpaintr renames `palette=` to `colors=` but silently accepts the old name as a no-op, the gate passes and the book shows working code that does nothing. Mitigation: lean on the package's own e2e suite (precondition #9) to catch this upstream.
- **Shinylive cannot exercise file upload via the OS picker** and may struggle with plotly + ggiraph custom-render fixtures. Hero demo selection must avoid these features. If a chosen hero turns out to be incompatible, fall back to screenshot for that chapter without breaking the rest.
- **The drift audit referenced in decision #9 is a package-side artifact that already exists for some vignettes (`dev/audit/FEATURE-CHECKLIST*`) but not all.** Per-vignette migration cannot start until the audit exists for that vignette. This is on the package side, not the book.
