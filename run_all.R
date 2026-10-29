# Regenerate every figure: Rscript run_all.R (from the repo root)

packages <- c("ggplot2", "dplyr", "tidyr", "ggridges", "colorspace", "pheatmap",
              "survival", "survminer", "plotly", "htmlwidgets", "palmerpenguins",
              "gapminder", "shiny", "scales")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")

for (script in sort(list.files("R", pattern = "\\.R$", full.names = TRUE))) {
  message("== ", script)
  source(script, local = new.env())
}

# make sure the Shiny app at least builds
stopifnot(inherits(source("app/app.R", local = new.env())$value, "shiny.appobj"))
message("done")
