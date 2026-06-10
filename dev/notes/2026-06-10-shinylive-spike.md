# Shinylive feasibility spike — verdict: NO-GO (M1)

Decision per `dev/plans/finish-the-book.md` § M1. Heroes (`getting-started.qmd`, `formula-language.qmd`) are authored screenshot-only under ADR 0002's fallback rule; no chapter sets `shinylive: true`; the gate truthfully reports `Shinylive: 0/0 hero demos compile`.

## Evidence

A `{shinylive-r}` chunk runs under webR in the reader's browser, which can only load packages that exist as wasm binaries (webR's CRAN-mirror repo or an r-universe with wasm builds). Checked 2026-06-10:

1. **Not on CRAN.** `"ggpaintr" %in% rownames(available.packages(repos = "https://cloud.r-project.org"))` → `FALSE`. A CRAN submission exists package-side (`CRAN-SUBMISSION`: v0.9.0, 2026-04-28, SHA 838c43f) but has not been accepted.
2. **Not in the author's r-universe.** `https://willju-wangqian.r-universe.dev/api/packages` lists only `cmpsR`; `https://willju-wangqian.r-universe.dev/ggpaintr/json` → "Package ggpaintr not found in willju-wangqian".
3. **No wasm binary.** `https://repo.r-wasm.org/.../ggpaintr_*.tgz` → HTTP 403 (absent).

So webR cannot install ggpaintr at all today. The chunk would render at `quarto render` time (the bundling step succeeds without the package) and then fail in the reader's browser at app boot — the worst kind of failure: invisible to CI, visible to every reader. This is the proxy trap named in M1's DoD.

## Why a future GO is harder than it looks

Even after adding ggpaintr to r-universe (which would build wasm), r-universe builds the repo HEAD — a moving target. The book pins `76a4126`; a hero widget running HEAD-of-main while the prose documents the pin violates the truthfulness contract the gate exists to enforce. A GO needs a wasm build *of the pinned ref* (e.g. wasm artifacts built in CI at the pin and served with the book), which is real infrastructure, not a toggle.

## Standing consequences

- `dev/book-gate.R::check_shinylive` stays a fail-closed stub: 0 heroes → PASS `0/0`; any `shinylive: true` chapter → FAIL until the check is implemented per the Interface Contract in the plan (M1 GO branch). Do not author a hero before that lands.
- Revisit trigger: ggpaintr accepted on CRAN **and** the book pin moved to that CRAN release tag, or a pinned-ref wasm pipeline exists.
