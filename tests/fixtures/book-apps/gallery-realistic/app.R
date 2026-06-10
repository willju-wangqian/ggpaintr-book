# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
arg_range <- function() {
  function(arg_expr) {
    val <- tryCatch(eval(arg_expr, baseenv()), error = function(e) NULL)
    if (!is.numeric(val) || length(val) != 2L) {
      stop("ppRange() default must be a length-2 numeric vector, e.g. c(10, 45)")
    }
    val
  }
}

ppRange <- ptr_define_placeholder_value(
  keyword = "ppRange",
  build_ui = function(node, label = NULL, selected = NULL, ...) {
    v <- suppressWarnings(as.numeric(selected))
    initial <- if (length(v) == 2L && all(is.finite(v))) v else c(0, 50)
    shiny::sliderInput(node$id, label = label %||% "Range",
                       min = -100, max = 100, value = initial, step = 1)
  },
  resolve_expr = function(value, node, ...) {
    if (is.null(value) || length(value) != 2L) return(NULL)
    rlang::expr(c(!!value[1], !!value[2]))
  },
  ui_text_defaults = list(label = "Range for {param}"),
  parse_positional_arg = arg_range()
)

{
  ggplot(mpg, aes(ppVar(displ), ppVar(hwy), color = ppVar(class))) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = ppText("loess"), se = FALSE, span = 0.75) +
    ppLayerOff(facet_wrap(~ ppVar(drv)), FALSE) +
    scale_color_brewer(palette = "Set2") +
    labs(title = "Highway MPG vs engine displacement",
         x = ppText("Engine displacement (L)"), y = ppText("Highway MPG")) +
    coord_cartesian(xlim = ppExpr(c(1, 7)), ylim = ppRange(c(10, 45)))
} |>
  ptr_app()
# <<<
