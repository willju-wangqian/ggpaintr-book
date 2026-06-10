# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
plots <- list(
  "ggplot(iris, aes(x = ppVar(shared = 'metric'), y = Sepal.Length, fill = Species)) + geom_boxplot()",
  "ggplot(iris, aes(x = ppVar(shared = 'metric'), y = Sepal.Width,  fill = Species)) + geom_violin()"
)

obj <- ptr_shared(formulas = plots)

ui <- shiny::fluidPage(
  shiny::titlePanel("My host app"),
  ptr_shared_panel(obj),
  shiny::fluidRow(
    shiny::column(6, ptr_ui(plots[[1]], "plot_1", shared = obj)),
    shiny::column(6, ptr_ui(plots[[2]], "plot_2", shared = obj))
  )
)
server <- function(input, output, session) {
  sh <- ptr_shared_server(obj)
  ptr_server(plots[[1]], "plot_1", shared_state = sh)
  ptr_server(plots[[2]], "plot_2", shared_state = sh)
}

shiny::shinyApp(ui, server)
# <<<
