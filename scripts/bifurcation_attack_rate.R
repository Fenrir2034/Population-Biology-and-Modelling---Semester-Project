# ============================================================
# bifurcation_attackrate.R
# Predator-mediated coexistence / keystone (mortality) bifurcation
# ============================================================
# this script performs a bifurcation analysis by varying predator mortality (m) 
# meaning that we look at how the equilibrium densities of prey and predator change as we change m
library(tidyverse)
library(deSolve)
source("R/model_functions.R")

simulate_maxP <- function(m_val) { # simulate and get max predator P
  parms <- c( # parameters
    r1 = 1.0, r2 = 0.8, # growth rates
    K1 = 1.0, K2 = 1.2, # carrying capacities
    alpha12 = 0.5, alpha21 = 0.4, # competition coefficients
    a1 = 1.0, a2 = 0.8, # attack rates
    h1 = 0.5, h2 = 0.5, # handling times
    e = 0.8, m = m_val # efficiency and mortality
  ) 
  
  state <- c(N1 = 0.4, N2 = 0.3, P = 0.2) # initial conditions
  times <- seq(0, 500, by = 0.5) # time sequence
  out <- ode(y = state, times = times, func = two_prey_predator, parms = parms) # integrate ODEs
  
  # Extract steady-state or oscillatory maxima
  last <- tail(out, 500) # last part of the time series
  tibble(m = m_val, Pmax = max(last[, "P"])) # return max predator P
}

m_grid <- seq(0.1, 1.0, by = 0.01) # mortality values
bif <- map_dfr(m_grid, simulate_maxP) # run simulations over grid

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
