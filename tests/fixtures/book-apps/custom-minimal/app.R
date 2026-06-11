# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ppPalette <- ptr_define_placeholder_value(
  keyword = "ppPalette",

  build_ui = function(node, label = NULL, selected = NULL, ...) {
    shiny::selectInput(
      node$id, label = label %||% "Palette",
      choices  = c("Set1", "Set2", "Dark2", "Paired"),
      selected = selected
    )
  },

  resolve_expr = function(value, node, ...) {
    if (is.null(value)) return(NULL)
    value
  }
)

ptr_app(
  ggplot(iris, aes(x = ppVar("Sepal.Length"), y = ppVar("Petal.Length"), color = ppVar("Species"))) +
    geom_point() +
    scale_color_brewer(palette = ppPalette())
)
# <<<
