# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
plots <- list(
  "ggplot(iris, aes(x = ppVar(shared = 'ax1'), y = ppVar - ppVar(shared = 'ax1'),
                    color = Species)) + geom_point(size = ppNum(shared = 'sz'))",
  "ggplot(iris, aes(x = ppVar(shared = 'ax2'), y = Sepal.Width,
                    color = Species)) + geom_point(size = ppNum(shared = 'sz'))"
)

obj <- ptr_shared(formulas = plots)
# sz → both formulas → standalone panel.  ax1 → only plot_1's inline section.
# ax2 → only plot_2's inline section.

ui <- shiny::fluidPage(
  ptr_shared_panel(obj),             # holds sz only
  shiny::fluidRow(
    shiny::column(6, ptr_ui(plots[[1]], "plot_1", shared = obj)),  # ax1 inline
    shiny::column(6, ptr_ui(plots[[2]], "plot_2", shared = obj))   # ax2 inline
  )
)
server <- function(input, output, session) {
  sh <- ptr_shared_server(obj)
  ptr_server(plots[[1]], "plot_1", shared_state = sh)
  ptr_server(plots[[2]], "plot_2", shared_state = sh)
}

shiny::shinyApp(ui, server)
# <<<
