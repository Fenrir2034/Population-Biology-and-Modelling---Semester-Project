# ============================================================
# simulate_two_prey_predator.R
# Time-series simulation
# ============================================================

library(deSolve)
source("R/model_functions.R")

# Parameters
parms <- c(
  r1 = 1.0, r2 = 0.8,
  K1 = 1.0, K2 = 1.2,
  alpha12 = 0.5, alpha21 = 0.4,
  a1 = 1.0, a2 = 0.8,
  h1 = 0.5, h2 = 0.5,
  e = 0.8, m = 0.4
)

state <- c(N1 = 0.4, N2 = 0.3, P = 0.2)
times <- seq(0, 300, by = 0.1)

out <- ode(y = state, times = times, func = two_prey_predator, parms = parms)

# Plot
matplot(out[, "time"], out[, 2:4], type = "l", lwd = 2, lty = 1,
        col = c("darkgreen", "steelblue", "black"),
        xlab = "Time", ylab = "Population density")
legend("topright", legend = c("N1", "N2", "P"),
       col = c("darkgreen", "steelblue", "black"), lty = 1, lwd = 2)

# Save
write.csv(as.data.frame(out), file = "data/simulation_output.csv", row.names = FALSE)
