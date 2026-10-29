# Module 3: specialised plots for health data.
# Data: survival::lung (NCCTG advanced lung cancer trial) and penguins.

library(ggplot2)
library(dplyr)
library(survival)
library(survminer)
library(pheatmap)
library(palmerpenguins)

dir.create("figures", showWarnings = FALSE)

# Kaplan-Meier survival curves by sex, with log-rank test and risk table
lung2 <- survival::lung |>
  mutate(sex = factor(sex, levels = c(1, 2), labels = c("male", "female")))

fit <- survfit(Surv(time, status) ~ sex, data = lung2)
km <- ggsurvplot(
  fit, data = lung2,
  pval = TRUE, conf.int = TRUE, risk.table = TRUE,
  xscale = "d_m", break.time.by = 182.6, xlab = "months",
  palette = c("#2E86AB", "#E4572E"),
  legend.labs = c("male", "female"), legend.title = "",
  ggtheme = theme_minimal(base_size = 11)
)
png("figures/03_kaplan_meier.png", width = 7, height = 6, units = "in", res = 150)
print(km)
dev.off()

med <- surv_median(fit)
write.csv(med, "figures/03_median_survival.csv", row.names = FALSE)

# Cox model: hazard ratio for sex, adjusted for age and ECOG score
cox <- coxph(Surv(time, status) ~ sex + age + ph.ecog, data = lung2)
png("figures/03_cox_forest.png", width = 7, height = 4.2, units = "in", res = 150)
print(ggforest(cox, data = lung2))
dev.off()

# Heatmap: scaled penguin measurements, rows clustered, annotated by species
peng <- penguins |> filter(if_all(c(bill_length_mm:body_mass_g, sex), ~ !is.na(.)))
mat <- peng |> select(bill_length_mm:body_mass_g) |> as.matrix() |> scale()
rownames(mat) <- paste0("p", seq_len(nrow(mat)))
annot <- data.frame(species = peng$species, sex = peng$sex, row.names = rownames(mat))

pheatmap(
  t(mat),
  annotation_col = annot,
  show_colnames = FALSE,
  clustering_method = "ward.D2",
  color = colorRampPalette(c("#2166AC", "white", "#B2182B"))(50),
  main = "Penguin measurements (z-scores), clustered",
  filename = "figures/03_heatmap.png", width = 9, height = 4
)
