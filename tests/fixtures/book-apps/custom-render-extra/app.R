# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
formula <- "ggplot(mtcars, aes(x = mpg, y = hp)) + geom_point()"

ui <- shiny::fluidPage(
  shiny::actionButton("add_log", "Toggle log-scale"),
  ptr_ui(formula)
)

server <- function(input, output, session) {
  state <- ptr_server(formula)
  shiny::observeEvent(input$add_log, {
    ptr_gg_extra(state, ggplot2::scale_x_log10())
  })
}

shiny::shinyApp(ui, server)
# <<<
