# Plan: Finish the ggpaintr book

> Status: DRAFT 2026-06-10. Companion to the locked process doc [`book-workflow.md`](book-workflow.md) — that doc owns *how* a chapter ships (gate, fixtures, pin policy); this doc owns *what* remains to ship and in what order. Decisions taken with the author on 2026-06-10: (1) bump the pin to current ggpaintr HEAD `76a4126`; (2) gallery includes **everything** (ptr_app examples *and* plain ggplot2/extension-package plots); (3) all 18 chapters get full treatment; (4) shinylive heroes are gated on a feasibility spike, with screenshot fallback per ADR 0002.

## Source of truth

All content originates from `../ggpaintr` (the package repo). The book copies prose and code from the vignettes listed below; it never edits package files. Cross-repo rules in `book-workflow.md` § "Cross-repo vignette migration" apply to the two still-live vignettes (`ggpaintr-llm`, `ggpaintr-safety`); the three retired vignettes under `archive/retired_vignettes/` are already package-side-retired, so the book absorbs them without a paired package PR.

| Book chapter | Source in `../ggpaintr` | Approx. source location |
|---|---|---|
| `index.qmd` | rewrite of existing draft + new pin banner | — |
| `getting-started.qmd` | `vignettes/ggpaintr-tutorial.Rmd` § 1 "Basics" | lines 30–91 |
| `formula-language.qmd` | `archive/retired_vignettes/ggpaintr-use-cases.Rmd` § "Formula tour", "Data pipelines in the formula", "Layer and stage toggles" | lines 28–170 |
| `placeholders.qmd` | `ggpaintr-tutorial.Rmd` § "The five built-in placeholders", "Seeding the widgets", "Nothing renders until Update" | lines 44–91 |
| `generated-code.qmd` | `ggpaintr-use-cases.Rmd` § "Empty-call cleanup", "Local data with non-syntactic columns"; code-panel material from L1 | lines 235–268 |
| `use-cases.qmd` | `ggpaintr-use-cases.Rmd` § "L1 — All-in-one entry point" | lines 171–268 |
| `gallery.qmd` | `archive/retired_vignettes/ggpaintr-gallery.Rmd` §§ 3–7 + `dev/scripts/gallery-examples.R` | whole files |
| `customization.qmd` | `archive/retired_vignettes/ggpaintr-customization.Rmd` § "Migrating from checkbox_defaults", "Styling with CSS" | lines 28–57, 111–157 |
| `shared-placeholders.qmd` | `ggpaintr-use-cases.Rmd` § "Shared widgets: single vs multiple instances", "Multiple linked instances — the shared trio", "How input ids are built" | lines 302–423 |
| `multi-plot.qmd` | `ggpaintr-tutorial.Rmd` § 3 (`ptr_ui()`/`ptr_server()` + the `ptr_shared()` trio; `ptr_app_grid` is **not exported** at the pin — drift recorded in `dev/notes/2026-06-10-pin-76a4126-drift.md`, the retired vignette's grid sections are excluded) | tutorial 297–380 |
| `embed-default.qmd` | `ggpaintr-use-cases.Rmd` § "L2 — Embed in your own Shiny app", "Default-layout path" | lines 269–301 |
| `embed-bare.qmd` | `ggpaintr-use-cases.Rmd` § "L3 — Own the layout", "bare pieces and combinators", "fully hand-laid-out page", "slide-out code window", "navbarPage roots" | lines 424–545 |
| `custom-render.qmd` | `ggpaintr-use-cases.Rmd` § "Custom renderers — state$runtime()$plot", custom code panel / error UI / `ptr_gg_extra()` / shared widgets driving custom renderers | lines 546–731 |
| `custom-placeholders.qmd` | `ggpaintr-tutorial.Rmd` § 2 (value/consumer/source deltas) + `ggpaintr-customization.Rmd` § "Adding a new widget type" | tutorial 92–296; customization 262–547 |
| `theming-wrappers.qmd` | `ggpaintr-customization.Rmd` § "Writing your own wrapper", "Wrappers compose", "Public-API limits" | lines 158–261 |
| `ui-text.qmd` | `ggpaintr-customization.Rmd` § "Rewriting copy with ui_text" (six override sections, merge precedence, building overrides) | lines 58–110 |
| `llm.qmd` | `vignettes/ggpaintr-llm.Rmd` (live — paired package PR required) | whole file |
| `safety.qmd` | `vignettes/ggpaintr-safety.Rmd` (live — paired package PR required) | whole file |
| `cheatsheet.qmd` | distilled from all of the above: placeholder table, entry-point table (L1/L2/L3), `pp*` keyword reference | — |

## Global Success Criteria

1. All 18 chapter `.qmd` files contain real teaching content; zero "Draft stub" callouts remain anywhere in the book (`grep -rl "Draft stub" *.qmd` returns nothing).
2. `Rscript dev/book-gate.R` prints `BOOK GATE: PASS` with non-trivial counts: Boot ≥ 20 fixtures, Verbatim ≥ 20 chunks, Symbols ≥ 1, Screenshots = Boot count.
3. `DESCRIPTION` pins ggpaintr to `76a4126` (or a tag that contains it); `index.qmd`'s banner names the same ref.
4. `quarto render` completes without error and every gallery section from the retired gallery vignette (§§ 3–6.5) appears in the rendered `gallery.qmd`.
5. CI (`.github/workflows/book-gate.yml`) is green on `main` against the new pin, and `publish.yml` deploys the rendered book.

## Global Constraints

- Follow `book-conventions.md` chunk rules exactly: app chunks are `eval: false` + `#| fixture: <slug>` + screenshot; only genuinely static output sets `eval: true`.
- Fixture `app.R` files must be self-contained: any custom placeholder definition (`ppRange`, `ppVars`, `colvars`, `ppPercent`, …) the chunk shows lives *inside* the `>>>`/`<<<` marker block so chunk and fixture stay byte-identical; boot-harness lines stay outside the block.
- The book repo never edits `../ggpaintr`. The only package-side work this plan triggers is the paired vignette-deletion PRs for `llm` and `safety` (M8), authored separately in that repo per `book-workflow.md` § "Cross-repo vignette migration".
- Prose may be copied from the vignettes, but second-person voice, heading levels, and cross-references must be adapted to book context; no chapter may describe ggpaintr internals (CLAUDE.md "Out of scope").
- Do not hard-wrap prose; one paragraph per line.
- New R dependencies used by gallery chunks must be added to `DESCRIPTION` Imports in the same PR as the chunk that needs them.

## Piece tiers (audit rigor)

Agreed 2026-06-10 (`/implementable`): **load-bearing** — M1 (edits gate code itself), M2 (first run of the unproven shoot pipeline; sets the fixture pattern all later milestones copy), M4 (widest blast radius: CI dependency surface, render-time evaluation), M9 (cross-repo pairing with an external precondition). **Leaf** — M0, M3, M5, M6, M7, M8, M10 (gate-covered pattern work; the floor — observable Success Criteria, authoritative DoD, independence clause — still applies to every piece).

## Independence & verification

Any "done / gate green / render clean" report from an implementer — a sub-agent, a worktree session, a milestone PR description, or a previous session of the same author — is a claim to verify, never proof. Before merging any milestone PR, the integrator re-runs that milestone's Definition of Done (`Rscript dev/book-gate.R`, plus `quarto render` where the DoD includes it) on the merge candidate and observes the expected output personally. A status block, a CI badge, or a pasted terminal transcript does not substitute for re-running the gate.

## Definition of Done (whole plan)

```sh
Rscript dev/book-gate.R && quarto render
```

Expected: gate output ending `BOOK GATE: PASS` (with N = M = screenshot count ≥ 20, Symbols ≥ 1), then a complete render with no errors. Proxy traps (from CLAUDE.md, restated because they will tempt at every milestone): `quarto render` succeeding alone is NOT done (renders stale chunks happily); `devtools::test()` is meaningless here; a green CI badge only counts if that run used the `76a4126` pin.

## Parent-criteria coverage (`book-workflow.md` → this plan)

The locked parent doc's six Success Criteria map to this plan's scenarios as follows; each is verified at the boundary the criterion describes (the gate's printed output), not only at the implementation seam.

| `book-workflow.md` Success Criterion | Covering scenario(s) |
|---|---|
| 1 — gate exits 0 with `BOOK GATE: PASS` iff all five properties hold | M2 (both scenarios), M1 (both Shinylive scenarios), M10 "Final authoritative check on main" |
| 2 — every `#\| fixture:` chunk byte-identical to its marker block | M2 "Chunk and fixture stay byte-identical"; M4 "Interactive version is fixture-backed" |
| 3 — every `ptr_*` token resolves against the pinned NAMESPACE | M6 "Symbol check covers the shared trio" |
| 4 — screenshot pair-hash sidecar tracks the fixture | M2 "Screenshot tracks the fixture" |
| 5 — `DESCRIPTION` Remotes pins a specific SHA; floating refs rejected | M0 "Pin and banner advance together" |
| 6 — CI runs the gate on every push; merge requires green | M10 "Final authoritative check on main" |

---

## M0 — Pin bump + repo hygiene

Bump `DESCRIPTION` Remotes from `beec4325…` to `76a41267…` (current `../ggpaintr` HEAD; gains `suppress_warnings` option). Update the version banner + install snippet in `index.qmd` to the same SHA. Fix the stale package path in the book's `CLAUDE.md` (`../ggpaintr-post-add-expr/` → `../ggpaintr/`, two occurrences). Add the gallery dependencies to `DESCRIPTION` Imports: `broom`, `tidyr`, `purrr`, `palmerpenguins`, `ggpcp`, `GGally`, `ggridges`, `ggrepel`, `ggalluvial`, `ggdist`. Reinstall ggpaintr at the new pin locally.

**Success Criteria:** `grep -c 76a4126 DESCRIPTION index.qmd` ≥ 1 each; `grep ggpaintr-post-add-expr CLAUDE.md` empty; gate passes (trivially — zero fixtures exist yet).

**Constraints:** Pin must be the full 40-char SHA in `DESCRIPTION` (gate rejects floating refs). Banner and Remotes change in the same commit (workflow doc § "Pin policy").

```gherkin
Feature: Book tracks a specific ggpaintr SHA
Scenario: Pin and banner advance together
  Given DESCRIPTION pins ggpaintr@beec4325...
  When the Remotes line is changed to ggpaintr@76a41267... and index.qmd's banner is updated in one commit
  Then `Rscript dev/book-gate.R` exits 0
  And `grep -o "76a4126[0-9a-f]*" DESCRIPTION index.qmd` finds the SHA in both files
```

**Definition of Done:** `Rscript dev/book-gate.R` → `BOOK GATE: PASS` with the new pin installed (`Rscript -e 'packageDescription("ggpaintr")$RemoteSha'` prints `76a41267…`). Proxy trap: the gate passing against a *stale local install* of ggpaintr is not done — verify RemoteSha first.

## M1 — Shinylive feasibility spike (timeboxed: 1 session)

Attempt a minimal `{shinylive-r}` chunk embedding `ptr_app("ggplot(iris, aes(var, var)) + geom_point()")` in a scratch qmd; ggpaintr must install under webR (likely blocker: native deps or GitHub-only install). Record the verdict in `dev/notes/`. If GO: wire `check_shinylive` in `dev/book-gate.R` (currently a stub at `dev/book-gate.R:217` reporting "TODO: wire shinylive compile") so heroes are actually compiled. If NO-GO: apply ADR 0002's fallback — heroes become screenshot chapters, no `shinylive: true` front matter anywhere, gate truthfully reports `Shinylive: 0/0`.

**Success Criteria:** A written GO/NO-GO note with the failing/passing evidence; the gate's Shinylive line is truthful either way (no `shinylive: true` chapter exists while the check is a stub).

**Constraints:** Timebox to one working session; do not sink time into patching webR. Hero selection must avoid file upload, plotly, ggiraph (workflow doc § "Honest gaps").

```gherkin
Feature: Hero display mode is decided by evidence
Scenario: webR cannot install ggpaintr
  Given a scratch qmd with a shinylive-r chunk calling ptr_app()
  When `quarto render` of the scratch file fails at webR package install
  Then the spike note records NO-GO with the error text
  And getting-started.qmd and formula-language.qmd are authored screenshot-only
  And `Rscript dev/book-gate.R` reports "Shinylive: 0/0"
Scenario: webR runs the hero
  Given the same scratch chunk renders an interactive app in the browser
  Then dev/book-gate.R::check_shinylive is implemented to compile hero chunks
  And the two hero chapters set `shinylive: true`
```

**Interface Contract (GO branch — `dev/book-gate.R::check_shinylive`):**

- **Signature:** `check_shinylive(qmd_files)` — `qmd_files`: character vector of chapter paths, required, no default. Returns `list(name = "Shinylive", pass = <logical>, msg = <character>, details = <character>)` — the same check-result shape the gate's other checks emit.
- **Input domain:** any character vector of existing `.qmd` paths. Heroes are the subset whose YAML front matter sets `shinylive: true`. Outside the circle: a path that does not exist, or front matter that fails to parse → that file is reported as a failure in `details`, never silently skipped.
- **Output spec:** `pass = TRUE` iff every `{shinylive-r}` chunk in every hero compiles under the quarto shinylive extension (a bundling/compile check; no execution semantics asserted). `msg` is exactly `sprintf("%d/%d hero demos compile", H_ok, H)`.
- **Error modes:** hero declares `shinylive: true` but contains zero `{shinylive-r}` chunks → `pass = FALSE`, `details` names the file and says "hero declares shinylive but has no shinylive-r chunk"; shinylive quarto extension not installed → `pass = FALSE`, `details` gives the install command; zero heroes in `qmd_files` → `pass = TRUE`, `msg = "0/0 hero demos compile"`.
- **Worked examples:** (a) `check_shinylive("use-cases.qmd")` where that file has no `shinylive:` front-matter key → `pass = TRUE`, `msg = "0/0 hero demos compile"`. (b) `check_shinylive("getting-started.qmd")` where front matter has `shinylive: true` and one compilable `{shinylive-r}` chunk → `pass = TRUE`, `msg = "1/1 hero demos compile"`. (c) Same file with `shinylive: true` but no `{shinylive-r}` chunk → `pass = FALSE`, `msg = "0/1 hero demos compile"`.

**Definition of Done:** spike note committed under `dev/notes/`; `Rscript dev/book-gate.R` → `BOOK GATE: PASS` with a Shinylive line that is either `0/0` (NO-GO) or `H/H` with H ≥ 1 produced by a real compile (GO). Proxy trap: declaring heroes "supported" because the chunk *renders locally in quarto preview* — the gate's compile check, not preview, is the evidence.

## M2 — Foundations part (`getting-started`, `formula-language`, `placeholders`, `generated-code`)

Write the four Foundations chapters from tutorial § 1 and use-cases' formula-tour material per the source map. Estimated fixtures: getting-started 2 (literal formula; one placeholder added), formula-language 3 (formula tour app, pipeline app, `ppLayerOff`/`ppVerbSwitch` app), placeholders 2 (five built-ins in one app; seeded widgets), generated-code 0–1 (mostly `eval: true` static chunks showing generated-code strings and cleanup behavior). For each fixture: create `tests/fixtures/book-apps/<slug>/app.R`, `Rscript dev/book-shoot.R <slug>`, gate to green.

**Success Criteria:** Four chapters with no stub callouts; ≥ 7 new fixtures booting; every `pp*`/`ptr_*` symbol the prose names resolves against the pinned NAMESPACE; a reader can go from zero to a running customized app by following getting-started alone.

**Constraints:** getting-started stays short (first-app experience only); deeper placeholder semantics belong to `placeholders.qmd`; toggle keywords (`ppLayerOff`, `ppVerbSwitch`) belong to `formula-language.qmd`. Static chunks demonstrating generated code must really evaluate (`eval: true`) so readers see live output.

```gherkin
Feature: Foundations chapters teach the core loop truthfully
Scenario: Chunk and fixture stay byte-identical
  Given getting-started.qmd has a chunk tagged `#| fixture: getting-started-first-app`
  When the chunk body and the fixture's >>>/<<< block differ by one character
  Then `Rscript dev/book-gate.R` exits non-zero with `Verbatim: FAIL`
Scenario: Screenshot tracks the fixture
  Given fixture getting-started-first-app/app.R is edited
  When dev/book-shoot.R is not re-run
  Then the gate exits non-zero with `Screenshots: FAIL`
```

**Definition of Done:** `Rscript dev/book-gate.R` → `BOOK GATE: PASS` with Boot ≥ 7 and Screenshots = Boot; `quarto render` clean; `grep -l "Draft stub" getting-started.qmd formula-language.qmd placeholders.qmd generated-code.qmd` empty. Proxy trap: a chapter that *renders* but whose chunks were never bound to fixtures (`#| fixture:` omitted) silently bypasses Verbatim — check the gate's M count grew by the expected number of chunks.

## M3 — `use-cases.qmd` (L1 entry point)

Absorb use-cases § L1: `ptr_app()` single plot, empty-call cleanup, local data with non-syntactic columns. The vignette's "Multiple plots and shared widgets — ptr_app_grid()" section is dead API at the pin (`ptr_app_grid` is not exported — see `dev/notes/2026-06-10-pin-76a4126-drift.md`); replace it with a one-paragraph pointer to `multi-plot.qmd`'s `ptr_ui()`/`ptr_server()` approach. Estimated fixtures: 3.

**Success Criteria / Constraints:** as M2, scoped to one chapter; the token `ptr_app_grid` must not appear in any chapter (the Symbols gate rejects it).

```gherkin
Feature: L1 chapter mirrors the retired use-cases vignette
Scenario: Non-syntactic column example works at the pinned SHA
  Given the fixture use-cases-nonsyntactic/app.R copied from the vignette's example
  When `Rscript dev/book-gate.R` runs
  Then the Boot line counts that fixture as booted
```

**Definition of Done:** gate PASS with Boot ≥ 10 cumulative; render clean; no stub callout in `use-cases.qmd`. Proxy traps: as M2.

## M4 — `gallery.qmd` (the explicit user ask)

Port retired gallery vignette §§ 3–7, using `dev/scripts/gallery-examples.R` as the runnable reference for each section's "original plot". Every section gets the pattern: short intro prose → **original plot** as an evaluated static chunk (`eval: true`; plotly/ggiraph emit live htmlwidgets, plain ggplot2 emits an image) → where a `ptr_app()` formula version exists, the **parameterized version** as a fixture-bound verbatim chunk + screenshot. Section inventory with display mode:

| § | Example | Original chunk | ptr_app fixture |
|---|---|---|---|
| 3 | Realistic mpg graphic with `ppRange` custom placeholder | eval: true | `gallery-realistic` |
| 4.1 | dplyr filter/group pipeline | eval: true | `gallery-pipeline` |
| 4.2 | PCA + ellipses with `ppVars` consumer + `ppVerbSwitch` | eval: true | `gallery-pca` |
| 4.3 | K-means elbow | eval: true | — (static only) |
| 4.4 | Regression diagnostics (mtcars; iris `ppExpr` variant) | eval: true | `gallery-regression` |
| 4.5 | Rolling time-series | eval: true | `gallery-rolling` |
| 4.6 | Group-wise regression coefficients (penguins) | eval: true | — |
| 5.1 | plotly tooltips | eval: true (htmlwidget) | — |
| 5.2 | ggiraph tooltips | eval: true (htmlwidget) | — |
| 6.1 | ggpcp parallel coordinates + `ppVars2` bare-name consumer | eval: true | `gallery-pcp` |
| 6.2 | ggridges | eval: true | — |
| 6.3 | ggrepel | eval: true | — |
| 6.4 | ggalluvial | eval: true | — |
| 6.5 | ggdist + `colvars` / `ppPercent` examples | eval: true | `gallery-percent` |

**Success Criteria:** all 14 sections present in rendered output; 7 new fixtures boot; every custom-placeholder definition shown in a fixture-bound chunk lives inside the marker block so the fixture is self-bootable; § 7 "Where to go next" becomes cross-links into the book's own chapters.

**Constraints:** Original-plot chunks must run at render time with only `DESCRIPTION`-declared packages (no `install.packages` in chunks). The two `ppVars` variants (string-vector vs bare-name) and `ptr_arg_*` helper definitions are copied verbatim from `gallery-examples.R` — do not "improve" them; they are the tested reference. Section 4.4's duplicated title in the second variant (`"mpg ~ wt + cyl + hp"` over iris data, `gallery-examples.R:149`) is a source bug — fix the title in book copy and note it; everything else byte-faithful.

```gherkin
Feature: Gallery pairs every original plot with its tested interactive version
Scenario: Original plot really evaluates
  Given gallery.qmd § 6.2 contains the ggridges chunk with `#| eval: true`
  When `quarto render` runs
  Then the rendered chapter contains the ridge-density figure and no error block
Scenario: Interactive version is fixture-backed
  Given § 4.2 contains a chunk tagged `#| fixture: gallery-pca`
  And tests/fixtures/book-apps/gallery-pca/app.R defines ppVars inside its >>>/<<< block
  When `Rscript dev/book-gate.R` runs
  Then Boot counts gallery-pca and Verbatim matches the chunk byte-for-byte
Scenario: A gallery dependency is missing from DESCRIPTION
  Given a chunk uses ggalluvial but DESCRIPTION lacks it
  When CI runs remotes::install_deps then quarto render
  Then the render fails — so the dependency list in M0 must already cover every gallery package
```

**Definition of Done:** `Rscript dev/book-gate.R` → PASS with Boot ≥ 17 cumulative; `quarto render` clean; rendered `_book/gallery.html` contains all 14 section headings (`grep -c "<h3\|<h2" _book/gallery.html` consistent with the table). Proxy trap: `eval: true` chunks make `quarto render` itself a *partial* check here, but it still cannot catch fixture/screenshot staleness — both commands are required.

## M5 — `customization.qmd`

Absorb the retired customization vignette's user-facing surface: `checkbox_defaults` migration and the two CSS surfaces. (Its `ui_text` deep-dive goes to `ui-text.qmd` in M8; "Adding a new widget type" goes to `custom-placeholders.qmd` in M8; "Writing your own wrapper" goes to `theming-wrappers.qmd` in M8 — this chapter links to all three.) Estimated fixtures: 2 (a CSS-styled app; a `css =` injection app).

**Success Criteria / Constraints:** chapter contains no placeholder-definition or wrapper-authoring content (those are Extension-part topics); "What is not stable surface" caveats are preserved verbatim in intent.

```gherkin
Feature: Customization chapter shows only stable styling surface
Scenario: Styled app fixture boots
  Given fixture customization-css/app.R passes a css = argument to ptr_app
  When the gate runs
  Then Boot counts it and the screenshot pair-hash matches
```

**Definition of Done:** gate PASS (Boot ≥ 19 cumulative); render clean; no stub callout. Proxy traps: as M2.

## M6 — Composition part (`shared-placeholders`, `multi-plot`)

`shared-placeholders.qmd` from use-cases' shared-widget sections (single instance auto-inline; the shared trio; input-id construction and collision avoidance). `multi-plot.qmd` from tutorial § 3 (one plot inside your own app via `ptr_ui()`/`ptr_server()`; one control across several plots via `ptr_shared()` + `ptr_shared_panel()` + `ptr_shared_server()`; layout is plain Shiny `fluidRow`/`column` — `ptr_app_grid` does not exist at the pin and must not be mentioned). Estimated fixtures: 4.

**Success Criteria:** both chapters stub-free; the shared trio example and the own-app multi-plot example each have a booting fixture + screenshot; id-collision guidance names the actual id scheme the pinned version uses (verify against package man pages, not memory).

**Constraints:** Multi-plot screenshots must show ≥ 2 plots in frame to be honest illustrations; if `book-shoot.R`'s viewport is too small, extend the shot height for these slugs rather than cropping.

```gherkin
Feature: Composition chapters demonstrate sharing across plots
Scenario: Shared trio fixture boots with one control driving two plots
  Given fixture shared-trio/app.R from the vignette's shared-widget example
  When the gate runs
  Then Boot counts it
Scenario: Symbol check covers the shared trio
  Given multi-plot.qmd mentions ptr_shared, ptr_shared_panel, and ptr_shared_server
  When the pinned ggpaintr exports all three
  Then the Symbols line resolves them
```

**Definition of Done:** gate PASS (Boot ≥ 23 cumulative); render clean. Proxy traps: as M2.

## M7 — Embedding part (`embed-default`, `embed-bare`, `custom-render`)

`embed-default.qmd` from use-cases L2 (`ptr_ui()` / `ptr_server()`). `embed-bare.qmd` from L3 (bare pieces + combinators, hand-laid page, slide-out code window recipe, navbarPage decomposition). `custom-render.qmd` from L3's custom renderers (`state$runtime()$plot` in `renderPlotly`, custom code panel, custom error UI, `ptr_gg_extra()`, shared widgets driving custom renderers). Estimated fixtures: 4 (one L2 app, one hand-laid L3 page, one plotly custom renderer, one `ptr_gg_extra`).

**Success Criteria:** the three chapters together cover the L2/L3 ladder without overlap; every `ptr_*` combinator named (e.g. `ptr_ui_controls`, `ptr_server`) resolves in the Symbols check.

**Constraints:** These fixtures are full Shiny apps, not `ptr_app()` one-liners — the marker block contains the whole `ui`/`server`/`shinyApp` body shown in the chunk. Keep each example minimal enough that the screenshot fits one frame.

```gherkin
Feature: Embedding chapters mirror the L2/L3 vignette ladder
Scenario: Custom plotly renderer fixture boots
  Given fixture custom-render-plotly/app.R renders state$runtime()$plot via plotly::renderPlotly
  When the gate runs
  Then Boot counts it and its screenshot pair-hash matches
```

**Definition of Done:** gate PASS (Boot ≥ 27 cumulative); render clean; no stub callouts in the three files. Proxy traps: as M2.

## M8 — Extension part (`custom-placeholders`, `theming-wrappers`, `ui-text`)

`custom-placeholders.qmd` merges tutorial § 2 (the value → consumer → source delta narrative) with customization's "Adding a new widget type" reference detail (node/value/resolve_expr contracts, `spec=` seeding, common pitfalls, unregistering). `theming-wrappers.qmd` from customization's wrapper sections. `ui-text.qmd` from customization's `ui_text` sections (six override sections, merge precedence, building overrides). Estimated fixtures: 4 (one custom value placeholder app, one consumer, one wrapper-applied app, one ui_text-override app).

**Success Criteria:** the delta narrative survives the merge (tutorial's teaching order wins; customization's reference tables follow); every constructor argument documented (`build_ui`, `resolve_expr`, `validate_session_input`, `parse_positional_arg`, `parse_named_args`, `embellish_eval`, `ui_text_defaults`) matches the pinned function signatures (verify with `formals()` against the installed pin, not against vignette text).

**Constraints:** This is the highest drift-risk part — tutorial and customization describe the same API at different ages. Where they disagree, the installed `76a4126` package is the arbiter; record any such disagreement found in `dev/notes/`.

```gherkin
Feature: Extension chapters document the real constructor contracts
Scenario: Documented signature matches the pinned package
  Given custom-placeholders.qmd documents ptr_define_placeholder_value(keyword, build_ui, resolve_expr, ...)
  When `Rscript -e 'names(formals(ggpaintr::ptr_define_placeholder_value))'` runs against the pin
  Then every argument the chapter documents appears in that output
Scenario: ui_text override fixture boots
  Given fixture ui-text-overrides/app.R passes a ui_text override list
  When the gate runs
  Then Boot counts it
```

**Definition of Done:** gate PASS (Boot ≥ 31 cumulative); render clean; the `formals()` cross-check above run for all three `ptr_define_placeholder_*` constructors with no undocumented-vs-documented mismatch. Proxy trap: trusting the vignette text for signatures — the vignettes predate the pin; only `formals()` against the installed pin counts.

## M9 — Advanced part (`llm`, `safety`) + paired package PRs

Migrate the two live vignettes per `book-workflow.md` § "Cross-repo vignette migration". Precondition (decision #9): each vignette's package-side e2e fixtures green and drift audit clean — **check this in `../ggpaintr` before starting; if the audit artifact is missing for a vignette, that blocks and goes back to the package, not worked around here.** Book PR: absorb chapter, port any package fixtures to `tests/fixtures/book-apps/`, shoot, gate. Paired package PR (authored in `../ggpaintr`, separately): delete vignette + fixtures + e2e cases, `devtools::check()` green, ships within ~24h after the book PR.

**Success Criteria:** `llm.qmd` covers all 10 vignette sections (motivation → behavior boundary); `safety.qmd` covers `expr_check` modes, denylist + AST walker, upload trust model; LLM chapter's provider snippets are shown `eval: false` (they need API keys) with the token-free testing path (§ 8) as the only evaluated chunk.

**Constraints:** Safety chapter must preserve the vignette's "when (never) to turn it off" framing — it is a normative claim, not optional color. No API keys, no network calls at render time.

```gherkin
Feature: Live vignettes migrate without a coverage gap
Scenario: Precondition is checked before migration
  Given the package's drift audit lacks an entry for ggpaintr-llm
  When M9 starts
  Then the book PR is not opened and the gap is reported to the package repo
Scenario: Paired PRs leave no orphaned content
  Given the book PR with llm.qmd is merged and gate-green
  When the package PR deletes vignettes/ggpaintr-llm.Rmd and its fixtures and e2e cases
  Then devtools::check() passes on the package PR
  And at no point is the content absent from both repos
```

**Definition of Done:** book side — `Rscript dev/book-gate.R` → PASS (Boot ≥ 33 cumulative), render clean; package side — `devtools::check(document = FALSE, manual = FALSE, args = c("--as-cran","--no-manual"))` green on the paired PR. Proxy trap: the book gate passing says nothing about the package PR; both gates must be seen green, each in its own repo.

## M10 — Front/back matter + final sweep

Rewrite `index.qmd` (drop "work-in-progress", final hero/fallback wording per M1's verdict, confirm banner SHA). Write `cheatsheet.qmd`: the five built-in placeholders table, the `pp*` keyword reference (`ppLayerOff`, `ppVerbSwitch`, upload shortcut), the L1/L2/L3 entry-point table with one-line signatures. Populate `references.bib`/`references.qmd` (ggplot2, Shiny, the extension packages cited in the gallery). Final sweep: stub-grep, full gate, full render, CI green, publish verified.

**Success Criteria:** the five Global Success Criteria at the top of this plan all hold simultaneously on `main`.

**Constraints:** Cheatsheet entries must each name a chapter to read more — it is an index, not a fourth tutorial. No new fixtures in this milestone unless the index hero requires one.

```gherkin
Feature: The finished book ships
Scenario: Final authoritative check on main
  Given all chapter PRs are merged to main
  When CI runs `Rscript dev/book-gate.R` followed by `quarto render` at the 76a4126 pin
  Then the gate prints BOOK GATE: PASS
  And `grep -rl "Draft stub" *.qmd` prints nothing
  And the gh-pages deployment serves the rendered gallery with all 14 sections
```

**Definition of Done:**

```sh
grep -rl "Draft stub" *.qmd; Rscript dev/book-gate.R && quarto render
```

Expected: the grep prints nothing; the gate ends `BOOK GATE: PASS` with Boot ≈ 33, Screenshots = Boot, Shinylive per M1's verdict; render completes. Then confirm the CI run on `main` executed the same gate against the `76a4126` pin (open the Actions log; a cached older ggpaintr install is the named trap) and that `publish.yml` deployed.

---

## Order & parallelism

M0 → M1 are sequential and first (everything is written against the new pin; hero mode affects M2's chapter front matter). M2 → M3 → M4 sequential (each builds reader vocabulary the next assumes). M5–M8 are independent of each other after M3 and can proceed in any order or in parallel branches; M4 (gallery) can also run parallel to M5–M8 once M3 merges. M9 runs whenever its package-side precondition is met (independent of M4–M8). M10 is last. Each milestone is one PR (M9 is two, paired cross-repo).

## Risks worth one line each

- `dev/book-shoot.R` has never run against a real fixture (zero exist) — M2's first fixture will debug the shoot pipeline; budget slack there.
- Gallery `eval: true` chunks make render time and CI dependency surface much larger; if CI time blows up, switch §§ 5–6 originals to pre-rendered images in a follow-up decision, not silently.
- The two retired-vignette sources predate the pin by months; any example that no longer boots at `76a4126` is package drift — record it in `dev/notes/` and adapt the book copy, never patch the package from here.

<!-- implementable: PASS date=2026-06-10 gate="Rscript dev/book-gate.R" hash=66ece2e8d9a2 -->
