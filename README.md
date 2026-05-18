# ggpaintr book

Source for the **ggpaintr** book — a Quarto book, structured after the
[ggplot2 book](https://ggplot2-book.org/), covering ggpaintr's formula
language, placeholder system, the L1/L2/L3 embedding model, customization,
and internals.

This repository is **separate from the ggpaintr package** (the same way the
ggplot2 book is separate from ggplot2): independent versioning, build, and
deploy; it depends on a released/pinned ggpaintr rather than vendoring it.

## Build locally

```sh
quarto preview      # live-reloading local server
quarto render       # one-off build into _book/
```

Requires [Quarto](https://quarto.org) and R with the packages in
`DESCRIPTION` (notably `ggpaintr`). Note most example chunks are
`eval: false` by design — see `book-conventions.md` for *why* (ggpaintr
produces interactive Shiny apps that can't render statically) and the
screenshot/fixture convention every chapter follows.

## Deploy

`.github/workflows/publish.yml` renders and publishes to the `gh-pages`
branch on push to `main` (enable Settings → Pages → Source: `gh-pages`).
Inert until a GitHub remote + Pages are configured.

## Status

Scaffold + chapter stubs. See `_quarto.yml` for the planned structure and
`book-conventions.md` before authoring.
