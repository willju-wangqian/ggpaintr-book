# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
my_app_bslib <- function(formula,
                         envir = parent.frame(),
                         ui_text = NULL,
                         expr_check = TRUE,
                         safe_to_remove = character(),
                         theme = NULL) {
  if (!requireNamespace("bslib", quietly = TRUE)) {
    rlang::abort("Package 'bslib' is required for my_app_bslib().")
  }
  if (is.null(theme)) {
    theme <- bslib::bs_theme(version = 5, bootswatch = "flatly")
  }
  id <- "ptr"
  title <- ptr_resolve_ui_text("title", ui_text = ui_text)$label %||% "ggpaintr"

  ui <- bslib::page_sidebar(
    title = title,
    theme = theme,
    sidebar = bslib::sidebar(
      title = "Controls",
      # The `.ptr-app` div restores the themed scope the bslib page chrome
      # does not provide, and ptr_ui_assets() ships the bundle (deduped
      # page-wide by htmlDependency).
      shiny::tags$div(
        class = "ptr-app",
        ptr_ui_assets(),
        ptr_ui_controls(
          id = id, formula = formula,
          ui_text = ui_text,
          expr_check = expr_check,
          shared = NULL
        )
      )
    ),
    bslib::card(
      shiny::tags$div(
        class = "ptr-app",
        ptr_ui_assets(),
        ptr_ui_toggle_code(
          ptr_ui_inline_error(ptr_ui_plot(id), ptr_ui_error(id)),
          ptr_ui_code(id)
        )
      )
    )
  )

  server <- function(input, output, session) {
    ptr_server(
      formula = formula,
      id = id,
      envir = envir,
      ui_text = ui_text,
      expr_check = expr_check,
      safe_to_remove = safe_to_remove
    )
  }

  shiny::shinyApp(ui = ui, server = server)
}

my_app_bslib("ggplot(iris, aes(ppVar('Sepal.Length'), ppVar('Sepal.Width'), color = ppVar('Species'))) + geom_point()")
# <<<
