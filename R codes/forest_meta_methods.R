library(metafor)
library(metamisc)
library(ggplot2)

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(8)

# --- Simulate 10 studies with AUC estimates ---
k <- 10
tau2_true <- 0.15
mu_true <- qlogis(0.90)

theta_j <- rnorm(k, mean = mu_true, sd = sqrt(tau2_true))
se_j <- runif(k, 0.10, 0.45)
yi <- rnorm(k, mean = theta_j, sd = se_j)

# --- Fit frequentist models (3 tau2 estimators x Wald/HKSJ) ---
fit_dl        <- rma(yi = yi, sei = se_j, method = "DL")
fit_dl_hksj   <- rma(yi = yi, sei = se_j, method = "DL",   test = "knha")
fit_reml      <- rma(yi = yi, sei = se_j, method = "REML")
fit_reml_hksj <- rma(yi = yi, sei = se_j, method = "REML", test = "knha")
fit_pm        <- rma(yi = yi, sei = se_j, method = "PM")
fit_pm_hksj   <- rma(yi = yi, sei = se_j, method = "PM",   test = "knha")

fits <- list(
  "DL"          = fit_dl,
  "DL + HKSJ"   = fit_dl_hksj,
  "REML"        = fit_reml,
  "REML + HKSJ" = fit_reml_hksj,
  "PM"          = fit_pm,
  "PM + HKSJ"   = fit_pm_hksj
)

extract_results <- function(fit, label) {
  pi <- predict(fit)
  data.frame(
    Method = label,
    est    = as.numeric(fit$b),
    ci_lb  = fit$ci.lb, ci_ub = fit$ci.ub,
    pi_lb  = pi$pi.lb,  pi_ub = pi$pi.ub,
    tau2   = fit$tau2,   I2    = fit$I2
  )
}

pooled <- do.call(rbind, Map(extract_results, fits, names(fits)))
pooled$AUC       <- plogis(pooled$est)
pooled$ci_lb_auc <- plogis(pooled$ci_lb)
pooled$ci_ub_auc <- plogis(pooled$ci_ub)
pooled$pi_lb_auc <- plogis(pooled$pi_lb)
pooled$pi_ub_auc <- plogis(pooled$pi_ub)

# --- Fit Bayesian model via metamisc ---
auc_estimates <- plogis(yi)
auc_se <- se_j * auc_estimates * (1 - auc_estimates)

fit_bayes <- valmeta(
  measure  = "cstat",
  cstat    = auc_estimates,
  cstat.se = auc_se,
  method   = "BAYES",
  verbose  = FALSE
)

bayes_row <- data.frame(
  Method     = "Bayesian (JAGS)",
  est        = qlogis(fit_bayes$est),
  ci_lb      = qlogis(fit_bayes$ci.lb),
  ci_ub      = qlogis(fit_bayes$ci.ub),
  pi_lb      = qlogis(fit_bayes$pi.lb),
  pi_ub      = qlogis(fit_bayes$pi.ub),
  tau2       = fit_bayes$tau2,
  I2         = NA,
  AUC        = fit_bayes$est,
  ci_lb_auc  = fit_bayes$ci.lb,
  ci_ub_auc  = fit_bayes$ci.ub,
  pi_lb_auc  = fit_bayes$pi.lb,
  pi_ub_auc  = fit_bayes$pi.ub
)

pooled <- rbind(pooled, bayes_row)
n_methods <- nrow(pooled)

# --- Assemble plot data ---
studies <- data.frame(
  label = paste0("Study ", 1:k),
  est   = plogis(yi),
  ci_lb = plogis(yi - 1.96 * se_j),
  ci_ub = plogis(yi + 1.96 * se_j),
  type  = "study"
)

pooled_plot <- data.frame(
  label = pooled$Method,
  est   = pooled$AUC,
  ci_lb = pooled$ci_lb_auc,
  ci_ub = pooled$ci_ub_auc,
  type  = "pooled"
)

