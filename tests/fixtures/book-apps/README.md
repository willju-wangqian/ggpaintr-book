# book-apps fixtures

Each subdirectory is one self-contained Shiny app, named for its slug. Chunks in the `.qmd` chapters tagged `#| fixture: <slug>` are byte-identical to the `>>> ... <<<` marker block inside `<slug>/app.R`. The convention is taken from the ggpaintr package's `tests/testthat/helper-vignette-apps.R`.

The `Rscript dev/book-gate.R` command exercises each fixture and the matching chunk. To re-shoot the screenshot after editing a fixture, run `Rscript dev/book-shoot.R <slug>` — that also rewrites the `images/<slug>.png.sha` pair-hash sidecar so the gate sees the screenshot as fresh.

See [`../../dev/plans/book-workflow.md`](../../dev/plans/book-workflow.md) for the full workflow and [`../../docs/adr/0001-book-owns-fixtures.md`](../../docs/adr/0001-book-owns-fixtures.md) for the rationale.
