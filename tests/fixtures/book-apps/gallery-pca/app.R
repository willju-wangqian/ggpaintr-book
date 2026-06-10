# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(broom)
# >>>
ppVars <- ptr_define_placeholder_consumer(
  keyword = "ppVars",
  build_ui = function(node, cols, data, label = NULL, selected = NULL, ...) {
    retained <- intersect(selected %||% character(0), cols)
    shiny::selectInput(node$id, label = label %||% "Columns",
                       choices = cols, selected = retained,
                       multiple = TRUE)
  },
  resolve_expr = function(value, node, ...) {
    if (length(value) == 0L) return(NULL)
    rlang::call2("c", !!!as.list(value))
  },
  validate_session_input = function(value, ctx) {
    bad <- setdiff(value, ctx$upstream_cols)
    if (length(bad) == 0L) TRUE
    else paste0("Not in upstream data: ", paste(bad, collapse = ", "))
  },
  ui_text_defaults = list(label = "Columns for {param}"),
  parse_positional_arg = ptr_arg_string(vector = TRUE)
)

do_pca <- function(d, cols) {
  broom::augment(prcomp(d[, cols], scale. = TRUE), d)
}

{ppUpload(iris) |>
    ppVerbSwitch(drop_na(), FALSE) |>
    do_pca(ppVars(c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"))) |>
    ggplot(aes(ppVar(.fittedPC1), ppVar(.fittedPC2), color = ppVar(Species))) +
    stat_ellipse(level = 0.95, linewidth = 0.8) +
    geom_point(alpha = 0.8, size = 2) +
    scale_color_brewer(palette = "Dark2") +
    labs(title = "Iris in PC space, with 95% ellipses",
         x = "PC1", y = "PC2") +
    theme_minimal() +
    theme(legend.position = "bottom")} |>
  ptr_app()
# <<<
