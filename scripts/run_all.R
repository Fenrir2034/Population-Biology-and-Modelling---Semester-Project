# ============================================================
# Master script: Predator-mediated coexistence project
# Author: Eleni Baltzi
# Date: Sys.Date()
# ============================================================
# This script runs the main simulations and analyses for the predator-mediated coexistence project.
# It includes:
# 1. Package setup
# 2. File path setup
# 3. Loading model functions
# 4. Running a baseline time-series simulation
# 5. Performing a bifurcation analysis by varying predator mortality
# 6. Saving results and figures
# ============================================================  
# this way we have a single script to run all analyses and generate outputs at once!

# --- 0. Package setup ---
required_packages <- c("deSolve", "ggplot2", "dplyr", "purrr", "tibble", "readr") # list of required packages

# install any missing packages
installed <- installed.packages()[, "Package"]
for (pkg in required_packages) {
  if (!pkg %in% installed) {
    message(" Installing missing package: ", pkg)
    install.packages(pkg, dependencies = TRUE)
  }
}

# load all packages
invisible(lapply(required_packages, library, character.only = TRUE))

# --- 1. File paths ---
root_dir <- getwd() # assume script is run from project root
dir.create(file.path(root_dir, "data"), showWarnings = FALSE) # create data directory
dir.create(file.path(root_dir, "figures"), showWarnings = FALSE) # create figures directory

# --- 2. Load model functions ---
source("R/model_functions.R") # load ODE model and simulation functions

# --- 3. Define baseline parameters ---
p <- list( # parameters
  r1 = 1.0, r2 = 0.9, # growth rates
  K1 = 1.0, K2 = 1.0,   # carrying capacities
  alpha12 = 0.7, alpha21 = 0.9, # competition coefficients
  a1 = 2.0, a2 = 1.0,  # predator prefers prey 1
  h1 = 0.3, h2 = 0.3, # handling times
  e = 0.6, m = 0.4 # efficiency and mortality
)

# --- 4. Run single simulation ---
cat("\n Running baseline time-series simulation...\n")

res <- run_sim(p) # run simulation with default initial conditions and tmax=500

# Save CSV
write_csv(res, "data/sim_timeseries.csv") # save results

# Plot and save as PNG + PDF
plot_ts <- ggplot(res, aes(time)) +
  geom_line(aes(y = N1, color = "Prey 1"), linewidth = 1) +
  geom_line(aes(y = N2, color = "Prey 2"), linewidth = 1) +
  geom_line(aes(y = P,  color = "Predator"), linewidth = 1) +
  labs(y = "Population density", color = "Species",
       title = "Predator-mediated coexistence dynamics") +
  theme_minimal(base_size = 14)

ggsave("figures/sim_timeseries.png", plot_ts, width = 7, height = 5, dpi = 300)
ggsave("figures/sim_timeseries.pdf", plot_ts, width = 7, height = 5)

cat(" Time-series simulation complete and saved.\n")

# --- 5. Run bifurcation (predator mortality sweep) ---
cat("\nRunning bifurcation analysis (keystone effect)...\n")

m_values <- seq(0.1, 1.0, by = 0.05) # range of mortality values
steady_states <- purrr::map_dfr(m_values, function(mv) { # for each mortality value
  p$m <- mv # update mortality in parameters
  out <- run_sim(p) # run simulation
  last <- tail(out, 1) # get last time point (steady state)
  tibble(m = mv, N1 = last$N1, N2 = last$N2, P = last$P) # return steady state
})

write_csv(steady_states, "data/bifurcation_m.csv") # save results

plot_bif <- ggplot(steady_states, aes(m)) +
  geom_line(aes(y = N1, color = "Prey 1"), linewidth = 1) +
  geom_line(aes(y = N2, color = "Prey 2"), linewidth = 1) +
  geom_line(aes(y = P, color = "Predator"), linewidth = 1) +
  labs(title = "Keystone effect of predator mortality",
       x = expression("Predator mortality rate " * m),
       y = "Equilibrium abundance",
       color = "Species") +
  theme_minimal(base_size = 14)

ggsave("figures/bifurcation_m.png", plot_bif, width = 7, height = 5, dpi = 300)
ggsave("figures/bifurcation_m.pdf", plot_bif, width = 7, height = 5)

cat("Bifurcation analysis complete and saved.\n")

# --- 6. Summary output ---
cat("\n All simulations complete!\n")
cat(" Results saved to:\n")
cat("   - data/sim_timeseries.csv\n")
cat("   - data/bifurcation_m.csv\n")
cat(" Figures saved to:\n")
cat("   - figures/sim_timeseries.png / .pdf\n")
cat("   - figures/bifurcation_m.png / .pdf\n")
cat("\nDone!.\n")
