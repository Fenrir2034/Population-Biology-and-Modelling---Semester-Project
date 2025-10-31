# ============================================================
# sensitivity_keystone.R
# 2D parameter sweep: mortality (m) × attack rate (a1)
# ============================================================
# this script performs a sensitivity analysis by varying both predator mortality (m) and attack rate on prey 1 (a1)
# meaning that we look at how the equilibrium density of the predator changes as we change both m and a1
# we then plot a heatmap of predator equilibrium density over this 2D parameter space
library(deSolve)
library(tidyverse)
source("R/model_functions.R")

simulate_eq <- function(m_val, a1_val) { # simulate and get mean predator P at equilibrium
  parms <- c( # parameters
    r1 = 1.0, r2 = 0.8, # growth rates
    K1 = 1.0, K2 = 1.2, # carrying capacities
    alpha12 = 0.5, alpha21 = 0.4, # competition coefficients
    a1 = a1_val, a2 = 0.8, # attack rates
    h1 = 0.5, h2 = 0.5, # handling times
    e = 0.8, m = m_val # efficiency and mortality
  )
  state <- c(N1 = 0.4, N2 = 0.3, P = 0.2) # initial conditions
  times <- seq(0, 400, by = 0.5) # time sequence
  out <- ode(y = state, times = times, func = two_prey_predator, parms = parms) # integrate ODEs
  last <- tail(out, 200) # last part of the time series
  tibble(m = m_val, a1 = a1_val, Pmean = mean(last[, "P"])) # return mean predator P
}

grid <- expand_grid(m = seq(0.2, 1, 0.05), a1 = seq(0.5, 1.5, 0.05)) # parameter grid
sens <- map2_dfr(grid$m, grid$a1, simulate_eq) # run simulations over grid

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
