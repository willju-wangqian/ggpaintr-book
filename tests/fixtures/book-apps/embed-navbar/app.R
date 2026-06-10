# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
formula <- "ggplot(iris, aes(x = ppVar, y = ppVar, color = ppVar)) + geom_point()"

ui <- shiny::navbarPage(
  "Iris explorer",                            # navbarPage needs a positional title
  shiny::tabPanel(
    "Plot",
    ptr_ui_assets(),                          # the bundle, once (self-deduping) — escape hatch
    shiny::tags$div(
      class = "ptr-app",                      # the single theme scope
      shiny::sidebarLayout(
        shiny::sidebarPanel(ptr_ui_controls(formula = formula)),
        shiny::mainPanel(
          ptr_ui_toggle_code(
            ptr_ui_inline_error(ptr_ui_plot(), ptr_ui_error()),
            ptr_ui_code()
          )
        )
      )
    )
  ),
  shiny::tabPanel("About", "Built with ggpaintr.")
)
server <- function(input, output, session) {
  ptr_server(formula)
}

shiny::shinyApp(ui, server)
# <<<
