# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
.env <- environment()   # the scope whose data frames should be loadable

ptr_define_placeholder_source(
  keyword  = "ppDataset",
  shortcut = TRUE,

  build_ui = function(node, label = NULL, ...) {
    # env-name-only source: the framework's shortcut text box is the sole
    # entry point, so build_ui contributes no widget of its own.
    NULL
  },

  resolve_data = function(value, node, ...) {
    nm <- if (is.character(value) && length(value) == 1L && nzchar(value)) value else NULL
    if (is.null(nm)) return(NULL)
    tryCatch(get(nm, envir = .env, inherits = TRUE),
             error = function(e) NULL)
  },

  resolve_expr     = function(value, node, ...) rlang::sym(value),
  ui_text_defaults = list(label = "Dataset for {param}")
)

ptr_app(
  ppDataset() |> ggplot(aes(x = ppVar("mpg"))) + geom_histogram()
)
# <<<
