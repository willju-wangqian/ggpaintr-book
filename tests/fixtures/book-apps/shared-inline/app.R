# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  "ggplot(iris, aes(x = ppVar(shared = 'col'), y = ppVar - ppVar(shared = 'col'),
                    color = Species)) + geom_point()"
)
# <<<
