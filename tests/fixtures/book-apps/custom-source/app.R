# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_define_placeholder_source(
  keyword  = "ppDataset",
  shortcut = TRUE,

  build_ui = function(node, label = NULL, ...) {
    # Shortcut-only source: the framework's text box is the sole entry
    # point, so build_ui contributes no widget of its own.
    NULL
  },

  resolve_data = function(value, node, ...) {
    # `value` is the primary widget's value -- always NULL here, since
    # build_ui renders nothing. The shortcut lookup is the framework's.
    NULL
  },

  ui_text_defaults = list(label = "Dataset for {param}")
)

ptr_app(
  ppDataset() |> ggplot(aes(x = ppVar("mpg"))) + geom_histogram()
)
# <<<
