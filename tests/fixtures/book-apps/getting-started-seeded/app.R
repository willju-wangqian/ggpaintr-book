# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  ggplot(mtcars, aes(x = ppVar("wt"), y = ppVar("mpg"))) +
    geom_point(size = ppNum(3), alpha = ppNum(0.6)) +
    labs(title = ppText("Weight vs. mileage"))
)
# <<<
