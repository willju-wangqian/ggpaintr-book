# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
"mtcars |>
ppVerbSwitch(dplyr::filter(mpg > ppNum), switch_on = FALSE) |>
ggplot(aes(mpg, wt)) +
geom_point() +
ppLayerOff(geom_smooth(method = 'lm'), TRUE)"
)
# <<<
