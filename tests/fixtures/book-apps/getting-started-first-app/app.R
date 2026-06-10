# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree. Lines outside the marker block
# are scaffolding; the >>> block is byte-identical to the chapter chunk.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  ggplot(mtcars, aes(x = ppVar, y = ppVar)) + geom_point()
)
# <<<
