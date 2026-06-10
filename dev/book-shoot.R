#!/usr/bin/env Rscript
# book-shoot.R — capture a screenshot of a fixture and write its pair-hash sidecar.
#
# Usage:
#
#     Rscript dev/book-shoot.R <slug> [--update] [--code]
#
# --update clicks the app's "Update plot" button (input id ptr_update_plot)
#   before capturing, so seeded fixtures show a drawn plot instead of the
#   empty boot pane. --code additionally opens the generated-code window
#   (selector .ptr-code-toggle). Flags affect only the image; the pair-hash
#   sidecar always hashes the fixture's app.R.
#
# - Boots tests/fixtures/book-apps/<slug>/app.R in shinytest2 against a real
#   headless Chromium.
# - Captures images/<slug>.png.
# - Writes images/<slug>.png.sha containing SHA-256(tests/fixtures/book-apps/<slug>/app.R).
#
# After any edit to a fixture's app.R, re-run this script for that slug or the
# gate's Screenshots check will FAIL.

args <- commandArgs(trailingOnly = TRUE)
flags <- args[startsWith(args, "--")]
args  <- setdiff(args, flags)
if (length(args) != 1L) {
  stop("usage: Rscript dev/book-shoot.R <slug> [--update] [--code]", call. = FALSE)
}
slug <- args[[1]]
do_update <- "--update" %in% flags
do_code   <- "--code" %in% flags

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

if (!dir.exists("images")) dir.create("images")

# AppDriver$new() skips (-> errors outside testthat) unless NOT_CRAN is set.
Sys.setenv(NOT_CRAN = "true")

app <- NULL
on.exit(if (!is.null(app)) try(app$stop(), silent = TRUE), add = TRUE)
# "Failed to locate globals" warnings at AppDriver construction are benign
# (same construction-scoped suppression the package's e2e helper uses).
app <- suppressWarnings(shinytest2::AppDriver$new(
  app_dir      = dirname(fixture),
  name         = slug,
  load_timeout = 60 * 1000,
  timeout      = 30 * 1000,
  width        = 1200,
  height       = 900,
  view         = FALSE
))
app$wait_for_idle(timeout = 15 * 1000)
if (do_update) {
  app$click("ptr_update_plot")
  app$wait_for_idle(timeout = 15 * 1000)
}
if (do_code) {
  app$click(selector = ".ptr-code-toggle")
  app$wait_for_idle(timeout = 15 * 1000)
}
app$get_screenshot(file = image)

# ---- write pair-hash sidecar ----------------------------------------------

if (!requireNamespace("digest", quietly = TRUE)) {
  stop("digest required; install.packages('digest')", call. = FALSE)
}
hash <- digest::digest(file = fixture, algo = "sha256")
writeLines(hash, sha)

message(sprintf("[book-shoot] %s → %s  (sha256=%s)", fixture, image, substr(hash, 1, 12)))
