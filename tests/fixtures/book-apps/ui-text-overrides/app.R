# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
custom_text <- ptr_ui_text(list(
  shell = list(
    title       = list(label = "Iris explorer"),
    draw_button = list(label = "Render")
  ),
  params = list(
    x     = list(ppVar  = list(label = "X variable")),
    title = list(ppText = list(label = "Plot heading"))
  )
))

ptr_app(
  "ggplot(iris, aes(x = ppVar, y = ppVar, color = ppVar)) +
     geom_point() +
     labs(title = ppText)",
  ui_text = custom_text
)
# <<<
