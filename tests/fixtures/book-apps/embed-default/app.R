# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
formula <- "ggplot(iris, aes(ppVar, ppVar, color = ppVar)) + geom_point()"

ui <- shiny::fluidPage(
  shiny::titlePanel("My host app"),
  ptr_ui(formula)
)
server <- function(input, output, session) {
  ptr_server(formula)
}

shiny::shinyApp(ui, server)
# <<<
