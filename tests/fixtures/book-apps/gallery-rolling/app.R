# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(dplyr)
# >>>
roll_mean <- function(x, n) {
  as.numeric(stats::filter(x, rep(1 / n, n), sides = 1))
}

{economics |>
    mutate(roll = roll_mean(ppVar(unemploy), ppNum(12))) |>
    ggplot(aes(date, ppVar(unemploy))) +
    geom_line(color = "gray70") +
    geom_line(aes(y = roll), color = "#0072B2", linewidth = 1) +
    labs(title = "US unemployment with 12-month rolling mean",
         x = NULL, y = "Persons (thousands)") +
    theme_minimal()} |>
  ptr_app()
# <<<
