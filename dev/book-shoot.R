#!/usr/bin/env Rscript
# book-shoot.R — capture a screenshot of a fixture and write its pair-hash sidecar.
#
# Usage:
#
#     Rscript dev/book-shoot.R <slug>
#
# - Boots tests/fixtures/book-apps/<slug>/app.R in shinytest2 against a real
#   headless Chromium.
# - Captures images/<slug>.png.
# - Writes images/<slug>.png.sha containing SHA-256(tests/fixtures/book-apps/<slug>/app.R).
#
# After any edit to a fixture's app.R, re-run this script for that slug or the
# gate's Screenshots check will FAIL.
#
# Skeleton: the boot/screenshot path is left as TODO until the first fixture
# lands. The hashing path is fully implemented so the verbatim-discipline
# scaffolding works even before shinytest2 wiring is complete.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("usage: Rscript dev/book-shoot.R <slug>", call. = FALSE)
}
slug <- args[[1]]

book_root <- rprojroot::find_root(rprojroot::has_file("_quarto.yml"))
setwd(book_root)

fixture <- file.path("tests/fixtures/book-apps", slug, "app.R")
image   <- file.path("images", paste0(slug, ".png"))
sha     <- paste0(image, ".sha")

if (!file.exists(fixture)) {
  stop(sprintf("fixture not found: %s", fixture), call. = FALSE)
}

# ---- capture screenshot ----------------------------------------------------

if (!requireNamespace("shinytest2", quietly = TRUE)) {
  stop("shinytest2 required; install.packages('shinytest2')", call. = FALSE)
}

# TODO: real shinytest2 capture. Pseudocode:
#
#   app <- shinytest2::AppDriver$new(
#     app_dir = dirname(fixture),
#     name    = slug,
#     load_timeout = 30 * 1000
#   )
#   on.exit(app$stop(), add = TRUE)
#   Sys.sleep(0.5)                                     # let initial render settle
#   app$get_screenshot(file = image)
#
# Until that lands, we touch a placeholder so the sidecar / pair-hash flow
# remains exercisable.

if (!dir.exists("images")) dir.create("images")
if (!file.exists(image)) {
  message(sprintf("[book-shoot] TODO: real shinytest2 capture; writing placeholder PNG at %s", image))
  png::writePNG(matrix(1, nrow = 1, ncol = 1), target = image)
}

# ---- write pair-hash sidecar ----------------------------------------------

if (!requireNamespace("digest", quietly = TRUE)) {
  stop("digest required; install.packages('digest')", call. = FALSE)
}
hash <- digest::digest(file = fixture, algo = "sha256")
writeLines(hash, sha)

message(sprintf("[book-shoot] %s → %s  (sha256=%s)", fixture, image, substr(hash, 1, 12)))
