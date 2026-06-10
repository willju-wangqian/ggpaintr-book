# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
"ggplot(mpg, aes(displ, hwy)) +
geom_point(alpha = ppNum(0.5)) +
geom_smooth(method = ppText('loess'))"
)
# <<<
