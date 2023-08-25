# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import plotly
import chroma
import yaml/serialization, streams
import sugar
import std/math
import os

const PLANES_DIR = "./planes"

### Physics
type
  Plane = object
    name: string    # Name of the plane.
    S: float64      # Wing area of the plan. m²
    W: float64      # Weight of the aircraft, Gross takeoff Weight + fuel kg
    CL_max: float64 # Maximun Lift coefficient

const
  nmax = 9.0        # Maximum G load factor considered, G
  Vmax = 1000.float # Maximum Speed considered m/s
  ρ = 1.204        # Air density kg/m^3
  g = 9.80665       # Gravity m/s^2

            # from https://aviation.stackexchange.com/questions/96827/computing-an-energy-maneuverability-e-m-diagram-for-an-aircraft
func calculate_turn(plane: Plane, speed: float): float =
  let vto = sqrt(plane.W / (0.5 * ρ * plane.CL_max * plane.S)) # Speed to take off
 # (g * sqrt(( (ρ * speed^2 * plane.S * plane.CL_max)/(2 * plane.W * g))^2 -
 #     1)) / (speed * vto * sqrt(nmax))
  radToDeg(tan(arccos(1/nmax))) * (g / vto * sqrt(nmax))


### Simulation
let nb_data_point = 100 # How many data point to show on the graph.



when isMainModule:

  var speeds = collect:
    for i in 1..nb_data_point:
      i.float * Vmax.float/nb_data_point.float

  echo speeds
  var planes: seq[Plane]
  var turns = newSeq[seq[float]]()

  # First load the all the planes to simulate.
  if dirExists(PLANES_DIR):
    let files = collect(newSeq):
      for file in walkDir(PLANES_DIR): file

    if files.len == 0:
      echo "No planes found in ", PLANES_DIR

    for file in files:
      var s = newFileStream(file[1])
      load(s, planes)
      s.close()
      echo "Loaded ", planes[^1].name, " from file ", file[1]

  else:
    echo "Planes directory not found."

  # Then simulate the maximun turn rate for any given airspeed for each airplane.

  # for plane in planes:
  #   var tmp = newSeq[float]()
  #   for i in 0..<nb_data_point:
  #     tmp.add calculate_turn(plane, speeds[i]).radToDeg
  #   echo tmp
  #   turns.add(tmp)

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

  # Finally, render the graph
  var dd: seq[Trace[float]] = collect:
    for i in 0..<planes.len:
      (var d = Trace[float](mode: PlotMode.LinesMarkers,
          `type`: PlotType.Scatter, name: planes[i].name);
      d.xs = speeds;
      d.ys = turns[i];
      d)

  var layout = Layout(
    title: "Energy Maneuvering Diagram at sea level",
    width: 1200,
    height: 800,
    xaxis: Axis(title: "Speed TAS [m/s]"),
    yaxis: Axis(title: "Turn rate [deg/s]"),
    autosize: true
  )
  var p = Plot[float](layout: layout, traces: dd)
  p.show()
