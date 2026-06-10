# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree. The sibling my-theme.css is part
# of this fixture; note the screenshot pair-hash covers app.R only.
library(ggpaintr)
library(ggplot2)
# >>>
ptr_app(
  "ggplot(mtcars, aes(ppVar('wt'), ppVar('mpg'))) + geom_point()",
  css = "my-theme.css"
)
# <<<
