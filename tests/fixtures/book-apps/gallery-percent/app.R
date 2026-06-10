# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ppPercent <- ptr_define_placeholder_value(
  keyword = "ppPercent",

  build_ui = function(node, label = NULL, selected = NULL,
                      named_args = list(), ...) {
    step <- named_args$step %||% 1
    shiny::sliderInput(
      node$id, label = label %||% "Percent",
      min = 0, max = 100,
      value = selected %||% node$default %||% 50,
      step = step
    )
  },

  resolve_expr = function(value, node, ...) {
    if (is.null(value)) return(NULL)
    as.numeric(value) / 100
  },

  validate_session_input = function(value, ctx) {
    v <- suppressWarnings(as.numeric(value))
    if (length(v) != 1L || is.na(v) || v < 0 || v > 100) {
      rlang::abort("Percent must be a single number between 0 and 100.")
    }
    TRUE
  },

  parse_positional_arg = ptr_arg_numeric(),
  parse_named_args = list(step = ptr_arg_numeric()),
  embellish_eval   = function(x, ...) as.numeric(x) / 100,
  ui_text_defaults = list(label = "Percent for {param}")
)

ptr_app(
  ggplot(mtcars, aes(x = ppVar("wt"), y = ppVar("mpg"))) +
    geom_point(alpha = ppPercent(40, step = 5))
)
# <<<
