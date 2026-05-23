#!/usr/bin/env Rscript
# book-gate.R — authoritative gate for the ggpaintr book.
#
# Runs five checks against the pinned ggpaintr:
#   - Boot:        every fixture under tests/fixtures/book-apps/ boots clean
#   - Verbatim:    every #| fixture: <slug> chunk == that fixture's >>> block
#   - Symbols:     every ptr_* token in .qmd resolves to a ggpaintr export
#   - Screenshots: every images/<slug>.png has a sidecar .sha matching the fixture's SHA-256
#   - Shinylive:   hero demos compile (heroes declared by `shinylive: true` in chapter YAML)
#
# Authoritative invocation:
#
#     Rscript dev/book-gate.R
#
# Exits 0 on `BOOK GATE: PASS`, non-zero otherwise.
#
# This is a skeleton: it implements the discovery, hashing, verbatim, and symbol
# checks fully; the Boot and Shinylive checks are stubbed in a way that returns
# success when no fixtures / no heroes are declared (so the gate is trivially
# green on an empty book) and fails loud when a fixture exists but the runtime
# pieces have not yet been wired. See dev/plans/book-workflow.md for the design.

suppressPackageStartupMessages({
  library(yaml)
  library(stringr)
})

book_root <- rprojroot::find_root(rprojroot::has_file("_quarto.yml"))
setwd(book_root)

QMD_FILES <- list.files(".", pattern = "\\.qmd$", full.names = FALSE)
FIXTURE_DIR <- "tests/fixtures/book-apps"
IMAGE_DIR   <- "images"

# ---- helpers ---------------------------------------------------------------

discover_fixtures <- function() {
  if (!dir.exists(FIXTURE_DIR)) return(character())
  slugs <- list.dirs(FIXTURE_DIR, recursive = FALSE, full.names = FALSE)
  slugs[file.exists(file.path(FIXTURE_DIR, slugs, "app.R"))]
}

discover_chunk_fixtures <- function(qmd_files) {
  # Returns a data frame: file, chunk_index, slug, body (chunk body lines).
  rows <- list()
  for (f in qmd_files) {
    lines <- readLines(f, warn = FALSE)
    in_chunk <- FALSE
    chunk_start <- NA_integer_
    chunk_opts <- character()
    chunk_body <- character()
    idx <- 0L
    for (i in seq_along(lines)) {
      line <- lines[[i]]
      if (!in_chunk && grepl("^```\\{r[ ,}]", line)) {
        in_chunk <- TRUE
        chunk_start <- i
        chunk_opts <- character()
        chunk_body <- character()
        next
      }
      if (in_chunk && grepl("^```\\s*$", line)) {
        slug <- extract_fixture_slug(chunk_opts)
        if (!is.na(slug)) {
          idx <- idx + 1L
          rows[[length(rows) + 1L]] <- data.frame(
            file = f, chunk_index = idx, slug = slug,
            body = paste(chunk_body, collapse = "\n"),
            stringsAsFactors = FALSE
          )
        }
        in_chunk <- FALSE
        next
      }
      if (in_chunk) {
        if (startsWith(trimws(line), "#|")) {
          chunk_opts <- c(chunk_opts, line)
        } else {
          chunk_body <- c(chunk_body, line)
        }
      }
    }
  }
  if (length(rows) == 0L) {
    return(data.frame(file = character(), chunk_index = integer(),
                      slug = character(), body = character(),
                      stringsAsFactors = FALSE))
  }
  do.call(rbind, rows)
}

extract_fixture_slug <- function(opt_lines) {
  m <- regmatches(opt_lines, regexpr("(?<=#\\|\\s)fixture:\\s*\\S+", opt_lines, perl = TRUE))
  m <- m[lengths(m) > 0]
  if (length(m) == 0L) return(NA_character_)
  sub("^fixture:\\s*", "", m[[1]])
}

fixture_marker_block <- function(slug) {
  path <- file.path(FIXTURE_DIR, slug, "app.R")
  if (!file.exists(path)) return(NULL)
  lines <- readLines(path, warn = FALSE)
  start <- grep("^#\\s*>>>", lines)
  end   <- grep("^#\\s*<<<", lines)
  if (length(start) == 0L || length(end) == 0L) return(NULL)
  paste(lines[(start[[1]] + 1L):(end[[1]] - 1L)], collapse = "\n")
}

sha256_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("digest package required for screenshot pair-hash check")
  }
  digest::digest(file = path, algo = "sha256")
}

scan_ptr_tokens <- function(qmd_files) {
  # All ptr_* tokens referenced anywhere in .qmd (prose + code).
  tokens <- character()
  for (f in qmd_files) {
    lines <- readLines(f, warn = FALSE)
    m <- regmatches(lines, gregexpr("\\bptr_[A-Za-z0-9_]+", lines))
    tokens <- c(tokens, unlist(m))
  }
  unique(tokens)
}

# ---- checks ----------------------------------------------------------------

check_boot <- function(fixtures) {
  if (length(fixtures) == 0L) {
    return(list(pass = TRUE, msg = "0/0 fixtures booted", details = character()))
  }
  # TODO: wire shinytest2 boot here. For now, mark failed if any fixture exists
  # but the boot driver is not yet implemented, so we don't silently pass.
  list(
    pass = FALSE,
    msg = sprintf("0/%d fixtures booted (TODO: wire shinytest2 driver)", length(fixtures)),
    details = "dev/book-gate.R::check_boot not yet implemented; see dev/plans/book-workflow.md"
  )
}

