# Module 2: scales, faceting, themes and colour.
# Data: gapminder (life expectancy, GDP per capita, population by country/year).

library(ggplot2)
library(dplyr)
library(gapminder)
library(colorspace)
library(ggridges)

dir.create("figures", showWarnings = FALSE)

latest <- gapminder |> filter(year == max(year))

# same data, linear vs log x axis
base <- ggplot(latest, aes(gdpPercap, lifeExp)) +
  geom_point(aes(size = pop, colour = continent), alpha = 0.7) +
  scale_size_area(max_size = 12, guide = "none") +
  labs(y = "life expectancy (years)", colour = NULL) +
  theme_minimal(base_size = 12)

ggsave("figures/02_linear.png", base + labs(title = "2007, linear GDP axis", x = "GDP per capita"),
       width = 6, height = 4, dpi = 150)

p_log <- base +
  scale_x_log10(labels = scales::label_dollar()) +
  geom_smooth(method = "lm", se = FALSE, colour = "grey30", linewidth = 0.6) +
  labs(title = "2007, log GDP axis", x = "GDP per capita (log scale)")
ggsave("figures/02_log.png", p_log, width = 6, height = 4, dpi = 150)

# faceting: one panel per continent, trajectories over time
p <- ggplot(gapminder, aes(year, lifeExp, group = country)) +
  geom_line(alpha = 0.3, colour = "grey40") +
  stat_summary(aes(group = continent), fun = median, geom = "line",
               colour = "firebrick", linewidth = 1.1) +
  facet_wrap(~continent, nrow = 1) +
  labs(title = "Life expectancy by country (grey) and continent median (red)",
       x = NULL, y = "years") +
  theme_bw(base_size = 10) +
  theme(strip.background = element_rect(fill = "grey95"),
        axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("figures/02_facets.png", p, width = 10, height = 3.5, dpi = 150)

# a custom theme + a colour-blind-friendly qualitative palette
my_theme <- theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"),
        legend.position = "bottom")

p <- ggplot(latest, aes(reorder(continent, lifeExp, FUN = median), lifeExp, fill = continent)) +
  geom_boxplot(alpha = 0.8, outlier.shape = NA) +
  geom_jitter(width = 0.15, size = 0.8, alpha = 0.6) +
  scale_fill_discrete_qualitative(palette = "Dark 3") +
  labs(title = "Life expectancy in 2007", x = NULL, y = "years", fill = NULL) +
  my_theme
ggsave("figures/02_theme_palette.png", p, width = 6, height = 4.5, dpi = 150)

# ridgeline: how the whole distribution moved over 55 years
p <- ggplot(gapminder |> filter(year %in% c(1952, 1967, 1982, 1997, 2007)),
            aes(lifeExp, factor(year), fill = after_stat(x))) +
  geom_density_ridges_gradient(scale = 1.6, rel_min_height = 0.01) +
  scale_fill_continuous_sequential(palette = "Viridis", rev = FALSE, guide = "none") +
  labs(title = "World life expectancy distribution", x = "years", y = NULL) +
  theme_minimal(base_size = 12)
ggsave("figures/02_ridges.png", p, width = 6, height = 4.5, dpi = 150)
