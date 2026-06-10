# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(dplyr)
# >>>
ptr_app(
  mpg |>
    dplyr::filter(ppVar(displ) > ppNum(1.5)) |>
    dplyr::group_by(ppVar(class)) |>
    dplyr::filter(ppExpr(dplyr::n() > 5)) |>
    dplyr::ungroup() |>
    ggplot(aes(ppVar(displ), ppVar(hwy), color = ppVar(class))) +
    geom_point(alpha = 0.5)
)
# <<<
