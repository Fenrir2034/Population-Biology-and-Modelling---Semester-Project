# ============================================================
# Master script: Predator-mediated coexistence project
# Author: Eleni Baltzi
# Date: Sys.Date()
# ============================================================

# --- 0. Package setup ---
required_packages <- c("deSolve", "ggplot2", "dplyr", "purrr", "tibble", "readr")

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
root_dir <- getwd()
dir.create(file.path(root_dir, "data"), showWarnings = FALSE)
dir.create(file.path(root_dir, "figures"), showWarnings = FALSE)

# --- 2. Load model functions ---
source("R/model_functions.R")

# --- 3. Define baseline parameters ---
p <- list(
  r1 = 1.0, r2 = 0.9,
  K1 = 1.0, K2 = 1.0,
  alpha12 = 0.7, alpha21 = 0.9,
  a1 = 2.0, a2 = 1.0,  # predator prefers prey 1
  h1 = 0.3, h2 = 0.3,
  e = 0.6, m = 0.4
)

# --- 4. Run single simulation ---
cat("\n Running baseline time-series simulation...\n")

res <- run_sim(p)

# Save CSV
write_csv(res, "data/sim_timeseries.csv")

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
cat("\n📈 Running bifurcation analysis (keystone effect)...\n")

m_values <- seq(0.1, 1.0, by = 0.05)
steady_states <- purrr::map_dfr(m_values, function(mv) {
  p$m <- mv
  out <- run_sim(p)
  last <- tail(out, 1)
  tibble(m = mv, N1 = last$N1, N2 = last$N2, P = last$P)
})

write_csv(steady_states, "data/bifurcation_m.csv")

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
cat("\n✨ Done! You can now include these results in your LaTeX report.\n")
