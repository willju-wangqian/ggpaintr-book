# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  mtcars |>
    dplyr::filter(ppExpr(mpg > 15)) |>
    ggplot(aes(x = ppVar, y = ppVar, color = ppVar)) +
    geom_point(size = ppNum) +
    labs(title = ppText)
)
# <<<
