### Predator-Mediated Coexistence and Keystone Species
# Predator-Mediated Coexistence and Keystone Species
 
**Course:** Population Biology and Modelling — M1 Computational Biology  
**Institution:** Aix-Marseille Université — Institut de Neurosciences de la Timone  
**Language:** R (`deSolve`, `ggplot2`, `purrr`, `dplyr`, `tibble`)  

---

## Intro

This project explores **predator-mediated coexistence** — a key ecological mechanism where a shared predator promotes coexistence among competing prey species by preferentially suppressing the stronger competitor.  
Through numerical simulations of a **two-prey, one-predator dynamical system**, the project examines how predator mortality and feeding preferences determine whether all species coexist or one prey excludes the other.

The predator thereby acts as a **keystone species**: removing it collapses coexistence and reduces community diversity.

---

## Model

The system is modeled by a **Rosenzweig–MacArthur-type functional response** with two prey (\(N_1, N_2\)) and one predator (\(P\)):

\[
\begin{aligned}
\frac{dN_1}{dt} &= r_1 N_1 \left(1 - \frac{N_1 + \alpha_{12}N_2}{K_1}\right)
                  - \frac{a_1 N_1 P}{1 + a_1 h_1 N_1 + a_2 h_2 N_2}, \\
\frac{dN_2}{dt} &= r_2 N_2 \left(1 - \frac{N_2 + \alpha_{21}N_1}{K_2}\right)
                  - \frac{a_2 N_2 P}{1 + a_1 h_1 N_1 + a_2 h_2 N_2}, \\
\frac{dP}{dt}   &= e \left( \frac{a_1 N_1 + a_2 N_2}{1 + a_1 h_1 N_1 + a_2 h_2 N_2} \right) P
                  - mP.
\end{aligned}
\]

---

## Project structure

