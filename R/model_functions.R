# Model functions for two-prey one-predator Rosenzweig–MacArthur model
# ============================================================
# this code defines the ODE system and a wrapper function to run simulations
# and ODE system is when the predator has a Holling type II functional response to both prey 
# meaninhg that the predation rate saturates at high prey densities

library(deSolve) # for ODE solving
library(tibble) # for tibbles

# Two-prey one-predator Rosenzweig–MacArthur model
two_prey_predator <- function(t, y, p) { # y: state variables, p: parameters
  with(as.list(c(y, p)), { # unpack state variables and parameters
    denom <- 1 + a1 * h1 * N1 + a2 * h2 * N2 # functional response denominator
    f1 <- (a1 * N1 / denom) # functional response for prey 1
    f2 <- (a2 * N2 / denom)     # functional response for prey 2

    dN1 <- r1 * N1 * (1 - (N1 + alpha12 * N2) / K1) - f1 * P    # prey 1 equation
    dN2 <- r2 * N2 * (1 - (N2 + alpha21 * N1) / K2) - f2 * P   # prey 2 equation
    dP  <- e * (f1 + f2) * P - m * P                          # predator equation

    list(c(dN1, dN2, dP)) # return the rates of change
  })
}

# Wrapper function to integrate system through time
run_sim <- function(p, y0 = c(N1 = 0.5, N2 = 0.3, P = 0.1), tmax = 500) { # default initial conditions and time
  times <- seq(0, tmax, by = 0.5) # time sequence
  out <- deSolve::ode(y = y0, times = times, # integrate ODEs
                      func = two_prey_predator, parms = p, # parameters
                      method = "rk4") # Runge-Kutta 4th order method
  tibble::as_tibble(out) # convert output to tibble and return
}
