# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(shiny)
# >>>
formula <- "ggplot(iris, aes(x = ppVar, y = ppVar, color = ppVar)) + geom_point()"

ui <- ptr_ui_page(                          # Bootstrap page + single .ptr-app + assets
  ptr_ui_header("Iris explorer"),
  shiny::fluidRow(
    shiny::column(4, ptr_ui_controls(formula = formula)),
    shiny::column(8, ptr_ui_plot())         # bare plot card; error placed below
  ),
  ptr_ui_error(),                           # error banner in its own row
  ptr_ui_code()                             # plain, always-visible code card
)
server <- function(input, output, session) {
  ptr_server(formula)   # binds ptr_plot / ptr_error / ptr_code
}

shiny::shinyApp(ui, server)
# <<<
