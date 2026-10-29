# Small Shiny app: pick a continent and a year range, see life expectancy vs GDP.
# Run from the repo root with: shiny::runApp("app")

library(shiny)
library(ggplot2)
library(dplyr)
library(gapminder)

ui <- fluidPage(
  titlePanel("Gapminder explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput("continent", "Continent", choices = levels(gapminder$continent),
                  selected = "Africa"),
      sliderInput("years", "Years", min = 1952, max = 2007, value = c(1952, 2007),
                  step = 5, sep = ""),
      checkboxInput("log_x", "Log scale for GDP", value = TRUE)
    ),
    mainPanel(
      plotOutput("scatter", height = "420px"),
      tableOutput("top")
    )
  )
)

server <- function(input, output, session) {
  selected <- reactive({
    gapminder |>
      filter(continent == input$continent,
             between(year, input$years[1], input$years[2]))
  })

  output$scatter <- renderPlot({
    p <- ggplot(selected(), aes(gdpPercap, lifeExp, colour = year)) +
      geom_point(alpha = 0.7) +
      scale_colour_viridis_c() +
      labs(x = "GDP per capita", y = "life expectancy") +
      theme_minimal(base_size = 13)
    if (input$log_x) p <- p + scale_x_log10()
    p
  })

  output$top <- renderTable({
    selected() |>
      filter(year == max(year)) |>
      arrange(desc(lifeExp)) |>
      select(country, year, lifeExp, gdpPercap) |>
      head(5)
  })
}

shinyApp(ui, server)
