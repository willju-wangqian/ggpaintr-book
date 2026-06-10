# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app("
ggplot(iris, aes(x = ppVar, y = ppVar, color = ppVar)) +
geom_point(size = ppNum) +
labs(title = ppText) +
facet_wrap(ppExpr)
")
# <<<