pi_data <- data.frame(
  label = pooled$Method,
  pi_lb = pooled$pi_lb_auc,
  pi_ub = pooled$pi_ub_auc
)

plot_data <- rbind(studies, pooled_plot)

# Tighter vertical spacing
study_ypos  <- rev(seq_len(k)) * 0.85 + n_methods * 0.7 + 0.8
pooled_ypos <- rev(seq_len(n_methods)) * 0.7

plot_data$ypos <- NA
plot_data$ypos[plot_data$type == "study"]  <- study_ypos
plot_data$ypos[plot_data$type == "pooled"] <- pooled_ypos
pi_data$ypos <- pooled_ypos

plot_data$est_label <- sprintf("%.2f [%.2f, %.2f]",
                               plot_data$est, plot_data$ci_lb, plot_data$ci_ub)
plot_data$pi_label <- ""
plot_data$pi_label[plot_data$type == "pooled"] <- sprintf(
  "[%.2f, %.2f]", pi_data$pi_lb, pi_data$pi_ub
)

# tau2 / I2 annotations (tau^2 without hat)
pooled_annot <- data.frame(
  ypos  = pooled_ypos,
  annot = ifelse(
    is.na(pooled$I2),
    sprintf("tau^2 == %.3f", pooled$tau2),
    sprintf("tau^2 == %.3f ~~ I^2 == %.1f*'%%'", pooled$tau2, pooled$I2)
  )
)

# Colours: blue for frequentist, dark red for Bayesian
is_freq  <- pooled_plot$label != "Bayesian (JAGS)"
is_bayes <- pooled_plot$label == "Bayesian (JAGS)"
pi_cols  <- ifelse(pi_data$label == "Bayesian (JAGS)", "#8B0000", "grey50")

sep_y <- min(study_ypos) - 0.35
top_y <- max(study_ypos) + 0.6

