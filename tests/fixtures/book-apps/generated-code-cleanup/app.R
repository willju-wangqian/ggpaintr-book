# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app("
ggplot(iris, aes(x = ppVar('Sepal.Length'), y = ppVar('Sepal.Width'))) +
geom_point() +
labs(title = ppText) +
facet_wrap(ppExpr)
")
# <<<
