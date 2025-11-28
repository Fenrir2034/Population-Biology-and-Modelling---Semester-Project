# ============================================================
# simulate_two_prey_predator.R
# Time-series simulation
# ============================================================
# This script performs a basic time-series simulation of the
# Rosenzweig–MacArthur predator–prey model extended to two prey.
#
# It integrates the ODE system over time and visualizes the
# population trajectories of:
#   N1 — prey species 1
#   N2 — prey species 2
#   P  — predator
#
# This script is mainly used for demonstration, quick testing of
# parameter effects, and generating a clear time-series figure.
# ============================================================

library(ggplot2)     # For plotting (though here we use matplot)
library(deSolve)     # For solving ODEs with 'ode()'
source("R/model_functions.R")   # Imports the ODE system: two_prey_predator()

# ------------------------------------------------------------
# PARAMETER DEFINITIONS
# ------------------------------------------------------------
parms <- c(
  r1 = 1.0, r2 = 0.8,                 # Intrinsic growth rates of prey 1 and prey 2
  K1 = 1.0, K2 = 1.2,                 # Carrying capacities (max densities)
  alpha12 = 0.5, alpha21 = 0.4,       # Competition coefficients between the prey
  a1 = 1.0, a2 = 0.8,                 # Predator attack rates on each prey species
  h1 = 0.5, h2 = 0.5,                 # Handling times (Holling type II response)
  e = 0.8,                            # Conversion efficiency (prey biomass → predator growth)
  m = 0.4                             # Predator mortality rate
)

# ------------------------------------------------------------
# INITIAL CONDITIONS FOR THE STATE VARIABLES
# ------------------------------------------------------------
state <- c(
  N1 = 0.4,      # Starting population of prey 1
  N2 = 0.3,      # Starting population of prey 2
  P  = 0.2       # Starting predator density
)

# ------------------------------------------------------------
# TIME VECTOR FOR SIMULATION
# ------------------------------------------------------------
times <- seq(0, 300, by = 0.1)
# Simulation runs from t = 0 to t = 300 in steps of 0.1.
# This gives smooth trajectories and enough time for equilibrium.

# ------------------------------------------------------------
# INTEGRATE THE ODE SYSTEM
# ------------------------------------------------------------
out <- ode(
  y     = state,              # Initial values
  times = times,              # Time sequence
  func  = two_prey_predator,  # ODE function from model_functions.R
  parms = parms               # Parameter vector
)
# 'out' becomes a matrix-like object: first column = time,
# next columns = N1, N2, P over time.

# ------------------------------------------------------------
# PLOT THE TIME SERIES
# ------------------------------------------------------------
matplot(
  out[, "time"],              # x-axis = time
  out[, 2:4],                 # y-values = N1, N2, P (columns 2, 3, 4)
  type = "l",                 # line plot
  lwd  = 2,                   # line width
  lty  = 1,                   # solid lines
  col  = c("darkgreen", "steelblue", "black"),  # colors per species
  xlab = "Time",
  ylab = "Population density"
)

legend(
  "topright",                 # location
  legend = c("N1", "N2", "P"), # labels for lines
  col = c("darkgreen", "steelblue", "black"),
  lty = 1,
  lwd = 2
)

# ------------------------------------------------------------
# SAVE OUTPUT DATA TO CSV
# ------------------------------------------------------------
write.csv(
  as.data.frame(out),                    # Convert to dataframe for export
  file = "data/simulation_output.csv",   # Output file path
  row.names = FALSE                      # No row numbers
)
