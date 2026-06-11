# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  ggplot(mpg, aes(x = ppVar("displ"), y = ppVar("hwy"), color = ppVar("class"))) +
    geom_point(alpha = ppNum(0.6)) +
    geom_smooth(method = ppText("loess"), se = FALSE) +
    labs(title = ppText("Bigger engines, thirstier cars"))
)
# <<<
