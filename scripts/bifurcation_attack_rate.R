# ============================================================
# bifurcation_attackrate.R
# Predator-mediated coexistence / keystone (mortality) bifurcation
# ============================================================
# This script performs a bifurcation analysis by varying predator mortality (m).
# In practice, we repeatedly simulate the predator–prey model for different
# values of m and record, for each value, a summary of the predator's dynamics.
# Here we use the local maximum of predator density at late times (Pmax) as
# our bifurcation variable: Pmax ≈ equilibrium predator density if the system
# is at a fixed point, or the peak of oscillations if the system cycles.

library(tidyverse)   # Loads ggplot2, dplyr, purrr, tibble, and other tidyverse tools
library(deSolve)     # Provides 'ode()' for numerically integrating ODE systems
source("R/model_functions.R")  # Imports the function 'two_prey_predator' that defines the ODEs

# ----------------------------------------------------------------
# Function: simulate_maxP
# Purpose:  For a given predator mortality value m_val, run the ODE
#           simulation and extract the maximum predator density P
#           over the final part of the time series.
# ----------------------------------------------------------------
simulate_maxP <- function(m_val) {   # Define a function taking one argument: the predator mortality m
  
  parms <- c(                      # Create a named numeric vector of model parameters
    r1 = 1.0, r2 = 0.8,            # r1, r2: intrinsic growth rates of prey 1 and prey 2 (per unit time)
    K1 = 1.0, K2 = 1.2,            # K1, K2: carrying capacities for prey 1 and prey 2 (maximum densities)
    alpha12 = 0.5, alpha21 = 0.4,  # α12, α21: interspecific competition coefficients (effect of one prey on the other)
    a1 = 1.0, a2 = 0.8,            # a1, a2: predator attack (search) rates on prey 1 and prey 2 (per density per time)
    h1 = 0.5, h2 = 0.5,            # h1, h2: handling times for each prey (time spent processing each captured prey)
    e = 0.8,                       # e: conversion efficiency (fraction of consumed prey biomass converted to predator growth)
    m = m_val                      # m: predator mortality rate (per unit time), set to the value passed into the function
  ) 
  
  state <- c(                      # Initial conditions for the state variables
    N1 = 0.4,                      # Initial density of prey 1
    N2 = 0.3,                      # Initial density of prey 2
    P  = 0.2                       # Initial density of the predator
  ) 
  
  times <- seq(0, 500, by = 0.5)   # Vector of time points from t = 0 to t = 500 in steps of 0.5 time units
                                   # A long integration window allows transients to decay
  
  out <- ode(                      # Numerically integrate the ODE system
    y     = state,                 #   y: vector of initial state values
    times = times,                 #   times: time sequence at which solutions are requested
    func  = two_prey_predator,     #   func: ODE function (from model_functions.R) computing dN1/dt, dN2/dt, dP/dt
    parms = parms                  #   parms: parameter vector passed into the ODE function
  )                                # 'out' is a matrix-like object: first column = time, others = state variables
  
  # Extract steady-state or late-time behavior
  last <- tail(out, 500)           # Keep only the last 500 rows (the "late-time" segment of the trajectory);
                                   # this reduces the influence of initial transients
  
  # Construct a tidy tibble summarizing the result for this particular m value
  tibble(
    m    = m_val,                  # Store the mortality value used in this simulation
    Pmax = max(last[, "P"])        # Pmax: maximum predator density over the final segment;
                                   # acts as an indicator of equilibrium density or oscillation amplitude
  )
}

# Grid of mortality values over which we perform the bifurcation analysis
m_grid <- seq(0.1, 1.0, by = 0.01)  # Sequence of m values from 0.1 to 1.0 in steps of 0.01

# For each mortality value in m_grid, run simulate_maxP and row-bind the results
bif <- map_dfr(m_grid, simulate_maxP)  # 'map_dfr' applies simulate_maxP to every m in m_grid
                                       # and combines all returned tibbles into one data frame 'bif'

# Plot the bifurcation diagram
ggplot(bif, aes(x = m, y = Pmax)) +    # Initialize ggplot: x-axis = predator mortality m, y-axis = Pmax
  geom_point(size = 0.8, alpha = 0.7) +   # Draw points for each (m, Pmax); small points with some transparency
  labs(
    title = "Predator-mediated coexistence (keystone mortality bifurcation)",  # Plot title
    x = "Predator mortality (m)",                                             # X-axis label
    y = "Local maxima of predator P"                                          # Y-axis label
  ) +
  theme_minimal()                        # Use a clean, minimal theme for aesthetics

# Save the bifurcation plot to disk as a PNG image
ggsave(
  "figures/bifurcation_keystone.png",    # File path where the figure will be written
  width  = 7,                            # Width of the image (in inches)
  height = 5                             # Height of the image (in inches)
)

# Save the raw numerical bifurcation data to a CSV file for reproducibility / later analysis
write.csv(
  bif,                                   # Data frame containing (m, Pmax) pairs
  "data/bifurcation_keystone.csv",       # Output file path
  row.names = FALSE                      # Do not include row numbers as a separate column
)
