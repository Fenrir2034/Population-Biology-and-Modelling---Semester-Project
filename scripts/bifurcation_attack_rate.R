# ============================================================
# bifurcation_attackrate.R
# Predator-mediated coexistence / keystone (mortality) bifurcation
# ============================================================

library(tidyverse)
library(deSolve)
source("R/model_functions.R")

simulate_maxP <- function(m_val) {
  parms <- c(
    r1 = 1.0, r2 = 0.8,
    K1 = 1.0, K2 = 1.2,
    alpha12 = 0.5, alpha21 = 0.4,
    a1 = 1.0, a2 = 0.8,
    h1 = 0.5, h2 = 0.5,
    e = 0.8, m = m_val
  )
  
  state <- c(N1 = 0.4, N2 = 0.3, P = 0.2)
  times <- seq(0, 500, by = 0.5)
  out <- ode(y = state, times = times, func = two_prey_predator, parms = parms)
  
  # Extract steady-state or oscillatory maxima
  last <- tail(out, 500)
  tibble(m = m_val, Pmax = max(last[, "P"]))
}

m_grid <- seq(0.1, 1.0, by = 0.01)
bif <- map_dfr(m_grid, simulate_maxP)

ggplot(bif, aes(x = m, y = Pmax)) +
  geom_point(size = 0.8, alpha = 0.7) +
  labs(
    title = "Predator-mediated coexistence (keystone mortality bifurcation)",
    x = "Predator mortality (m)",
    y = "Local maxima of predator P"
  ) +
  theme_minimal()

ggsave("figures/bifurcation_keystone.png", width = 7, height = 5)
write.csv(bif, "data/bifurcation_keystone.csv", row.names = FALSE)
