# ============================================================
# sensitivity_keystone.R
# 2D parameter sweep: mortality (m) × attack rate (a1)
# ============================================================
# This script performs a *two-dimensional sensitivity analysis*.
#
# We vary TWO parameters:
#   1. Predator mortality (m)
#   2. Predator attack rate on prey 1 (a1)
#
# For each pair (m, a1), we simulate the ODE system, extract the late-time
# mean predator density, and store it. Plotting these values produces a
# *heatmap showing where the predator persists or goes extinct*.
#
# This is essentially a 2D bifurcation map: a region of coexistence.
# ============================================================

library(deSolve)      # For numerical integration of ODEs
library(tidyverse)    # For data frames, plotting, and functional mapping
source("R/model_functions.R")  # Load the ODE model function

# ------------------------------------------------------------
# FUNCTION: simulate_eq(m_val, a1_val)
# Simulates the model for a given mortality m_val and attack
# rate a1_val, then returns the mean predator density at the
# end of the simulation (equilibrium or cycle).
# ------------------------------------------------------------
simulate_eq <- function(m_val, a1_val) {

  parms <- c(               # Define parameter vector
    r1 = 1.0, r2 = 0.8,     # Prey intrinsic growth rates
    K1 = 1.0, K2 = 1.2,     # Carrying capacities
    alpha12 = 0.5, alpha21 = 0.4,   # Competition between prey species
    a1 = a1_val, a2 = 0.8,  # Attack rates; a1 is varied in the grid
    h1 = 0.5, h2 = 0.5,     # Handling times for Holling Type II response
    e = 0.8,                # Conversion efficiency
    m = m_val               # Predator mortality, varied in the grid
  )

  state <- c(               # Initial conditions
    N1 = 0.4,               # Prey 1
    N2 = 0.3,               # Prey 2
    P  = 0.2                # Predator
  )

  times <- seq(0, 400, by = 0.5)  # Integration time range
                                  # Long enough for transients to die out

  out <- ode(                    # Numerical integration of the ODE system
    y     = state,
    times = times,
    func  = two_prey_predator,   # ODE function from model_functions.R
    parms = parms
  )

  last <- tail(out, 200)         # Extract the final 200 time points
                                 # (this avoids initial transients)

  tibble(
    m    = m_val,                # Store tested mortality
    a1   = a1_val,               # Store tested attack rate
    Pmean = mean(last[, "P"])    # Mean predator density at late time
                                 # Zero → predator extinction
                                 # High → predator persistence
  )
}

# ------------------------------------------------------------
# BUILD THE PARAMETER GRID
# ------------------------------------------------------------
# expand_grid() creates all combinations of m and a1.
grid <- expand_grid(
  m  = seq(0.2, 1.0, 0.05),      # Mortality values from 0.2 to 1.0
  a1 = seq(0.5, 1.5, 0.05)       # Attack rate values from 0.5 to 1.5
)

# ------------------------------------------------------------
# RUN SENSITIVITY ANALYSIS ACROSS THE GRID
# ------------------------------------------------------------
# map2_dfr applies simulate_eq() to each pair of (m, a1)
sens <- map2_dfr(
  grid$m,
  grid$a1,
  simulate_eq               # For each pair, compute equilibrium predator density
)

# ------------------------------------------------------------
# PLOT THE SENSITIVITY HEATMAP
# ------------------------------------------------------------
ggplot(sens, aes(x = a1, y = m, fill = Pmean)) +
  geom_tile() +                   # Heatmap tiles
  scale_fill_viridis_c() +        # Nice continuous color scale
  labs(
    title = "Predator persistence region (keystone sensitivity)",  # Title
    x = "Attack rate (a1)",        # Horizontal axis: predator efficiency
    y = "Mortality (m)",           # Vertical axis: predator death rate
    fill = "Mean P"                # Legend label: mean predator density
  ) +
  theme_minimal()

# Save the figure
ggsave(
  "figures/sensitivity_keystone.png",
  width = 7,
  height = 5
)

# Save numerical results to CSV
write.csv(
  sens,
  "data/sensitivity_surface.csv",
  row.names = FALSE
)
