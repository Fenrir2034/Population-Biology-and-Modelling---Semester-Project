# ============================================================
# sensitivity_keystone.R
# 2D parameter sweep: mortality (m) × attack rate (a1)
# ============================================================

library(deSolve)
library(tidyverse)
source("R/model_functions.R")

simulate_eq <- function(m_val, a1_val) {
  parms <- c(
    r1 = 1.0, r2 = 0.8,
    K1 = 1.0, K2 = 1.2,
    alpha12 = 0.5, alpha21 = 0.4,
    a1 = a1_val, a2 = 0.8,
    h1 = 0.5, h2 = 0.5,
    e = 0.8, m = m_val
  )
  state <- c(N1 = 0.4, N2 = 0.3, P = 0.2)
  times <- seq(0, 400, by = 0.5)
  out <- ode(y = state, times = times, func = two_prey_predator, parms = parms)
  last <- tail(out, 200)
  tibble(m = m_val, a1 = a1_val, Pmean = mean(last[, "P"]))
}

grid <- expand_grid(m = seq(0.2, 1, 0.05), a1 = seq(0.5, 1.5, 0.05))
sens <- map2_dfr(grid$m, grid$a1, simulate_eq)

ggplot(sens, aes(x = a1, y = m, fill = Pmean)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(
    title = "Predator persistence region (keystone sensitivity)",
    x = "Attack rate (a1)",
    y = "Mortality (m)",
    fill = "Mean P"
  ) +
  theme_minimal()

ggsave("figures/sensitivity_keystone.png", width = 7, height = 5)
write.csv(sens, "data/sensitivity_surface.csv", row.names = FALSE)
