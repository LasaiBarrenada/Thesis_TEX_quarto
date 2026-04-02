library(tidyverse)
library(rms)

set.seed(4738)
n <- 3000

p_pred <- runif(2 * n, 0.02, 0.98)

# Cluster A: model overestimates (true prob lower than predicted)
# Cluster B: model underestimates (true prob higher than predicted)
delta <- 0.7
p_true <- c(
  plogis(qlogis(p_pred[1:n]) - delta),
  plogis(qlogis(p_pred[(n+1):(2*n)]) + delta)
)
y <- rbinom(2 * n, 1, p_true)

df <- tibble(
  p_pred = p_pred,
  y = y,
  Cluster = rep(c("Cluster A", "Cluster B"), each = n)
)

# Restricted cubic spline calibration curves
fit_overall <- lrm(y ~ rcs(p_pred, 3), data = df)
fit_a <- lrm(y ~ rcs(p_pred, 3), data = filter(df, Cluster == "Cluster A"))
fit_b <- lrm(y ~ rcs(p_pred, 3), data = filter(df, Cluster == "Cluster B"))

grid <- tibble(p_pred = seq(0.05, 0.95, length.out = 300))

curves <- bind_rows(
  grid |> mutate(y_hat = plogis(predict(fit_overall, newdata = grid)), group = "Overall"),
  grid |> mutate(y_hat = plogis(predict(fit_a, newdata = grid)), group = "Cluster A"),
  grid |> mutate(y_hat = plogis(predict(fit_b, newdata = grid)), group = "Cluster B")
)

p_clust <- ggplot(curves, aes(x = p_pred, y = y_hat, color = group, linewidth = group)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  geom_line() +
  scale_color_manual(values = c("Overall" = "black", "Cluster A" = "#D6604D", "Cluster B" = "#4393C3")) +
  scale_linewidth_manual(values = c("Overall" = 1.1, "Cluster A" = 0.8, "Cluster B" = 0.8)) +
  guides(linewidth = "none") +
  labs(x = "Predicted probability", y = "Observed proportion", color = NULL) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  theme_classic(base_size = 11) +
  theme(legend.position = c(0.05, 0.95), legend.justification = c(0, 1),
        legend.background = element_rect(fill = alpha("white", 0.8), color = NA))

ggsave("figures/Introduction/calibration_clustering.pdf", p_clust, width = 5, height = 5, units = "in")
