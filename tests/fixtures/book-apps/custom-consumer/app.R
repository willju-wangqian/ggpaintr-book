# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(dplyr)
# >>>
colvars <- ptr_define_placeholder_consumer(
  keyword = "colvars",

  build_ui = function(node, cols = character(), data = NULL,
                      label = NULL, selected = character(0), ...) {
    shiny::selectInput(
      node$id, label = label %||% "Columns",
      choices  = cols,
      selected = intersect(selected, cols),  # keep only still-valid picks
      multiple = TRUE
    )
  },

  resolve_expr = function(value, node, ...) {
    if (length(value) == 0L) return(NULL)
    rlang::call2("c", !!!as.list(value))   # c(col1, col2, ...)
  },

  parse_positional_arg = ptr_arg_symbol_or_string(),
  ui_text_defaults = list(label = "Columns for {param}")
)

ptr_app(
  mtcars |>
    dplyr::select(colvars) |>
    ggplot(aes(x = ppVar, y = ppVar)) + geom_point()
)
# <<<
