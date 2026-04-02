library(tidyverse)

inv_logit <- \(x) 1 / (1 + exp(-x))

scenarios <- tribble(
  ~alpha, ~beta, ~label,                                                          ~filename,
   0,      1,    'alpha == 0 ~~ beta == 1',                                       "cal_a0_b1",
   1,      1,    'alpha == 1 ~~ beta == 1',                                       "cal_a1_b1",
  -1,      1,    'alpha == -1 ~~ beta == 1',                                      "cal_am1_b1",
   0,      0.5,  'alpha == 0 ~~ beta == 0.5',                                     "cal_a0_b05",
   0,      1.5,  'alpha == 0 ~~ beta == 1.5',                                     "cal_a0_b15",
   1,      0.5,  'alpha == 1 ~~ beta == 0.5',                                     "cal_a1_b05",
  -1,      0.5,  'alpha == -1 ~~ beta == 0.5',                                    "cal_am1_b05",
   1,      1.5,  'alpha == 1 ~~ beta == 1.5',                                     "cal_a1_b15",
  -1,      1.5,  'alpha == -1 ~~ beta == 1.5',                                    "cal_am1_b15"
)

p_pred <- seq(0.001, 0.999, length.out = 500)

for (i in seq_len(nrow(scenarios))) {
  s <- scenarios[i, ]
  curve_df <- tibble(
    p_pred = p_pred,
    p_obs = inv_logit(s$alpha + s$beta * qlogis(p_pred))
  ) |>
    mutate(
      above = p_obs > p_pred,
      obs_above = ifelse(above, p_obs, p_pred),
      obs_below = ifelse(!above, p_obs, p_pred)
    )

  pi <- ggplot(curve_df, aes(x = p_pred)) +
    geom_ribbon(aes(ymin = p_pred, ymax = obs_above), fill = "#4393C3", alpha = 0.3) +
    geom_ribbon(aes(ymin = obs_below, ymax = p_pred), fill = "#D6604D", alpha = 0.3) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey40") +
    geom_line(aes(y = p_obs), linewidth = 0.7, color = "#2166AC") +
    annotate("text", x = 0.5, y = 0.95, label = parse(text = s$label),
             size = 3.2, color = "grey20") +
    scale_x_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
    scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
    coord_fixed() +
    labs(x = "Predicted probability", y = "Observed prportion") +
    theme_classic(base_size = 11)

  ggsave(paste0("figures/Introduction/", s$filename, ".pdf"), pi,
         width = 3, height = 3, units = "in")
}
