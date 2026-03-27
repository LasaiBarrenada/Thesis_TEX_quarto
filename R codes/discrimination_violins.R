library(tidyverse)

inv_logit <- \(x) 1 / (1 + exp(-x))

set.seed(4821)

n <- 1000

make_disc_data <- function(sd_lp, label) {
  lp <- rnorm(n, mean = 0, sd = sd_lp)
  p_pred <- inv_logit(lp)
  y <- rbinom(n, 1, p_pred)
  auc <- as.numeric(pROC::auc(y, p_pred, quiet = TRUE))
  tibble(
    predicted = p_pred,
    outcome = factor(y, levels = c(0, 1), labels = c("Non-event", "Event")),
    panel = label,
    auc = auc
  )
}

disc_all <- bind_rows(
  make_disc_data(0.4, "Poor"),
  make_disc_data(1.2, "Moderate"),
  make_disc_data(2.5, "Good")
) |>
  mutate(panel = factor(panel, levels = c("Poor", "Moderate", "Good")))

auc_labels <- disc_all |>
  distinct(panel, auc) |>
  mutate(label = sprintf("AUC = %.2f", auc))

panels <- c("Poor", "Moderate", "Good")
filenames <- c("disc_poor", "disc_moderate", "disc_good")

for (j in seq_along(panels)) {
  sub_df <- disc_all |> filter(panel == panels[j])
  auc_lab <- auc_labels |> filter(panel == panels[j])

  pj <- ggplot(sub_df, aes(x = outcome, y = predicted, fill = outcome)) +
    geom_violin(color = "grey50", alpha = 0.4) +
    geom_boxplot(width = 0.15, outlier.size = 0.5, fill = "white") +
    annotate("text", x = 2.4, y = -0.015, label = auc_lab$label,
             size = 3.2, color = "grey30", hjust = 1) +
    scale_fill_manual(values = c("Non-event" = "#D6604D", "Event" = "#4393C3")) +
    scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1)) +
    coord_cartesian(ylim = c(0, 1), clip = "off") +
    labs(x = "Outcome", y = "Predicted probability") +
    theme_classic(base_size = 11) +
    theme(legend.position = "none",
          plot.margin = margin(5, 5, 20, 5))

  ggsave(paste0("figures/Introduction/", filenames[j], ".pdf"), pj,
         width = 3, height = 3.5, units = "in")
}
