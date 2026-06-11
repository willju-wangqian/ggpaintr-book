# ggpaintr Book

The user-facing Quarto book for ggpaintr. This context covers the language used to talk about the book's audience, structure, and content rules — not the package's internals.

## Language

**Reader**:
The book's assumed audience: an R user fluent in ggplot2, with **no** ggpaintr knowledge and **no** Shiny knowledge assumed.
_Avoid_: "user" (ambiguous — could mean the app's end user), "developer"

**Per-part prerequisite**:
A skill requirement stated at the start of a book part rather than book-wide; Shiny basics is one (required only from the Embedding part onward).

**Level (L1/L2/L3)**:
The package's three tiers of control — L1 `ptr_app()` all-in-one, L2 `ptr_ui()`/`ptr_server()` embedding, L3 bare UI pieces. Vocabulary only, **not** the book's structure.

**Task-oriented spine**:
The book's organizing principle (decided 2026-06-10): parts are named after Reader goals ("build an app", "embed in your own app", …), not after package levels or mechanisms. Chapter order must still respect concept dependencies (e.g. multi-plot requires `ptr_ui()`/`ptr_server()` to be taught first).

**Gallery**:
A near-the-end collection of complete worked examples — "more examples of ggpaintr", a lookup resource, not a teaching chapter. Earlier chapters (esp. the custom-placeholders part) point forward to it.

**Custom placeholders**:
A first-class core topic with its own dedicated part directly after the formula part — not "Extension" material. Decided 2026-06-10: it is a major part of ggpaintr's value and a prerequisite for several Gallery examples.

**Introduction**:
The new chapter 1 — the pitch for a Reader with zero ggpaintr knowledge: hero before/after demo, the L1/L2/L3 roadmap, a custom-placeholder teaser, and when-not-to-use.

## Relationships

- The **Reader** can complete every chapter before the embedding part without Shiny knowledge.
- L2 and L3 chapters carry a Shiny **per-part prerequisite**.
- The **Gallery** depends on **Custom placeholders** (three examples define `ppRange`, `ppVars`, `ppPercent` inline), so the custom-placeholders part precedes it.
- Structure decisions are recorded in [ADR 0003](docs/adr/0003-task-oriented-toc.md); the implementation plan is [`dev/plans/book-reorg.md`](dev/plans/book-reorg.md).

## Example dialogue

> **Dev:** "Should the embedding part come before custom placeholders, since L2 is 'lower-level' than extending?"
> **Domain expert:** "Levels are vocabulary, not structure — the **task-oriented spine** decides. Custom placeholders are core day-one value for the **Reader**, so they come right after formulas; embedding waits because it's the first part with a Shiny **per-part prerequisite**."

## Flagged ambiguities

- "Readers who know ggplot2 and Shiny basics" (`index.qmd`) conflicted with the L1 path needing no Shiny — resolved 2026-06-10: book-wide prerequisite is ggplot2 only; Shiny is a per-part prerequisite for Embedding/Extension.
