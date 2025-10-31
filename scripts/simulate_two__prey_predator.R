# ============================================================
# simulate_two_prey_predator.R
# Time-series simulation
# ============================================================
# this script runs a time-series simulation of the two-prey one-predator Rosenzweig–MacArthur model
# and plots the population dynamics over time
# this is mainly for demonstration and testing purposes
library(ggplot2)
library(deSolve)
source("R/model_functions.R")

# Parameters
parms <- c(
  r1 = 1.0, r2 = 0.8,     # growth rates
  K1 = 1.0, K2 = 1.2,   # carrying capacities
  alpha12 = 0.5, alpha21 = 0.4,       # competition coefficients
  a1 = 1.0, a2 = 0.8,   # attack rates
  h1 = 0.5, h2 = 0.5,   # handling times
  e = 0.8, m = 0.4     # efficiency and mortality
)

state <- c(N1 = 0.4, N2 = 0.3, P = 0.2)     # initial conditions
times <- seq(0, 300, by = 0.1)        # time sequence

out <- ode(y = state, times = times, func = two_prey_predator, parms = parms)   # integrate ODEs

# Plot
matplot(out[, "time"], out[, 2:4], type = "l", lwd = 2, lty = 1,
        col = c("darkgreen", "steelblue", "black"),
        xlab = "Time", ylab = "Population density")
legend("topright", legend = c("N1", "N2", "P"),
       col = c("darkgreen", "steelblue", "black"), lty = 1, lwd = 2)

# Save
write.csv(as.data.frame(out), file = "data/simulation_output.csv", row.names = FALSE)
