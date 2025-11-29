# DC Motor Position Control – SAE II Lab (2025)

![MATLAB](https://img.shields.io/badge/MATLAB-State--Space-orange)
![Control](https://img.shields.io/badge/Topic-Control%20Systems-blue)
![Hardware](https://img.shields.io/badge/Hardware-DC%20Motor%20%2B%20Arduino-lightgrey)

This repository contains my work for the **Control Systems II Laboratory (SAE II)**, focusing on **position control of a DC motor** using **state-space methods, pole placement, integral action and state observers**.  
The project combines **theory, MATLAB code and real hardware experiments** and was completed in 2025.

---

## 📌 Project Overview

The goal of this project is to:

- Model a DC motor + tachogenerator + position sensor system.
- Experimentally identify the system parameters from step responses.
- Design and implement:
  - **State feedback control** (position & speed).
  - **State feedback with integral action** for disturbance rejection.
  - **Observer-based output feedback** using a **Luenberger observer**.
- Run the controllers on real hardware (DC motor controlled via **Arduino**) and analyze the results in MATLAB.

This work demonstrates the complete workflow from **modeling → controller design → implementation → experimental validation**.

---

## 🧠 System & Modeling

The plant is a DC motor with tachogenerator and position sensor. The modeling is done in the **state-space** domain using:

- State vector:

  $$
  x =
  \begin{bmatrix}
    \theta \\
    v_\text{tacho}
  \end{bmatrix}
  $$

  where:

  - $\theta$: position (V)  
  - $v_\text{tacho}$: tachogenerator voltage (V)

- General state–space form:

  $$
  \dot{x} = A x + B u, \quad y = C x
  $$

The constants are experimentally identified from measured step responses and oscilloscope data.

### Identified Parameters

| Constant | Description                       | Value    |
|----------|-----------------------------------|----------|
| $k_m$    | Motor gain                        | 220      |
| $k_\tau$ | Tachogenerator gain               | 0.004    |
| $k_\mu$  | Gear / position sensor gain       | 0.027    |
| $k_o$    | Integrator/position scaling       | 0.24     |
| $T_m$    | Motor time constant               | 0.531 s  |

These values are used to construct the state-space matrices $A$, $B$, $C$ and to design all controllers.

---

## 🔬 Lab Exercises (Structure of the Project)

The project is organized conceptually into **four lab exercises**:

### 1️⃣ Lab 1 – Modeling & Parameter Identification

- Derivation of the transfer function for the DC motor and tachogenerator.
- Experimental measurement of:
  - Step response (steady-state values and time constant).
  - Tachogenerator and position sensor outputs.
- Identification of $k_m, k_\tau, k_\mu, k_o, T_m$.
- Construction of the **state-space model** used in all subsequent labs.

---

### 2️⃣ Lab 2 – State Feedback Position Control

Goal: control the **position** of the motor shaft so that  
$\theta(t) \to \theta_\text{ref} = 5\ \text{V}$ starting from $\theta_0 = 2\ \text{V}$.

Main steps:

- Define state feedback control law:

  $$
  u = -Kx + k_r r
  $$

  with full state feedback (position & speed).

- Select **closed-loop poles** (e.g. double pole at $-7$) to:
  - Ensure **stability**.
  - Achieve **minimum possible settling time**.
  - **Avoid overshoot** given the hardware limits (±10 V from Arduino).
- Implement pole placement in MATLAB using symbolic equations.
- Run experiments on the real setup:
  - Record **position**, **speed**, and **control input**.
  - Confirm no overshoot and fast settling within voltage constraints.
- Analyze steady-state error:
  - Identify causes: disturbances, measurement noise, unmodeled friction.
  - Discuss how increasing $k_1$ (position gain) affects disturbance rejection vs. measurement noise.

Additional experiment:

We also track sinusoidal references of the form:

$$
\theta_\text{ref}(t) = 5 + 2\sin(\omega t)
$$

for different frequencies $\omega$.

We observe:

- Amplitude attenuation for higher frequencies.
- Phase delay increasing with $\omega$.

---

### 3️⃣ Lab 3 – Dynamic State Feedback with Integral Action

Goal: **eliminate steady-state error** and **reject disturbances**.

Approach:

We augment the system with an integral state:

$$
z = \int (\theta - r)\, dt
$$

and define the extended state:

$$
x_b =
\begin{bmatrix}
  \theta \\
  v_\text{tacho} \\
  z
\end{bmatrix}
$$

We then use dynamic state feedback:

$$
u = -K x_b, \quad K = [k_1\ k_2\ k_i]
$$

- Choose desired closed-loop poles (e.g. $-7, -7, -5$) and compute gains in MATLAB.
- Implement on hardware:
  - Initially observe a small overshoot and long transient (~3.5 s).
  - Tune the speed gain $k_2$ to reduce overshoot and transient time.

Final results:

- **Zero steady-state error**.
- **No overshoot** after tuning.
- **Settling time** close to the physical limit imposed by the 10 V hardware constraint.

---

### 4️⃣ Lab 4 – Observer Design & Output Feedback

Goal: design a **Luenberger observer** and use **output feedback** when only position is measured.

#### 4.1 Observer Design

- Assume only position $\theta$ is measured.
- Check **controllability** and **observability** from matrices $A$, $B$, $C$.
- Design a Luenberger observer:

  $$
  \dot{\hat{x}} = A\hat{x} + B u + L\bigl(y - C\hat{x}\bigr)
  $$

- Place observer poles (e.g. $-20, -25$) to ensure fast estimation.
- Verify experimentally:
  - Compare real states vs. estimated states.
  - Confirm the observer tracks the states well after a short transient.

#### 4.2 Output Feedback Control

Use the estimated state $\hat{x}$ in the control law:

$$
u = -K\hat{x} + k_r r
$$

- Keep controller poles fixed and vary observer poles:
  - Faster observer → quicker convergence of estimation error, but sharper control action.
  - Slower observer → smoother control, but longer settling time and slower estimation.
- Record and compare:
  - Actual vs. estimated states.
  - Control input.
  - Position response (overshoot, settling time, steady-state error).

---
