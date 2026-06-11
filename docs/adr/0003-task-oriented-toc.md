# ADR 0003 — Task-oriented table of contents; custom placeholders as a core topic; gallery as terminal reference

- **Status:** Accepted, 2026-06-10
- **Authoritative gate:** `Rscript dev/book-gate.R`

## Context

The original ToC (Foundations / Use cases & gallery / Composition / Embedding / Extension / Advanced) organized chapters by package mechanism, not by reader goal. It had three concrete problems: (a) no motivation chapter — a reader with zero ggpaintr knowledge got housekeeping (`index.qmd`) and then mechanics (`getting-started.qmd`) with no "why should I care"; (b) a dependency inversion — the Composition part (multi-plot, shared-placeholders) preceded the Embedding part that teaches the `ptr_ui()`/`ptr_server()` machinery multi-plot requires; (c) custom placeholders — a prerequisite for several Gallery examples and a major part of the package's value — were shelved in the last content part ("Extension"), while the Gallery that uses them sat mid-book.

## Decision

The book is reorganized around **reader tasks**, with three structural commitments:

1. **Task-oriented spine.** Parts are named after what the reader wants to do (first app, writing formulas, your own placeholders, ggpaintr in your own Shiny app, making it yours, sharing & advanced), not after package levels or mechanisms. The L1/L2/L3 ladder remains vocabulary inside chapters and the Introduction's roadmap table, but does not name parts.
2. **Custom placeholders are a core topic, not an extension.** They get their own part directly after the formula part, split into three ramped chapters (first custom placeholder → consumer & source → hook contract).
3. **Gallery is terminal reference.** It is the final content part — "more examples", pointed to from earlier chapters, all of its cross-references pointing backward.

Supporting decisions: the book-wide prerequisite drops to ggplot2 only (Shiny becomes a per-part prerequisite stated at the embedding part); a new Introduction chapter carries the pitch (new hero fixture), the levels roadmap, and a custom-placeholder teaser; `use-cases.qmd` dissolves into Introduction / getting-started / formula-language.

## Alternatives considered

- **L1→L2→L3 ladder as the spine.** Parts ordered by level of control; the Shiny prerequisite falls out exactly at the L2 boundary. Rejected: part names like "L2" describe the package's architecture, not the reader's goal; the levels stay as in-chapter vocabulary instead.
- **Gallery early (right after Getting Started) for fast payoff.** Rejected: three Gallery examples define custom placeholders (`ppRange`, `ppVars`, `ppPercent`) inline, so the reader would meet constructor code before understanding it; and the Gallery's job is lookup, not teaching.
- **Splitting the Gallery** into a built-ins-only early gallery and a custom-powered late gallery. Rejected: doubles fixture/screenshot churn and dilutes the single lookup destination.
- **Keeping `use-cases.qmd`** as a renamed front-matter chapter. Rejected: its roadmap job moves to the Introduction; keeping both duplicates it.

## Consequences

- `use-cases.qmd` is deleted; all `@sec-use-cases` references retarget to the Introduction (ladder/roadmap mentions) or `@sec-getting-started` (the `ptr_normalize_column_names()` recipe, which moves there).
- `custom-placeholders.qmd` splits into three files; the `#sec-custom-placeholders` anchor stays on the first to keep existing references valid, and hook-contract references re-point to the new reference chapter.
- One new fixture (the Introduction hero) joins `tests/fixtures/book-apps/`; all other fixture slugs and screenshots are unchanged because chunks move between files with their slugs.
- The project `CLAUDE.md` mention of the "Advanced topics" part must track the new part names.
