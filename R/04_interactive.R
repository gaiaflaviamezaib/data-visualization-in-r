# Module 4: interactive plots with plotly.
# Output is an HTML file: open output/gapminder_animated.html in a browser.

library(ggplot2)
library(plotly)
library(gapminder)
library(htmlwidgets)

dir.create("output", showWarnings = FALSE)

# ggplot -> plotly: hover shows the country, the slider animates the years
p <- ggplot(gapminder, aes(gdpPercap, lifeExp, colour = continent)) +
  geom_point(aes(size = pop, frame = year, text = country), alpha = 0.7) +
  scale_x_log10() +
  scale_size_area(max_size = 15, guide = "none") +
  labs(x = "GDP per capita (log scale)", y = "life expectancy", colour = NULL) +
  theme_minimal()

widget <- ggplotly(p, tooltip = c("text", "x", "y")) |>
  animation_opts(frame = 600, redraw = FALSE) |>
  animation_slider(currentvalue = list(prefix = "year "))

# selfcontained = TRUE needs pandoc, so the JS libraries go in a side folder
saveWidget(widget, "output/gapminder_animated.html",
           selfcontained = FALSE, libdir = "lib", title = "Gapminder")
