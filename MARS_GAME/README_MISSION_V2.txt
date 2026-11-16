MARS — FULL MISSION / Godot 4
=============================
Main scene: scenes/main_menu/main_menu.tscn
Gameplay scene: scenes/game/Marcian_base.tscn
Persistent simulation: scripts/mars_simulation.gd (Autoload)

FLOW
New Game -> Pregame (2-5 astronauts, 1-3 rovers, optional solar/wind) -> Confirm -> Start Game.

MISSION
6 sols. Mission goal: process 150 GB of rover data in the LAB. Rovers never directly increase the progress bar.
Solar/wind/fission maintenance and life-support repair tasks require an assigned astronaut.
Operations: assign astronaut to a module or rest. An idle astronaut does not lose energy.
Lab: assign LAB astronaut to Process Data, Repair Rover, or Idle. Computer processing requires no astronaut but consumes +9 kW.
Automatic rover repair consumes +7 kW. All jobs run continuously across tabs.
Energy: view generation, loads, battery, source status; assign monitoring/repair tasks to ENERGY crew.
Life Support: oxygen kg, water L, temperature Fahrenheit; assign repairs to LIFE SUPPORT crew.
Rovers: charge or collect unprocessed samples. Their condition decreases while collecting.
Mission ends at sol 30 (or catastrophic oxygen/water/temperature failure); mission report includes score, metrics, improvement tips.
Pause -> End Mission Early is available for testing.

MODEL / ASSUMPTIONS (NOT VERIFIED NASA ENGINEERING RATINGS)
Time: 1 sol=1479 game-minutes, 10 game-minutes per real-second.
Fission: 40 kW when intact. Solar: 20 kW * max(0,sin(2pi * sol fraction)) if installed. Wind: variable 0.3-0.5 kW if installed.
Base: 11.5 kW, working crew +0.35 kW each, auto data +9 kW, auto repair +7 kW, rover charge +1.2 kW each.
Battery: 300 kWh, initial 210 kWh, 25 kW charge/discharge limit, charging efficiency 90%.
Crew: work 8-10 stamina % per game hour; rest +14%/hour. Assignment alone does not drain energy.
Rover: collects 1.5 GB raw/hour; spends 14% battery/hour and 1.8% mechanical health/hour. Charge +25%/hour.
Manual LAB data processor: 1.4 GB/hour per person; automatic processor 3.2 GB/hour.
Human repair rover: +28% health/hour; auto rover repair: +50% health/hour.
Human repair power/life support: 2 working hours per damaged system.
Solar failure probability 16% per sol, wind 5%, fission 1.2%; each life system 2.8% per sol, independent approximate Poisson steps.
Life: initial oxygen 40kg / water 220L, 70F. Crew consumption 0.035kg oxygen/person/hour, 0.2 L water/person/hour; generators +0.26kg O2/hour, +1.4L/hour when functioning and adequately powered.
Score: 45% processed data, 30% life systems uptime, 15% power supply continuity, 10% repair ratio.

Important: All figures above are illustrative gameplay design parameters. Do not cite as hardware performance specifications.

VALIDATION CHECKLIST
1. Test pregames with 2/5 astronauts and 1/3 rovers.
2. Collect data with rover only: progress bar must stay 0, unprocessed inventory increases.
3. Assign scientist to LAB, click Process Data: processed data and progress must increase.
4. Toggle automated processing and verify +9 kW load and no astronaut required.
5. Inspect rovers: status and battery text should remain on horizontal lines.
6. Assign two crew to ENERGY and LIFE SUPPORT, repair failed devices when they occur.
7. Pause freezes state. Use End Mission Early to inspect report.
8. Test 30-sol end, or shorten MISSION_SOLS to 1 temporarily to test end-of-mission.

Godot binary was not available in this execution environment; editor execution remains to be verified.
