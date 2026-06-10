# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
library(rlang)
# >>>
f <- rlang::expr(ggplot(mtcars, aes(x = ppVar("wt"), y = ppVar("mpg"))) + geom_point())

ui <- shiny::fluidPage(
  shiny::h3("My dashboard"),
  ptr_ui(!!f, "plot1")
)
server <- function(input, output, session) {
  ptr_server(!!f, "plot1")
}
shiny::shinyApp(ui, server)
# <<<
