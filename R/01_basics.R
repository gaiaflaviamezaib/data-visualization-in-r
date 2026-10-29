# Module 1: one variable at a time, then groups.
# Data: Palmer penguins (palmerpenguins package).

library(ggplot2)
library(dplyr)
library(palmerpenguins)

dir.create("figures", showWarnings = FALSE)
theme_set(theme_minimal(base_size = 12))

peng <- penguins |> filter(!is.na(sex), !is.na(body_mass_g))

# bar plot: counts of a discrete variable
p <- ggplot(peng, aes(island, fill = species)) +
  geom_bar() +
  labs(title = "Penguins per island", x = NULL, y = "count")
ggsave("figures/01_bar.png", p, width = 6, height = 4, dpi = 150)

# histogram vs density for a continuous variable
p <- ggplot(peng, aes(flipper_length_mm, fill = species)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 3, alpha = 0.4, position = "identity") +
  geom_density(alpha = 0.3) +
  labs(title = "Flipper length: histogram + density", x = "flipper length (mm)")
ggsave("figures/01_hist_density.png", p, width = 7, height = 4, dpi = 150)

# group comparison: a mean +/- error bar hides the data...
summary_tbl <- peng |>
  group_by(species) |>
  summarise(mean = mean(body_mass_g), se = sd(body_mass_g) / sqrt(n()), n = n())
p_bad <- ggplot(summary_tbl, aes(species, mean)) +
  geom_col(fill = "grey70") +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.2) +
  labs(title = "Mean +/- SE only", y = "body mass (g)", x = NULL)

# ...a violin + jittered points shows the whole distribution and n
p_good <- ggplot(peng, aes(species, body_mass_g, colour = species)) +
  geom_violin(fill = NA) +
  geom_jitter(width = 0.15, alpha = 0.5, size = 1) +
  stat_summary(fun = mean, geom = "point", size = 3, colour = "black") +
  labs(title = "Every penguin + the mean", y = "body mass (g)", x = NULL) +
  theme(legend.position = "none")

ggsave("figures/01_mean_only.png", p_bad, width = 4, height = 4, dpi = 150)
ggsave("figures/01_violin_jitter.png", p_good, width = 5, height = 4, dpi = 150)

# box plots split by a second variable
p <- ggplot(peng, aes(species, bill_length_mm, fill = sex)) +
  geom_boxplot(outlier.shape = 21) +
  labs(title = "Bill length by species and sex", x = NULL, y = "bill length (mm)")
ggsave("figures/01_box_by_sex.png", p, width = 6, height = 4, dpi = 150)
