# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  ppUpload(iris) |>
    ggplot(aes(x = ppVar(Sepal.Length), y = ppVar(Sepal.Width), color = ppVar(Species))) +
    geom_point()
)
# <<<
