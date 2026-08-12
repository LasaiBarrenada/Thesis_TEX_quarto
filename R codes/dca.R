library(tidyverse)

inv_logit <- \(x) 1 / (1 + exp(-x))

set.seed(6192)

n <- 2000
# Outcome driven by the Model 1; intercept targets ~35% prevalence
lp_best <- rnorm(n, mean = -1.2, sd = 2.5)
p_best <- inv_logit(lp_best)
y <- rbinom(n, 1, p_best)

# Model 2: correlated with true risk but noisier
lp_good <- qlogis(p_best) + rnorm(n, 0, 1.5)
p_good <- inv_logit(lp_good)

# Model 3: weakly correlated with true risk
lp_poor <- qlogis(p_best) + rnorm(n, 0, 4)
p_poor <- inv_logit(lp_poor)

prev <- mean(y)

calc_nb <- function(y, p_pred, thresholds) {
  n <- length(y)
  purrr::map_dbl(thresholds, \(pt) {
    tp <- sum(y == 1 & p_pred >= pt)
    fp <- sum(y == 0 & p_pred >= pt)
    tp / n - fp / n * pt / (1 - pt)
  })
}

thresholds <- seq(0.01, 0.80, by = 0.005)

dca_df <- bind_rows(
  tibble(threshold = thresholds,
         nb = prev - (1 - prev) * thresholds / (1 - thresholds),
         strategy = "Treat all"),
  tibble(threshold = thresholds,
         nb = 0,
         strategy = "Treat none"),
  tibble(threshold = thresholds,
         nb = calc_nb(y, p_best, thresholds),
         strategy = "Model 1"),
  tibble(threshold = thresholds,
         nb = calc_nb(y, p_good, thresholds),
         strategy = "Model 2"),
  tibble(threshold = thresholds,
         nb = calc_nb(y, p_poor, thresholds),
         strategy = "Model 3")
) |>
  mutate(strategy = factor(strategy,
    levels = c("Model 1", "Model 2", "Model 3", "Treat all", "Treat none"),
    labels = c("Model 1", "Model 2", "Model 3", "Treat all", "Treat none")))

# Loess smooth the three model lines
model_df <- dca_df |>
  filter(strategy %in% c("Model 1", "Model 2", "Model 3")) |>
  group_by(strategy) |>
  mutate(nb_smooth = predict(loess(nb ~ threshold, span = 0.25))) |>
  ungroup()

default_df <- dca_df |>
  filter(strategy %in% c("Treat all", "Treat none"))

# Ticks: denser between 0 and 20%, then every 20%
primary_breaks <- c(0, 0.05, 0.10, 0.15, 0.20,0.33, 0.50, 0.60, 0.80)
hb_labels <- sapply(primary_breaks, \(pt) {
  if (pt == 0) return("0")
  ratio <- pt / (1 - pt)
  if (ratio < 1) {
    denom <- round(1 / ratio)
    paste0("1:", denom)
  } else {
    paste0(round(ratio, 1), ":1")
  }
})

p_dca <- ggplot() +
  geom_vline(xintercept = primary_breaks, color = "grey90", linewidth = 0.3) +
  geom_vline(xintercept = 0.1, color = "black", linetype = "dashed", linewidth = 0.4)+
  geom_line(data = default_df, aes(x = threshold, y = nb, color = strategy),
            linewidth = 0.8) +
  geom_line(data = model_df, aes(x = threshold, y = nb_smooth, color = strategy),
            linewidth = 0.8) +
  scale_color_manual(
    breaks = c("Model 1", "Model 2", "Model 3", "Treat all", "Treat none"),
    values = c(
      "Model 1" = "#08519C",
      "Model 2"      = "#4292C6",
      "Model 3"      = "#9ECAE1",
      "Treat all"       = "#E41A1C",
      "Treat none"      = "#4DAF4A"
  )) +
  scale_x_continuous(
    limits = c(0, 0.8),
    breaks = primary_breaks,
    labels = scales::percent_format(accuracy = 1),
    sec.axis = sec_axis(~ ., breaks = primary_breaks, labels = hb_labels,
                        name = "Harm-to-benefit ratio")
  ) +
  annotate("point", x = prev, y = 0, shape = 21, size = 3,
           fill = "white", color = "black") +
  annotate("text", x = prev - 0.01, y = -0.015, label = "Prevalence",
           size = 2.8, hjust = 1) +
  coord_cartesian(ylim = c(-0.05, max(dca_df$nb) + 0.02)) +
  labs(x = "Decision threshold", y = "Net benefit",
       color = "Strategy") +
  theme_classic(base_size = 11) +
  theme(
    legend.position = c(0.98, 0.98),
    legend.justification = c(1, 1),
    legend.background = element_rect(fill = alpha("white", 0.8), color = "black", linewidth = 0.3),
    legend.key.size = unit(0.9, "lines"),
    legend.text = element_text(size = 8),
    legend.title = element_text(size = 9)
  )

ggsave("figures/Introduction/dca.pdf", p_dca, width = 5, height = 4, units = "in")
p_dca <- p_dca + theme(
  legend.background = element_rect(fill = "transparent", color = NA),
  legend.key = element_rect(fill = "transparent", color = NA),
  panel.background = element_rect(fill = "transparent", color = NA),
  plot.background = element_rect(fill = "transparent", color = NA)
)

ggsave(plot = p_dca, path = "C:\\Users\\u0158158\\OneDrive - KU Leuven\\KU Leuven\\PhD\\Thesis\\Thesis_TEX_quarto\\presentation\\imgs" , filename = "dca-1.png", width = 5, height = 4.5, units = "in", dpi = 800)

