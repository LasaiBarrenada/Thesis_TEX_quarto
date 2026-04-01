library(ggplot2)

# Boxes: Apparent -> Internal -> External -> Impact
boxes <- data.frame(
  label = c("Apparent\nvalidation", "Internal\nvalidation",
            "External\nvalidation", "Impact\nstudies"),
  x = 1:4,
  y = 0
)

# Sublabels beneath each box
sublabels <- data.frame(
  x = 1:4,
  y = -0.45,
  label = c(
    "Training data\nperformance",
    "Cross-validation,\nbootstrap",
    "New data,\nnew settings",
    "Clinical outcomes,\ndecision changes"
  )
)

p <- ggplot() +
  geom_tile(data = boxes, aes(x = x, y = y),
            width = 0.85, height = 0.55,
            fill = "white", colour = "black", linewidth = 0.5) +
  geom_text(data = boxes, aes(x = x, y = y, label = label),
            size = 3.2, lineheight = 0.9) +
  geom_text(data = sublabels, aes(x = x, y = y, label = label),
            size = 2.3, colour = "grey40", lineheight = 0.85) +
  # Arrows between boxes
  annotate("segment",
           x = 1:3 + 0.45, xend = 2:4 - 0.45,
           y = 0, yend = 0,
           arrow = arrow(length = unit(0.15, "cm"), type = "closed"),
           linewidth = 0.5) +
  # "Increasing generalisability" brace
  annotate("segment", x = 1, xend = 4, y = 0.45, yend = 0.45,
           linewidth = 0.3, colour = "grey50") +
  annotate("segment", x = 1, xend = 1, y = 0.42, yend = 0.45,
           linewidth = 0.3, colour = "grey50") +
  annotate("segment", x = 4, xend = 4, y = 0.42, yend = 0.45,
           linewidth = 0.3, colour = "grey50") +
  annotate("text", x = 2.5, y = 0.55,
           label = "Increasing generalisability", size = 2.8,
           colour = "grey40", fontface = "italic") +
  scale_x_continuous(limits = c(0.3, 4.7)) +
  scale_y_continuous(limits = c(-0.75, 0.7)) +
  coord_fixed(ratio = 1.8) +
  theme_void()

ggsave("figures/Introduction/validation_levels.pdf", plot = p,
       width = 14, height = 5, units = "cm", device = cairo_pdf)
