### Predator-Mediated Coexistence and Keystone Species
# Predator-Mediated Coexistence and Keystone Species
 
**Course:** Population Biology and Modelling — M1 Computational Biology  
**Institution:** Aix-Marseille Université
**Language:** R (`deSolve`, `ggplot2`, `purrr`, `dplyr`, `tibble`)  

---

## Intro

This project explores **predator-mediated coexistence** which is a key ecological mechanism where a shared predator promotes coexistence among competing prey species by preferentially suppressing the stronger competitor.  
Through numerical simulations of a **two-prey, one-predator dynamical system**, the project examines how predator mortality and feeding preferences determine whether all species coexist or one prey excludes the other.

The predator thereby acts as a **keystone species**: removing it collapses coexistence and reduces community diversity.

---

## Model

We use a 2-prey–1-predator Rosenzweig–MacArthur system.

State variables:
- N1: prey 1
- N2: prey 2
- P: predator

Parameters:
- r1, r2: intrinsic growth rates
- K1, K2: carrying capacities
- a1, a2: predator attack rates on N1, N2
- h1, h2: handling times
- alpha12: effect of species 2 on species 1 (competition)
- alpha21: effect of species 1 on species 2
- e: conversion efficiency
- m: predator mortality

Dynamics (human-readable):

We use a 2-prey–1-predator Rosenzweig–MacArthur model:

```math
\begin{aligned}
\frac{dN_1}{dt} &= r_1 N_1 \left(1 - \frac{N_1 + \alpha_{12} N_2}{K_1}\right)
  - \frac{a_1 N_1 P}{1 + a_1 h_1 N_1 + a_2 h_2 N_2}, \\
\\
\frac{dN_2}{dt} &= r_2 N_2 \left(1 - \frac{N_2 + \alpha_{21} N_1}{K_2}\right)
  - \frac{a_2 N_2 P}{1 + a_1 h_1 N_1 + a_2 h_2 N_2}, \\
\\
\frac{dP}{dt} &= e \frac{a_1 N_1 + a_2 N_2}{1 + a_1 h_1 N_1 + a_2 h_2 N_2} P - mP.
\end{aligned}
```



---

##structure



PredatorMediatedCoexistence/
├── R/

│   └── model_functions.R           # ODE definitions + solver

├── scripts/

│   ├── run_all.R # run everything with one command

│   ├── simulate_two_prey_predator.R # time-series simulation

│   ├── bifurcation_attackrate.R     # keystone (mortality) bifurcation

│   └── sensitivity_keystone.R       # optional 2D parameter sweep

├── data/                            # output tables (.csv)

├── figures/                         # plots (phase planes, bifurcations)

├── README.md                        # this file

└── PredatorMediatedCoexistence.Rproj



---

## Quick start

### 1. Clone the repository
```bash
git clone https://github.com/Fenrir2034/Population-Biology-and-Modelling---Semester-Project.git
cd Population-Biology-and-Modelling---Semester-Project
````

### Run the simulation (installs dependencies if not already installed)

```r
source("scripts/run_all.R")
```

This produces a time-series plot of predator and prey abundances showing predator-mediated coexistence and sweeps predator mortality (`m`) to visualize how predator removal drives competitive exclusion.


## Expected results

| Ecological regime | Description                                                      |
| ----------------- | ---------------------------------------------------------------- |
| **Coexistence**   | Predator regulates dominant prey, allowing both prey to persist. |
| **Exclusion**     | Predator extinct → competitive exclusion by one prey.            |
| **Oscillations**  | Moderate enrichment → predator–prey limit cycles.                |

---


