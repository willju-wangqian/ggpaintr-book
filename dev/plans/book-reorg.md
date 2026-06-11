# Plan — Reorganize the book around reader tasks (ADR 0003)

Decision record: [ADR 0003](../../docs/adr/0003-task-oriented-toc.md). Domain language: [`CONTEXT.md`](../../CONTEXT.md). Baseline: 36 fixtures under `tests/fixtures/book-apps/`, gate green at pin `1a28cec`.

## Audit tiering (per /implementable, recorded 2026-06-11; user pre-authorized autonomous tiering)

- Step 1 (Introduction + hero fixture): **load-bearing** — new fixture + gate interaction + environment risk.
- Step 2 (`_quarto.yml` restructure): **leaf** — mechanical, fully caught by gate + render; floor items only.
- Step 3 (dissolve `use-cases.qmd`): **load-bearing** — byte-identical chunk moves, file deletion, 7 ref retargets.
- Step 4 (split custom-placeholders): **load-bearing** — content restructure, anchor management, fixture redistribution.
- Step 5 (reorder + trims): **leaf** — small mechanical prose edits; floor items only.

## Independence clause

Any "done / gate green" report from a sub-agent, a worktree session, or a prior turn is a claim, not proof. The integrator re-runs `Rscript dev/book-gate.R` and `quarto render` themselves and reads the output before merging; a status block or CI badge is never a substitute.

## Baseline / drift ledger

