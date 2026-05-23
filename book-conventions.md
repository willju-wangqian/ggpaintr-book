# Book conventions

The authoritative process doc is [`dev/plans/book-workflow.md`](dev/plans/book-workflow.md). This file documents the chunk-level rules a chapter author actually types.

## The Shiny rendering problem (read first)

ggpaintr's primary output is a **running Shiny app**, not a static plot. A book chapter cannot embed a live app the way the ggplot2 book embeds a plot. Every chunk that depicts a running app follows this convention.

1. **Show code verbatim, do not execute it.** The book default is `eval: false` (see `_quarto.yml`).
2. **Bind the chunk to a fixture.** Add `#| fixture: <slug>` to the chunk header. Create `tests/fixtures/book-apps/<slug>/app.R` with a `>>>` / `<<<` marker block whose contents are byte-identical to the chunk body. The marker block is the convention stolen from the package's `tests/testthat/helper-vignette-apps.R`.
3. **Show the running UI as a screenshot at `images/<slug>.png`.** Generate it with `Rscript dev/book-shoot.R <slug>` — this also writes the `images/<slug>.png.sha` pair-hash sidecar.
4. **Re-shoot whenever the fixture changes.** A fixture edit without re-shoot makes `Rscript dev/book-gate.R` fail with `Screenshots: FAIL`.
5. **Static output is fine to evaluate.** The generated ggplot2 code string, the formula→widget mapping table, and any plain R (non-Shiny) helper output may set `#| eval: true` per-chunk — only the app launch is non-evaluable.

## Chunk patterns

App chunk bound to a fixture:

````markdown
```{r}
#| eval: false
#| fixture: getting-started-hero
ptr_app("ggplot(iris, aes(var, var)) + geom_point()")
```

![The generated app: two variable pickers and the plot.](images/getting-started-hero.png)
````

The corresponding fixture (`tests/fixtures/book-apps/getting-started-hero/app.R`):

```r
# Boot harness lines (load_all, options, etc.) go here, outside the marker block.
# >>>
ptr_app("ggplot(iris, aes(var, var)) + geom_point()")
# <<<
```

Static output chunk:

````markdown
```{r}
#| eval: true
ptr_extract_code("ggplot(mtcars, aes(mpg, hp)) + geom_point()")
```
````

Hero chapter (shinylive — initially limited to `getting-started.qmd` and `formula-language.qmd`; see [ADR 0002](docs/adr/0002-hybrid-display.md)):

```yaml
---
title: "Getting Started"
shinylive: true
---
```

then per-chunk:

````markdown
```{shinylive-r}
#| standalone: true
ptr_app("ggplot(iris, aes(var, var)) + geom_point()")
```
````

## Adding a chapter

1. Create `<name>.qmd` with a single `#` H1 title and a callout-note placeholder.
2. Add it to the `chapters:` list in `_quarto.yml` under the right part.
3. Follow the chunk rules above. For each fixture-backed chunk: create the fixture, run `Rscript dev/book-shoot.R <slug>`, run `Rscript dev/book-gate.R`, then `quarto preview` to check locally before pushing.

## Relationship to the package

This repo is **separate** from the ggpaintr package (the ggplot2-book / ggplot2 model). It pins ggpaintr in `DESCRIPTION`'s Remotes to a specific SHA or tag — never a moving branch. When package behavior changes that affects the book, bump the pin in a PR and re-run the gate; see [`dev/plans/book-workflow.md`](dev/plans/book-workflow.md) § "Pin policy & reader-facing version".

The book owns its own fixtures (see [ADR 0001](docs/adr/0001-book-owns-fixtures.md)). The package's vignettes shrink to minimal `ggpaintr-use-cases` + `ggpaintr-gallery`; book chapters absorb the rest. Migration is per-vignette and paired across both repos — see the workflow doc § "Cross-repo vignette migration".
