library(tidyverse)

inv_logit <- \(x) 1 / (1 + exp(-x))

# --- Simulate miscalibrated predictions ---
set.seed(7341)

n <- 2000
lp <- rnorm(n, mean = -0.5, sd = 1.2)
p_pred <- inv_logit(lp)

# Miscalibration: alpha = 0.3, beta = 0.8 (mild overfit + underestimation)
p_true <- inv_logit(0.3 + 0.8 * qlogis(p_pred))
y <- rbinom(n, 1, p_true)

sim <- tibble(p_pred, y)

# --- 1. Binned calibration with exact binomial CIs ---
nbins <- 10
binned <- sim |>
  mutate(bin = ntile(p_pred, nbins)) |>
  summarise(
    pred_mean = mean(p_pred),
    obs_mean = mean(y),
    n = n(),
    events = sum(y),
    .by = bin
  ) |>
  mutate(
    ci = map2(events, n, \(x, n) binom.test(x, n)$conf.int),
    ci_lo = map_dbl(ci, 1),
    ci_hi = map_dbl(ci, 2)
  )

# --- 2. Logistic calibration with Wald CIs on logit scale ---
fit_logistic <- glm(y ~ qlogis(p_pred), data = sim, family = binomial)
grid <- tibble(p_pred = seq(0.01, 0.99, length.out = 300))
logistic_pred <- predict(fit_logistic, newdata = grid, type = "link", se.fit = TRUE)
grid <- grid |>
  mutate(
    obs_fit = inv_logit(logistic_pred$fit),
    logistic_lo = inv_logit(logistic_pred$fit - 1.96 * logistic_pred$se.fit),
    logistic_hi = inv_logit(logistic_pred$fit + 1.96 * logistic_pred$se.fit)
  )

# --- 3. LOESS calibration with SE-based CIs ---
fit_loess <- loess(y ~ p_pred, data = sim, span = 0.75)
loess_pred <- predict(fit_loess, newdata = grid, se = TRUE)
grid <- grid |>
  mutate(
    obs_loess = loess_pred$fit,
    loess_lo = loess_pred$fit - 1.96 * loess_pred$se.fit,
    loess_hi = loess_pred$fit + 1.96 * loess_pred$se.fit
  )

# --- Common plot elements ---
diag <- geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey40")
rug_events <- geom_rug(data = sim |> filter(y == 1), aes(x = p_pred), sides = "t",
                        alpha = 0.03, inherit.aes = FALSE)
rug_nonevents <- geom_rug(data = sim |> filter(y == 0), aes(x = p_pred), sides = "b",
                           alpha = 0.03, inherit.aes = FALSE)
bt <- theme_classic(base_size = 11)

# --- Build panels ---
p1 <- ggplot(binned, aes(x = pred_mean, y = obs_mean)) +
  diag + rug_events + rug_nonevents +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2) +
  geom_point(size = 2.5) + geom_line() +
  scale_x_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
  coord_fixed() +
  labs(x = "Predicted probability", y = "Observed proportion") + bt

p2 <- ggplot(grid, aes(x = p_pred, y = obs_fit)) +
  diag + rug_events + rug_nonevents +
  geom_ribbon(aes(ymin = logistic_lo, ymax = logistic_hi), alpha = 0.2) +
  geom_line(color = "#2166AC", linewidth = 0.8) +
  scale_x_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
  coord_fixed() +
  labs(x = "Predicted probability", y = "Observed proportion") + bt

p3 <- ggplot(grid, aes(x = p_pred, y = obs_loess)) +
  diag + rug_events + rug_nonevents +
  geom_ribbon(aes(ymin = loess_lo, ymax = loess_hi), alpha = 0.2) +
  geom_line(color = "#2166AC", linewidth = 0.8) +
  scale_x_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
  coord_fixed() +
  labs(x = "Predicted probability", y = "Observed proportion") + bt

ggsave("figures/Introduction/calibration_binned.pdf", p1, width = 3, height = 3, units = "in")
ggsave("figures/Introduction/calibration_logistic.pdf", p2, width = 3, height = 3, units = "in")
ggsave("figures/Introduction/calibration_loess.pdf", p3, width = 3, height = 3, units = "in")
