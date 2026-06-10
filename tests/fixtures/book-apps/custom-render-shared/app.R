# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
library(plotly)
# >>>
plots <- list(
  "ggplot(iris, aes(x = ppVar(shared = 'metric'), y = Sepal.Length, fill = Species)) + geom_boxplot()",
  "ggplot(iris, aes(x = ppVar(shared = 'metric'), y = Sepal.Width,  fill = Species)) + geom_violin()"
)

obj <- ptr_shared(formulas = plots)

ui <- ptr_ui_page(
  ptr_ui_shared_panel(obj),                                  # cross-formula panel (bare, L3)
  shiny::fluidRow(
    shiny::column(3, ptr_ui_controls(plots[[1]], "plot_1", shared = obj)),
    shiny::column(9, plotly::plotlyOutput(shiny::NS("plot_1")("custom")))
  ),
  shiny::fluidRow(
    shiny::column(3, ptr_ui_controls(plots[[2]], "plot_2", shared = obj)),
    shiny::column(9, plotly::plotlyOutput(shiny::NS("plot_2")("custom")))
  )
)
server <- function(input, output, session) {
  sh <- ptr_shared_server(obj)                               # top level, once
  state1 <- ptr_server(plots[[1]], "plot_1", shared_state = sh)
  state2 <- ptr_server(plots[[2]], "plot_2", shared_state = sh)
  output[[shiny::NS("plot_1")("custom")]] <- plotly::renderPlotly({
    res <- state1$runtime(); shiny::req(isTRUE(res$ok), res$plot)
    plotly::ggplotly(res$plot)
  })
  output[[shiny::NS("plot_2")("custom")]] <- plotly::renderPlotly({
    res <- state2$runtime(); shiny::req(isTRUE(res$ok), res$plot)
    plotly::ggplotly(res$plot)
  })
}

shiny::shinyApp(ui, server)
# <<<
