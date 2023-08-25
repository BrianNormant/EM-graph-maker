#!/bin/env python

import numpy as np
import matplotlib.pyplot as plt

# Constants and parameters
Sref = 120
W = 4500
nmax = 7
Vmax = 800
etap = 0.75
Pmax = 1300 * 550
CLmax = 1.5
AR = 5.5
CD0 = 0.021
e = 0.75
rho = 0.0023769
g = 32.1740
nn = 100
nV = 51

# Create arrays for load factors and speeds
ns = np.linspace(1, nmax, nn)
Vs = np.linspace(1, Vmax, nV)

# Initialize arrays to store results
nmat = np.zeros((nn, nV))
Vmat = np.zeros((nn, nV))
Psmat = np.zeros((nn, nV))
CLmat = np.zeros((nn, nV))
omegamat = np.zeros((nn, nV))

# Calculate and store results
for in_ in range(nn):
    n = ns[in_]

    for iV in range(nV):
        V = Vs[iV]

        q = 0.5 * rho * V**2
        L = n * W
        CL = L / (q * Sref)
        CD = CD0 + (CL**2) / (np.pi * e * AR)
        D = CD * q * Sref
        T = Pmax * etap / V
        Ps = V * (T - D) / W
        omega = g * np.sqrt(n**2 - 1.0) / V

        nmat[in_, iV] = n
        Vmat[in_, iV] = V
        Psmat[in_, iV] = Ps
        CLmat[in_, iV] = CL
        omegamat[in_, iV] = omega * 180.0 / np.pi

# Create contour plots
plt.figure(1)

# Contour plot for load factor
# contour1 = plt.contour(Vmat, omegamat, nmat, levels=np.arange(1, nmax + 1), colors='k')

# Contour plot for coefficient of lift
# contour2 = plt.contour(Vmat, omegamat, CLmat, levels=[CLmax], colors='k')

# Contour plot for power required
contour3 = plt.contour(Vmat, omegamat, Psmat, levels=np.arange(0, 1001, 50), colors='k')

plt.xlabel('V (ft/s)')
plt.ylabel('$\omega$ (deg/s)')
plt.xlim(0, Vmax)
plt.ylim(0, 50)
plt.show()