# --- Build the forest plot ---
# x-axis drawn manually from 0.6 to 1.0; labels placed outside in margins
p <- ggplot(plot_data, aes(x = est, y = ypos)) +
  # PIs (dashed)
  geom_segment(
    data = cbind(pi_data, col = pi_cols),
    aes(x = pi_lb, xend = pi_ub, y = ypos, yend = ypos, colour = col),
    linewidth = 0.4, linetype = "dashed",
    inherit.aes = FALSE, show.legend = FALSE
  ) +
  scale_colour_identity() +
  # Study CIs
  geom_segment(
    data = plot_data[plot_data$type == "study", ],
    aes(x = ci_lb, xend = ci_ub, y = ypos, yend = ypos),
    linewidth = 0.4
  ) +
  geom_point(
    data = plot_data[plot_data$type == "study", ],
    shape = 15, size = 2.5
  ) +
  # Frequentist pooled (blue)
  geom_segment(
    data = pooled_plot[is_freq, ],
    aes(x = ci_lb, xend = ci_ub,
        y = pooled_ypos[is_freq], yend = pooled_ypos[is_freq]),
    linewidth = 0.7, colour = "#2166AC", inherit.aes = FALSE
  ) +
  geom_point(
    data = pooled_plot[is_freq, ],
    aes(x = est, y = pooled_ypos[is_freq]),
    shape = 18, size = 4, colour = "#2166AC", inherit.aes = FALSE
  ) +
  # Bayesian pooled (dark red)
  geom_segment(
    data = pooled_plot[is_bayes, ],
    aes(x = ci_lb, xend = ci_ub,
        y = pooled_ypos[is_bayes], yend = pooled_ypos[is_bayes]),
    linewidth = 0.7, colour = "#8B0000", inherit.aes = FALSE
  ) +
  geom_point(
    data = pooled_plot[is_bayes, ],
    aes(x = est, y = pooled_ypos[is_bayes]),
    shape = 18, size = 4, colour = "#8B0000", inherit.aes = FALSE
  ) +
  # Labels: studies
  geom_text(
    data = plot_data[plot_data$type == "study", ],
    aes(label = label), x = 0.40, hjust = 0, size = 2.8
  ) +
  # Labels: pooled methods (bold)
  geom_text(
    data = plot_data[plot_data$type == "pooled", ],
    aes(label = label), x = 0.40, hjust = 0, size = 2.8, fontface = "bold"
  ) +
  # tau2 / I2 below each pooled label
  geom_text(
    data = pooled_annot,
    aes(x = 0.40, y = ypos - 0.25, label = annot),
    parse = TRUE, hjust = 0, size = 2.1, colour = "grey40",
    inherit.aes = FALSE
  ) +
  # AUC [95% CI/CrI] column
  geom_text(aes(label = est_label), x = 1.03, hjust = 0, size = 2.4) +
  # 95% PI column
  geom_text(
    data = plot_data[plot_data$type == "pooled", ],
    aes(label = pi_label), x = 1.19, hjust = 0, size = 2.4, colour = "grey40"
  ) +
  # Separator line
  geom_hline(yintercept = sep_y, linetype = "solid", colour = "grey70",
             linewidth = 0.3) +
  # Column headers
  annotate("text", x = 0.40,  y = top_y, label = "Study",
           hjust = 0, size = 3, fontface = "bold") +
  annotate("text", x = 1.03, y = top_y, label = "AUC [95% CI/CrI]",
           hjust = 0, size = 3, fontface = "bold") +
  annotate("text", x = 1.19, y = top_y, label = "     95% PI",
           hjust = 0, size = 3, fontface = "bold", colour = "grey40") +
  # Reference line at REML+HKSJ pooled estimate
  geom_vline(
    xintercept = pooled$AUC[pooled$Method == "REML + HKSJ"],
    linetype = "dotted", colour = "grey50", linewidth = 0.3
  ) +
  # PI legend
  annotate("segment", x = 0.72, xend = 0.77,
           y = min(pooled_ypos) - 0.55, yend = min(pooled_ypos) - 0.55,
           linetype = "dashed", colour = "grey50", linewidth = 0.4) +
  annotate("text", x = 0.78, y = min(pooled_ypos) - 0.55,
           label = "95% Prediction interval",
           hjust = 0, size = 2.3, colour = "grey40") +
  # Full scale includes label areas; default axis hidden
  scale_x_continuous(
    limits = c(0.38, 1.32),
    breaks = seq(0.6, 1.0, by = 0.1),
    expand = c(0, 0)
  ) +
  scale_y_continuous(
    limits = c(min(pooled_ypos) - 1.55, top_y + 0.4),
    expand = c(0, 0)
  ) +
  coord_cartesian(clip = "off") +
  labs(x = NULL) +
  theme_classic(base_size = 11) +
  theme(
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y  = element_blank(),
    axis.line.x  = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x  = element_blank(),
    plot.margin  = margin(10, 10, 10, 5)
  ) +
  # Custom x-axis line from 0.6 to 1.0
  annotate("segment", x = 0.6, xend = 1.0,
           y = min(pooled_ypos) - 0.75, yend = min(pooled_ypos) - 0.75,
           colour = "black", linewidth = 0.4) +
  # Custom tick marks
  annotate("segment",
           x = seq(0.6, 1.0, 0.1), xend = seq(0.6, 1.0, 0.1),
           y = min(pooled_ypos) - 0.75, yend = min(pooled_ypos) - 0.82,
           colour = "black", linewidth = 0.4) +
  # Custom tick labels
  annotate("text",
           x = seq(0.6, 1.0, 0.1), y = min(pooled_ypos) - 0.95,
           label = sprintf("%.1f", seq(0.6, 1.0, 0.1)),
           size = 3) +
  # Axis title
  annotate("text", x = 0.8, y = min(pooled_ypos) - 1.35,
           label = "AUC", size = 3.5)

ggsave("figures/Introduction/forest_meta_methods.pdf", plot = p,
       width = 15, height = 16, units = "cm", device = cairo_pdf)
