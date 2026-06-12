# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
#
# Verbatim-diff anchor: this mirrors the package's browser-verified e2e fixture
# tests/testthat/fixtures/vignette-apps/adr28-plotly-linked/app.R (ADR 0028).
# It drops that fixture's explicit `source = "ptr_e2e"` (needed only so the e2e
# harness can inject a deterministic payload) — a real app omits source and
# lets both helpers derive the same per-instance id from the namespace.
library(ggpaintr)
library(ggplot2)
library(shiny)
library(plotly)
# >>>
# Live mode: instance 2 redraws on every brush because its render body reads
# sel() un-isolated, so reading the selection is an ordinary reactive
# dependency. No trigger wiring — that is the whole point.
ptr_options(gate_draw = FALSE)

# Instance 1: an ordinary ggpaintr formula. Its drawn data is the snapshot the
# selection projects off.
f1 <- rlang::expr(
  ggplot(mtcars, aes(x = ppVar(wt), y = ppVar(mpg))) + geom_point()
)

# Instance 2: an ordinary ggpaintr formula whose pipeline head is sel(). The
# flag projection appends a logical .ptr_selected; color = .ptr_selected.
f2 <- rlang::expr(
  sel() |>
    ggplot(aes(x = ppVar(hp), y = ppVar(qsec), color = .ptr_selected)) +
    geom_point()
)

ui <- ptr_ui_page(
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      ptr_ui_controls(formula = f1, id = "p1"),
      ptr_ui_controls(formula = f2, id = "p2")
    ),
    shiny::mainPanel(
      plotly::plotlyOutput("main_plotly"),
      ptr_ui_error("p1"),
      ptr_ui_plot("p2"),
      ptr_ui_error("p2"),
      shiny::tableOutput("sel_table")
    )
  )
)

server <- function(input, output, session) {
  state1 <- ptr_server(f1, "p1")

  # Instance 1 rendered through plotly, wired for linked selection.
  output$main_plotly <- plotly::renderPlotly(
    ptr_ggplotly(state1)
  )

  # The one selection, projected two ways off the instance-1 widget.
  sel      <- ptr_plotly_selection(state1, mode = "flag")
  sel_rows <- ptr_plotly_selection(state1, mode = "rows")

  # Instance 2: ordinary ggpaintr formula, pipeline head sel().
  ptr_server(f2, "p2")

  # Empty selection is a zero-row table (same columns), so no req() dance.
  output$sel_table <- shiny::renderTable(sel_rows())
}
# <<<

shiny::shinyApp(ui, server)
