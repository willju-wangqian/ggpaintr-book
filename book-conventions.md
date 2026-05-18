# Book conventions

## The Shiny rendering problem (read first)

ggpaintr's primary output is a **running Shiny app**, not a static plot. A book chapter cannot embed a live app the way the ggplot2 book embeds a plot. Every chapter must therefore follow this convention:

1. **Show code verbatim, do not execute it.** The book default is `eval: false` (see `_quarto.yml`). Author example chunks as plain shown code.
2. **Show the running UI as an image.** Put a screenshot or GIF in `images/` and reference it right after the code. Capture at a consistent window size.
3. **Keep examples in sync with a tested fixture.** Do not hand-write app code that no one runs — it bit-rots. Mirror the ggpaintr package's existing discipline: the package keeps `tests/testthat/fixtures/vignette-apps/<slug>/app.R` *verbatim-equivalent* to each documented chunk and exercises it with an e2e test. Book examples should be the same code, ideally lifted from (or pinned by) such a fixture, so "what you read" provably "is what runs".
4. **Static output is fine to evaluate.** The generated ggplot2 code string, the formula→widget mapping table, and any plain R (non-Shiny) helper output may use `eval: true` per-chunk — only the app launch is non-evaluable.

Recommended chunk patterns:

```r
#| eval: false
ptr_app("ggplot(iris, aes(var, var)) + geom_point()")
```

then:

```markdown
![The generated app: two variable pickers and the plot.](images/getting-started-basic.png)
```

For static output, override locally:

````markdown
```{r}
#| eval: true
ptr_extract_code("ggplot(mtcars, aes(mpg, hp)) + geom_point()")
```
````

## Adding a chapter

1. Create `<name>.qmd` with a single `#` H1 title.
2. Add it to the `chapters:` list in `_quarto.yml` under the right part.
3. Follow the rendering convention above.
4. `quarto preview` to check locally before pushing.

## Relationship to the package

This repo is **separate** from the ggpaintr package (the ggplot2-book / ggplot2 model). It pins ggpaintr via `DESCRIPTION` `Remotes:` / install instructions. When package behavior changes, update the affected chapter *and* its backing fixture in the package repo in the same logical change.
