# ADR 0002 — Hybrid display: shinylive on hero demos, screenshots elsewhere

- **Status:** Accepted, 2026-05-23
- **Authoritative gate:** `Rscript dev/book-gate.R` (shinylive build is one of the five checks)

## Context

ggpaintr's primary output is a running Shiny app, which a static HTML book cannot embed verbatim. Three commitments could be made for what a reader sees in the rendered book:

1. **All chapters embed live apps** via shinylive (WebAssembly Shiny in the browser).
2. **All chapters show only verbatim code + screenshot/GIF**, no interactivity.
3. **Hybrid**: a small number of marquee chapters embed live shinylive widgets; the rest use the screenshot pattern.

The user's stated aspiration is "if we can embed shiny apps in the book html, that would be great." This is an aspiration, not a commitment.

Cost analysis (numbers approximate, drawn from shinylive docs and community reports — not measured against ggpaintr's stack):

| Mode | Reader load | Build cost | Hosting | Failure mode |
|---|---|---|---|---|
| All-shinylive | ~50-80MB webR runtime, cached after first chapter | Multiple minutes added to `quarto render` | $0 (static) | Any webR-incompatible dep nukes the whole book |
| Hybrid | webR load only on hero chapters | +30-60s per shinylive chapter | $0 | A broken hero degrades to a screenshot, others unaffected |
| All-screenshot | <1s per chapter | ~10s whole book | $0 | Silent staleness without pair-hash discipline |
| Hosted iframes | 10-30s cold start per chapter | ~0 | ~$15-99/mo shinyapps.io once you exceed 5 apps | Suspended apps → broken iframes |

ggpaintr leans on `shinyWidgets`, `bslib`, `plotly`, `ggiraph`. File upload via the OS picker and some plotly/ggiraph custom-render flows are the known shinylive hazards; whether every dep has a current webR build is unverified at decision time.

## Decision

**Hybrid display.** One to two chapters host shinylive widgets — initial candidates are `getting-started.qmd` (the first user-visible "play with it" moment) and the formula-language playground in `formula-language.qmd`. Every other chapter follows the existing verbatim-code + screenshot/GIF pattern with pair-hash discipline (ADR 0001).

Hero selection is driven by **reader value**, not coverage. A chapter is a hero if a reader benefits materially from poking at sliders, not because shinylive technically works there.

A hero chapter that turns out to be webR-incompatible (missing dep build, file upload, etc.) falls back to the screenshot pattern without breaking neighboring chapters or the gate.

## Alternatives considered

- **All-shinylive.** Rejected because (a) ggpaintr's webR closure is not fully verified; (b) any one missing dep degrades every chapter, not just one; (c) build time per chapter compounds across ~15 chapters; (d) some examples (upload, plotly) likely cannot work in webR at all and would force ugly per-chapter exceptions everywhere.
- **All-screenshot, no live.** Rejected because it permanently drops a stated aspiration and gives up an easy-to-add reader win on the chapters that would benefit most. The existing screenshot infrastructure is the *base* of the hybrid; no work is lost by adding shinylive on top.
- **Hosted iframes (shinyapps.io).** Rejected because of recurring dollar cost ($15-99/mo per the public plan tiers), per-app deployment automation, cold-start latency at every read, and the "suspended app → broken iframe" failure mode that no gate can catch from the book repo alone.

## Consequences

- Two display patterns coexist; contributors must know which a chapter uses. Mitigation: a hero chapter is marked with a YAML key in its front-matter; the gate enumerates heroes from that.
- Shinylive's `quarto-ext/shinylive` extension is added to the book repo as a dependency.
- The gate's `Shinylive: H/H` line surfaces the hero count explicitly; H=0 is a legal state (no heroes wired yet).
- A reader on a constrained network can still consume the book — heroes are the exception, not the gate.
- Re-evaluating display mode later is cheap if hybrid proves wrong: removing shinylive degrades to all-screenshot with no data loss; promoting more chapters to heroes is additive.
