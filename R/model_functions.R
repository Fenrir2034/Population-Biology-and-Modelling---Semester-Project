# ============================================================
# model_functions.R
# Rosenzweig–MacArthur model (two prey, one predator)
# ============================================================

library(deSolve)

# ---- ODE system ----
two_prey_predator <- function(t, state, parms) {
  with(as.list(c(state, parms)), {
    
    # functional response denominator
    denom <- 1 + a1 * h1 * N1 + a2 * h2 * N2
    
    dN1 <- r1 * N1 * (1 - (N1 + alpha12 * N2) / K1) -
      (a1 * N1 * P) / denom
    
    dN2 <- r2 * N2 * (1 - (N2 + alpha21 * N1) / K2) -
      (a2 * N2 * P) / denom
    
    dP <- e * (a1 * N1 + a2 * N2) / denom * P - m * P
    
    list(c(dN1, dN2, dP))
  })
}
