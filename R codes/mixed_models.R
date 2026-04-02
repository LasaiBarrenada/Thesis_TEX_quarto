library(tidyverse)
library(lme4)
library(rms)
library(patchwork)

set.seed(7291)

n_clusters <- 6
n_per_cluster <- 500
beta0 <- -0.5
beta1 <- 1.2
tau <- 1.0

u_j <- rnorm(n_clusters, 0, tau)
cluster_labels <- paste0("Cluster ", LETTERS[1:n_clusters])

df <- map_dfr(seq_len(n_clusters), function(j) {
  x <- rnorm(n_per_cluster, 0, 1)
  lp <- (beta0 + u_j[j]) + beta1 * x
  tibble(x = x, y = rbinom(n_per_cluster, 1, plogis(lp)),
         cluster = cluster_labels[j])
})

# Fit standard LR (ignoring clustering) and mixed model
fit_fixed <- glm(y ~ x, data = df, family = binomial)
fit_mixed <- glmer(y ~ x + (1 | cluster), data = df, family = binomial)

df <- df |>
  mutate(
    p_fixed = predict(fit_fixed, type = "response"),
    p_mixed = predict(fit_mixed, type = "response")
  )

# Smooth calibration curves per cluster using rcs
grid <- tibble(p = seq(0.01, 0.99, length.out = 300))

fit_cal_curves <- function(data, pred_col) {
  map_dfr(cluster_labels, function(cl) {
    d <- filter(data, cluster == cl)
    fit <- lrm(y ~ rcs(p_pred, 3), data = mutate(d, p_pred = .data[[pred_col]]))
    grid |> mutate(
      p_pred = p,
      y_hat = plogis(predict(fit, newdata = tibble(p_pred = p))),
      cluster = cl
    )
  })
}

curves_fixed <- fit_cal_curves(df, "p_fixed")
curves_mixed <- fit_cal_curves(df, "p_mixed")

cluster_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#A65628")
names(cluster_colors) <- cluster_labels

base_theme <- theme_classic(base_size = 11) +
  theme(
    plot.title = element_text(size = 11, face = "bold", hjust = 0.5),
    legend.position = "none"
  )

p_fixed <- ggplot(curves_fixed, aes(x = p_pred, y = y_hat, color = cluster)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.6) +
  scale_color_manual(values = cluster_colors) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(x = "Predicted probability", y = "Observed proportion",
       title = "Standard logistic regression") +
  base_theme

p_mixed <- ggplot(curves_mixed, aes(x = p_pred, y = y_hat, color = cluster)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.6) +
  scale_color_manual(values = cluster_colors) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(x = "Predicted probability", y = "Observed proportion",
       title = "Mixed effects logistic regression") +
  base_theme

# Shared legend
legend_plot <- ggplot(curves_fixed, aes(x = p_pred, y = y_hat, color = cluster)) +
  geom_line() +
  scale_color_manual(values = cluster_colors) +
  guides(color = guide_legend(nrow = 1)) +
  theme_classic(base_size = 10) +
  theme(legend.position = "bottom", legend.title = element_blank())
shared_legend <- cowplot::get_legend(legend_plot)

p_top <- (p_fixed | p_mixed) + plot_annotation(tag_levels = "A")
p_combined <- p_top / wrap_elements(shared_legend) +
  plot_layout(heights = c(1, 0.07))

ggsave("figures/Introduction/mixed_models.pdf", p_combined,
       width = 8, height = 4.5, units = "in")
