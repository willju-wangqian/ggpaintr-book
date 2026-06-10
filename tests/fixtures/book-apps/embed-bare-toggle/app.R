# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
formula <- "ggplot(iris, aes(x = ppVar, y = ppVar, color = ppVar)) + geom_point()"

ui <- ptr_ui_page(
  ptr_ui_header("Iris explorer"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(ptr_ui_controls(formula = formula)),
    shiny::mainPanel(
      ptr_ui_toggle_code(                                   # </> slide-out toggle ...
        ptr_ui_inline_error(ptr_ui_plot(), ptr_ui_error()), # ... around plot + inline error
        ptr_ui_code()                                       # ... wrapped as the slide-out window
      )
    )
  )
)
server <- function(input, output, session) {
  ptr_server(formula)
}

shiny::shinyApp(ui, server)
# <<<
