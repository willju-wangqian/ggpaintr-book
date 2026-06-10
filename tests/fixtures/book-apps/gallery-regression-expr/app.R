# Boot harness: the book gates against the *installed pinned* ggpaintr
# (DESCRIPTION Remotes), never a dev tree.
library(ggpaintr)
library(ggplot2)
library(broom)
# >>>
{broom::augment(lm(ppExpr(Sepal.Length ~ Sepal.Width + Petal.Length), data = ppUpload(iris))) |>
    ggplot(aes(.fitted, .resid)) +
    geom_hline(yintercept = ppExpr(0), color = "gray60", linetype = 2) +
    geom_point(alpha = 0.7, size = 2.5, color = "#D55E00") +
    geom_smooth(method = ppText("loess"), se = FALSE, span = 0.75) +
    labs(title = "Residuals vs fitted (user-chosen model on iris)",
         x = "Fitted", y = "Residual") +
    theme_minimal()} |>
  ptr_app()
# <<<
