# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(ggpcp)
data(flea, package = "GGally")
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

{ppUpload(flea) |>
    pcp_select(ppVars(c("species", "tars1", "tars2", "head", "aede1", "aede2", "aede3"))) |>
    pcp_scale(method = "uniminmax") |>
    pcp_arrange() |>
    ggplot(aes_pcp()) +
    geom_pcp_axes() +
    geom_pcp(aes(colour = ppVar(species)))} |>
  ptr_app()
# <<<
