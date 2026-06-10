# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
"mpg |>
dplyr::filter(displ > ppNum) |>
dplyr::group_by(class) |>
dplyr::filter(dplyr::n() > ppNum) |>
dplyr::ungroup() |>
ggplot(aes(ppVar, ppVar, color = class)) +
geom_point(alpha = ppNum)"
)
# <<<
