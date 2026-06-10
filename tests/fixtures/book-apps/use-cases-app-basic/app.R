# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
"ggplot(iris, aes(ppVar, ppVar, color = ppVar)) + geom_point() + labs(title = ppText)"
)
# <<<