Before branching, run `Rscript dev/book-gate.R` on `main` and record its full output in the PR description as the baseline ledger. Any failure later in the branch is compared against this ledger: present in baseline → pre-existing (surface, don't absorb); absent → introduced by this work.

## Branch / merge convention

All work lands on branch `book-reorg-adr-0003`, one commit per step (each step revertable as a unit via `git revert`), one `--no-ff` merge to `main` via PR after local gate + CI gate are green.

## Parent-criteria coverage (ADR 0003 promise → scenario)

- Task-named parts replace mechanism parts → step 2 "New parts present in order" + "Old structure is gone".
- Custom placeholders taught as core, ramped → step 4 "First chapter is minimal" + "Anchors resolve".
- Gallery terminal, backward-pointing only → step 2 part order scenario (Gallery last) + step 3 orphan-ref scenario.
- Reader prerequisite is ggplot2-only, Shiny per-part → step 5 both scenarios.
- use-cases dissolves without dangling refs → step 3 both scenarios.
- Introduction pitches to a zero-knowledge Reader with an honest, gate-bound demo → step 1 both scenarios.

## Target table of contents

```
Welcome (index.qmd, trimmed)
1. Introduction (introduction.qmd, NEW)
Part I — Your first app
  2. Getting started (getting-started.qmd, absorbs chrome tour + own-data)
Part II — Writing formulas
  3. The built-in placeholders (placeholders.qmd)
  4. The formula language (formula-language.qmd, absorbs string-form example)
  5. The generated code and plot (generated-code.qmd)
Part III — Custom placeholders
  6. Your first custom placeholder (custom-placeholders.qmd, keeps #sec-custom-placeholders)
  7. Consumer and source placeholders (custom-consumer-source.qmd, NEW)
  8. The hook contract (hook-contract.qmd, NEW)
Part IV — ggpaintr in your own Shiny app   [Shiny prerequisite stated here]
  9. embed-default  10. multi-plot  11. shared-placeholders  12. embed-bare  13. custom-render
Part V — Making it yours
  14. customization  15. theming-wrappers  16. ui-text
Part VI — Sharing & advanced
  17. safety  18. llm
Part VII — Gallery
  19. gallery
Appendix: cheatsheet
DELETED: use-cases.qmd
```

## Global Definition of Done (authoritative — applies to every step)

```sh
Rscript dev/book-gate.R
```

Baseline on `main` (recorded 2026-06-11): `Boot 36/36 · Verbatim 36/36 · Symbols 49 · Screenshots 36/36 · Shinylive 0/0 · PASS`.

Expected output after the reorg (36 baseline fixtures + `intro-hero` from step 1 + `custom-minimal` from step 4):

```
Boot:        38/38 fixtures booted
Verbatim:    38/38 chunks match fixture markers
Symbols:     K ptr_* refs resolve   (K >= 49; new chapters may add ptr_* mentions)
Screenshots: 38/38 pair-hashes match
Shinylive:   0/0 hero demos compile
BOOK GATE: PASS
```

Plus a clean full render: `quarto render` exits 0 with no `WARN.*unresolved` cross-reference warnings in its output.

**Proxy traps (named, per project CLAUDE.md):** `quarto render` succeeding alone is NOT the gate (it renders stale chunks/screenshots happily); `devtools::test()` does not exist here; a green CI badge does not prove the gate ran against the pinned SHA. Run the gate locally and read its output.

---

## Step 1 — New Introduction chapter + hero fixture

**Success Criteria**

- `introduction.qmd` exists with anchor `{#sec-intro}` and contains, in order: the pitch (one paragraph, plain language, no jargon), a before/after pair (plain ggplot2 call shown statically → the same call with placeholders as a fixture-bound chunk → hero screenshot), the L1/L2/L3 roadmap table (moved from `use-cases.qmd:5-9`, "Chapter" column retargeted), a custom-placeholder teaser reusing `images/gallery-percent.png` (no new fixture for the teaser), and a short honest "when not to use ggpaintr" section.
- New fixture `tests/fixtures/book-apps/intro-hero/app.R` with `>>>`/`<<<` markers; chunk in `introduction.qmd` tagged `#| fixture: intro-hero`; screenshot `images/intro-hero.png` + `.sha` sidecar produced by `Rscript dev/book-shoot.R intro-hero`.
- The hero example is distinct from `getting-started-first-app` and `getting-started-seeded` (different dataset or visibly richer placeholder mix).

**Constraints**

- Requires the pinned ggpaintr (`@1a28cec`) installed locally to boot/shoot the fixture.
- Chapter is screenshot-only under ADR 0002's fallback rule — do NOT set `shinylive: true`.
- No internals/design content (project CLAUDE.md "Out of scope").
- Prose not hard-wrapped: one paragraph = one line.

**BDD**

```gherkin
Feature: Introduction chapter pitches ggpaintr to a reader with zero package knowledge
  Scenario: Hero chunk is gate-bound
    Given introduction.qmd contains a chunk tagged "#| fixture: intro-hero"
    When Rscript dev/book-gate.R runs
    Then the Verbatim count includes the intro-hero chunk
    And the Screenshots count includes images/intro-hero.png

  Scenario: Roadmap replaces use-cases as the levels reference
    Given the L1/L2/L3 table is present in introduction.qmd
    When grep -c 'ptr_app\|ptr_ui\|ptr_ui_page' introduction.qmd runs
    Then the count is at least 3
```

**Interface Contract**

- `introduction.qmd` — surface: H1 `# Introduction {#sec-intro}`; exactly one `#| fixture: intro-hero` chunk (with `#| eval: false`); a roadmap table with exactly three level rows (L1/L2/L3); a reference to `images/gallery-percent.png`; a "when not to use" heading. Rejected (outside the circle): any `shinylive: true`; any `@sec-use-cases` reference; any second fixture-bound chunk. Worked example: `grep -c 'fixture: intro-hero' introduction.qmd` → `1`; `grep -c 'shinylive' introduction.qmd` → `0`.
- `tests/fixtures/book-apps/intro-hero/app.R` — surface: boot-harness header (`library(ggpaintr); library(ggplot2)`), one `# >>>` … `# <<<` marker block byte-identical to the qmd chunk body, app boots headless under the gate. Side effects: `images/intro-hero.png` + `images/intro-hero.png.sha` (SHA-256 of `app.R`). Worked example: `shasum -a 256 tests/fixtures/book-apps/intro-hero/app.R | cut -d' ' -f1` equals `cat images/intro-hero.png.sha`.

**Definition of Done:** global DoD, plus `grep -l 'fixture: intro-hero' introduction.qmd` prints the file and `test -f images/intro-hero.png.sha` succeeds.

## Step 2 — Restructure `_quarto.yml`

**Success Criteria**

- `book.chapters` matches the target ToC exactly (part names verbatim: "Your first app", "Writing formulas", "Custom placeholders", "ggpaintr in your own Shiny app", "Making it yours", "Sharing & advanced", "Gallery").
- `use-cases.qmd` no longer appears; `introduction.qmd`, `custom-consumer-source.qmd`, `hook-contract.qmd` do.

**Constraints**

- Do not touch the `execute:` block or `format:` block.
- Step lands together with steps 1/3/4 in one PR — the intermediate states do not render.

**BDD**

```gherkin
Feature: ToC follows ADR 0003
  Scenario: Old structure is gone
    When grep -c 'use-cases.qmd\|Foundations\|Composition' _quarto.yml runs
    Then the count is 0
  Scenario: New parts present in order
    When grep -n 'part:' _quarto.yml runs
    Then the parts appear in the order: Your first app, Writing formulas, Custom placeholders, ggpaintr in your own Shiny app, Making it yours, Sharing & advanced, Gallery
```

**Definition of Done:** global DoD.

## Step 3 — Dissolve `use-cases.qmd`

**Success Criteria**

- Levels table + three-levels framing → `introduction.qmd` (step 1).
- String-form example (chunk `use-cases-app-basic`) → `formula-language.qmd`, byte-identical chunk body, slug unchanged.
- Chrome tour (chunk `use-cases-layers`) → new section in `getting-started.qmd` after "Your first app"; own-data section (chunk `use-cases-nonsyntactic`, `ptr_normalize_column_names()`) → `getting-started.qmd` "Using your own data" section.
- Pointer paragraphs ("Several plots in one app", "A different shell or theme") deleted, not moved.
- `use-cases.qmd` deleted. Every `@sec-use-cases` reference retargeted: ladder/levels mentions (`llm.qmd:7`, `gallery.qmd:546`, `cheatsheet.qmd:26,30`, `multi-plot.qmd:56`) → `@sec-intro`; normalize-columns mentions (`gallery.qmd:450`, `cheatsheet.qmd:75`) → `@sec-getting-started`.

**Constraints**

- Fixture slugs `use-cases-*` and their screenshots are NOT renamed — chunks move with slugs intact, so no re-shooting.
- Chunk bodies stay byte-identical to their fixture marker blocks (gate Verbatim check).

**BDD**

```gherkin
Feature: use-cases.qmd dissolves without dangling references
  Scenario: No orphan references
    Given use-cases.qmd is deleted
    When grep -rn 'sec-use-cases' --include='*.qmd' . runs
    Then it prints nothing
  Scenario: Moved chunks still match fixtures
    When Rscript dev/book-gate.R runs
    Then Verbatim reports M/M with the three use-cases-* chunks counted in their new files
```

**Interface Contract**

Move map (chunk slug → destination; each chunk body stays byte-identical to its fixture markers):

| Slug | From | To |
|---|---|---|
| `use-cases-app-basic` | use-cases.qmd | formula-language.qmd |
| `use-cases-layers` | use-cases.qmd | getting-started.qmd (chrome-tour section) |
| `use-cases-nonsyntactic` | use-cases.qmd | getting-started.qmd ("Using your own data" section) |

Reference retarget map (exhaustive — verified by grep on 2026-06-11): `llm.qmd:7`, `gallery.qmd:546`, `cheatsheet.qmd:26`, `cheatsheet.qmd:30`, `multi-plot.qmd:56` → `@sec-intro`; `gallery.qmd:450`, `cheatsheet.qmd:75` → `@sec-getting-started`. Rejected: any surviving `@sec-use-cases` string; any fixture slug rename. Worked example: `grep -rc 'sec-use-cases' --include='*.qmd' . | grep -v ':0'` → no output; `grep -c 'fixture: use-cases-' getting-started.qmd` → `2`.

**Definition of Done:** global DoD, plus `test ! -f use-cases.qmd` and the orphan-reference grep above printing nothing.

## Step 4 — Split `custom-placeholders.qmd` into three ramped chapters

**Success Criteria**

- Chapter 6 `custom-placeholders.qmd` ("Your first custom placeholder", keeps `{#sec-custom-placeholders}`): a genuinely minimal value placeholder — `keyword` + `build_ui` + `resolve_expr` only — backed by a NEW fixture `custom-minimal` (+ screenshot via `dev/book-shoot.R custom-minimal`). *(Audit fix 2026-06-11: the existing `custom-value` fixture is the every-argument example — it contains `validate_session_input`, `parse_named_args`, `embellish_eval` — so it cannot anchor the minimal chapter without violating the ramp BDD below.)*
- Chapter 7 `custom-consumer-source.qmd` (`{#sec-custom-consumer-source}`): consumer and source deltas; fixtures `custom-consumer`, `custom-source` move here with chunks byte-identical.
- Chapter 8 `hook-contract.qmd` (`{#sec-hook-contract}`): all hooks in full (`validate_session_input`, `parse_positional_arg`, `parse_named_args`, `embellish_eval`, `ui_text_defaults`, …); the existing every-argument `custom-value` chunk moves here as the worked example; common pitfalls; unregistering.
- Existing `@sec-custom-placeholders` references audited one by one: those meaning "make your own placeholder" stay; those meaning the full hook contract (e.g. `gallery.qmd:548`) re-point to `@sec-hook-contract`.

**Constraints**

- No fixture renames; `custom-value`, `custom-consumer`, `custom-source` keep their slugs and screenshots (they only change host file).
- Ramp rule: chapter 6 must not mention hooks beyond the three it teaches; forward-reference `@sec-hook-contract` instead.
- The new `custom-minimal` fixture must boot against the installed pinned ggpaintr; iterate on the fixture until `dev/book-gate.R`'s boot stage accepts it before writing the chapter prose around it.

**Interface Contract**

- `custom-placeholders.qmd` — surface: H1 keeps `{#sec-custom-placeholders}`; exactly one fixture-bound chunk (`custom-minimal`) whose marker block calls `ptr_define_placeholder_value()` with only `keyword`, `build_ui`, `resolve_expr`; at least one forward ref each to `@sec-custom-consumer-source` and `@sec-hook-contract`. Rejected: any of `validate_session_input|parse_positional_arg|parse_named_args|embellish_eval|ui_text_defaults` appearing in this file. Worked example: `grep -cE 'validate_session_input|parse_named_args|embellish_eval|ui_text_defaults|parse_positional_arg' custom-placeholders.qmd` → `0`; `grep -c 'fixture: custom-minimal' custom-placeholders.qmd` → `1`.
- `custom-consumer-source.qmd` — surface: anchor `{#sec-custom-consumer-source}`; two fixture-bound chunks (`custom-consumer`, `custom-source`), bodies byte-identical to their existing marker blocks. Worked example: `grep -c 'fixture: custom-' custom-consumer-source.qmd` → `2`.
- `hook-contract.qmd` — surface: anchor `{#sec-hook-contract}`; one fixture-bound chunk (`custom-value`, body unchanged); one section per hook name listed above; sections "Common pitfalls" and "Unregistering" preserved from the original chapter. Worked example: `grep -c 'fixture: custom-value' hook-contract.qmd` → `1`.
- `tests/fixtures/book-apps/custom-minimal/app.R` — same fixture surface as the intro-hero contract in step 1 (harness header, one marker block, boots headless, screenshot + `.sha` sidecar).

**BDD**

```gherkin
Feature: Custom placeholders teach in a ramp
  Scenario: First chapter is minimal
    When grep -c 'embellish_eval\|parse_named_args\|validate_session_input' custom-placeholders.qmd runs
    Then the count is 0
  Scenario: Anchors resolve
    When quarto render runs
    Then no unresolved-crossref warning mentions sec-custom-placeholders, sec-custom-consumer-source, or sec-hook-contract
```

**Definition of Done:** global DoD.

## Step 5 — Part II reorder + per-part Shiny prerequisite + front-matter trim

**Success Criteria**

- Part II order placeholders → formula-language → generated-code (done in step 2's yml); `placeholders.qmd`'s pipeline section keeps one forward reference to `@sec-formula-language`; `getting-started.qmd`'s "Where to go next" list updated to the new order and to `@sec-intro`.
- `embed-default.qmd` opens with a one-paragraph callout: this part assumes Shiny basics (`fluidPage`, server functions, modules by id); earlier parts do not.
- `index.qmd` "Who this is for" reads ggplot2-only (no Shiny prerequisite book-wide); the pitch sentence moves to `introduction.qmd`; version-pin and how-examples-work sections stay.
- Project `CLAUDE.md`: "Advanced topics" mention updated to "Sharing & advanced"; the shinylive would-be-heroes note gains `introduction.qmd` alongside `getting-started.qmd`/`formula-language.qmd` (still screenshot-only, `Shinylive: 0/0`).

**Constraints**

- Do not edit `docs/adr/0002-hybrid-display.md` — the fallback rule already covers the new chapter.
- `index.qmd` keeps the pinned install snippet untouched.

**BDD**

```gherkin
Feature: Prerequisites are honest per part
  Scenario: Book-wide gate is ggplot2 only
    When grep -i 'shiny' index.qmd runs
    Then no line states Shiny as a reader prerequisite
  Scenario: Embedding part states its prerequisite
    When grep -ic 'assumes.*shiny\|shiny basics' embed-default.qmd runs
    Then the count is at least 1
```

**Definition of Done:** global DoD.

---

## Sequencing & PR shape

Steps 1–4 are one atomic PR on branch `book-reorg-adr-0003` (the book does not render between them); step 5 rides along as its own commit. Order of work inside the PR: fixtures+shoot (`intro-hero`, `custom-minimal`) → introduction.qmd (1) → yml (2) → moves/deletes (3) → split (4) → trims (5) → gate → render → push. One commit per step. CI must run the gate (already wired in `publish.yml`) against pin `1a28cec`.

## Out of scope

- Any change to `../ggpaintr/` (cross-repo rule), to the pin, or to fixture slugs/screenshots other than the two new fixtures (`intro-hero`, `custom-minimal`).
- Rewriting chapter prose beyond what the moves/splits require (deeper rewrites of placeholders/formula-language are a later pass).
- Shinylive heroes (still NO-GO per `dev/notes/2026-06-10-shinylive-spike.md`).

Anything discovered mid-implementation that falls outside these steps (a stale claim in a chapter, a package bug, a broken screenshot unrelated to the moves) is surfaced as a follow-up note in the PR description — never silently fixed in this branch and never silently dropped.

<!-- implementable: PASS date=2026-06-11 gate="Rscript dev/book-gate.R" hash=c135a5622eeb -->
