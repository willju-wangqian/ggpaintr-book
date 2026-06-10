# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
library(plotly)
# >>>
formula <- "ggplot(iris, aes(x = ppVar, y = ppVar, color = ppVar)) + geom_point()"

ui <- ptr_ui_page(
  shiny::fluidRow(
    shiny::column(5, ptr_ui_controls(formula, "plot1")),      # widgets only
    shiny::column(
      7,
      plotly::plotlyOutput(shiny::NS("plot1")("custom_plot"), # your own output
                           height = "500px") |>
        ptr_ui_toggle_code(ptr_ui_code("plot1"))
    )
  )
)

server <- function(input, output, session) {
  state <- ptr_server(formula, "plot1")
  output[[shiny::NS("plot1")("custom_plot")]] <- plotly::renderPlotly({
    res <- state$runtime()
    shiny::req(isTRUE(res$ok), res$plot)
    plotly::ggplotly(res$plot)
  })
}

shiny::shinyApp(ui, server)
# <<<