check_verbatim <- function(chunk_df) {
  if (nrow(chunk_df) == 0L) {
    return(list(pass = TRUE, msg = "0/0 chunks match fixture markers", details = character()))
  }
  fails <- character()
  for (i in seq_len(nrow(chunk_df))) {
    row <- chunk_df[i, ]
    marker <- fixture_marker_block(row$slug)
    if (is.null(marker)) {
      fails <- c(fails, sprintf("%s chunk #%d slug=%s: fixture or marker block missing",
                                row$file, row$chunk_index, row$slug))
      next
    }
    if (!identical(trimws(row$body, which = "right"), trimws(marker, which = "right"))) {
      fails <- c(fails, sprintf("%s chunk #%d slug=%s: chunk body diverges from fixture marker",
                                row$file, row$chunk_index, row$slug))
    }
  }
  list(
    pass = length(fails) == 0L,
    msg = sprintf("%d/%d chunks match fixture markers",
                  nrow(chunk_df) - length(fails), nrow(chunk_df)),
    details = fails
  )
}

check_symbols <- function(qmd_files) {
  tokens <- scan_ptr_tokens(qmd_files)
  if (length(tokens) == 0L) {
    return(list(pass = TRUE, msg = "0 ptr_* refs resolve", details = character()))
  }
  exports <- tryCatch(getNamespaceExports("ggpaintr"), error = function(e) NULL)
  if (is.null(exports)) {
    return(list(pass = FALSE,
                msg = sprintf("%d ptr_* refs found, ggpaintr not installed", length(tokens)),
                details = "install ggpaintr at the pinned SHA before running the gate"))
  }
  unknown <- setdiff(tokens, exports)
  list(
    pass = length(unknown) == 0L,
    msg = sprintf("%d ptr_* refs resolve", length(tokens) - length(unknown)),
    details = if (length(unknown)) sprintf("unknown symbols: %s",
                                            paste(unknown, collapse = ", ")) else character()
  )
}

check_screenshots <- function(fixtures) {
  if (length(fixtures) == 0L) {
    return(list(pass = TRUE, msg = "0/0 pair-hashes match", details = character()))
  }
  fails <- character()
  for (slug in fixtures) {
    img <- file.path(IMAGE_DIR, paste0(slug, ".png"))
    sha <- paste0(img, ".sha")
    if (!file.exists(img)) {
      fails <- c(fails, sprintf("%s: missing screenshot at %s (run: Rscript dev/book-shoot.R %s)", slug, img, slug))
      next
    }
    if (!file.exists(sha)) {
      fails <- c(fails, sprintf("%s: missing sidecar %s (run: Rscript dev/book-shoot.R %s)", slug, sha, slug))
      next
    }
    actual <- sha256_file(file.path(FIXTURE_DIR, slug, "app.R"))
    expected <- trimws(readLines(sha, warn = FALSE)[[1]])
    if (!identical(actual, expected)) {
      fails <- c(fails, sprintf("%s: pair-hash mismatch — fixture edited without re-shoot (run: Rscript dev/book-shoot.R %s)", slug, slug))
    }
  }
  list(
    pass = length(fails) == 0L,
    msg = sprintf("%d/%d pair-hashes match", length(fixtures) - length(fails), length(fixtures)),
    details = fails
  )
}

check_shinylive <- function(qmd_files) {
  heroes <- character()
  for (f in qmd_files) {
    lines <- readLines(f, warn = FALSE)
    yaml_end <- grep("^---\\s*$", lines)
    if (length(yaml_end) >= 2L && yaml_end[[1]] == 1L) {
      fm <- tryCatch(yaml::yaml.load(paste(lines[2:(yaml_end[[2]] - 1L)], collapse = "\n")),
                     error = function(e) NULL)
      if (isTRUE(fm$shinylive)) heroes <- c(heroes, f)
    }
  }
  if (length(heroes) == 0L) {
    return(list(pass = TRUE, msg = "0/0 hero demos compile", details = character()))
  }
  list(
    pass = FALSE,
    msg = sprintf("0/%d hero demos compile (TODO: wire shinylive compile)", length(heroes)),
    details = "dev/book-gate.R::check_shinylive not yet implemented"
  )
}

# ---- runner ----------------------------------------------------------------

main <- function() {
  fixtures <- discover_fixtures()
  chunk_df <- discover_chunk_fixtures(QMD_FILES)
  results <- list(
    Boot        = check_boot(fixtures),
    Verbatim    = check_verbatim(chunk_df),
    Symbols     = check_symbols(QMD_FILES),
    Screenshots = check_screenshots(fixtures),
    Shinylive   = check_shinylive(QMD_FILES)
  )
  pad <- max(nchar(names(results)))
  for (nm in names(results)) {
    r <- results[[nm]]
    cat(sprintf("%-*s %s\n", pad + 1L, paste0(nm, ":"), r$msg))
    for (d in r$details) cat("  - ", d, "\n", sep = "")
  }
  all_pass <- all(vapply(results, function(r) isTRUE(r$pass), logical(1)))
  cat(sprintf("BOOK GATE: %s\n", if (all_pass) "PASS" else "FAIL"))
  if (!all_pass) quit(status = 1L)
}

main()
