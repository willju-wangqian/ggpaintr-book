# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
# >>>
messy <- data.frame(
  check.names = FALSE,
  "first column" = 1:3,
  "if"           = 4:6
)
clean <- ptr_normalize_column_names(messy)

ptr_app("ggplot(clean, aes(x = ppVar('first_column'), y = ppVar('if_'))) + geom_point()")
# <<<
