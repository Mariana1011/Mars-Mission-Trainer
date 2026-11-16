 MARS — Junior Astronaut Mission Trainer

## Project Demo

Watch our Mars Mission Trainer demonstration:

https://www.youtube.com/watch?v=J7Y3hAO3nKI

**An educational Mars-base management simulator by Team ElektroLab**  
**NASA Space Apps Challenge 2026 — Build a Junior Astronaut Mission Trainer**

> **Mission:** Manage a scientific base in **Deuteronilus Mensae, Mars**. Keep essential systems running and process **150 GB of scientific data over six Martian sols**.

## Overview

MARS is a Godot-based educational simulation for children aged **7–12**. Instead of controlling a single astronaut, the player acts as the mission commander: they choose a starting configuration, assign crew members to tasks, manage rovers, and balance electricity, scientific productivity, and life-support resources.

The game introduces core engineering ideas through decisions and consequences: **power (kW) versus stored energy (kWh)**, renewable and nuclear generation, battery charging, automated versus human-operated tasks, maintenance, and resource constraints.

**The numbers are simplified gameplay parameters inspired by real space-engineering concepts—not a validated engineering design for an actual Mars habitat.**

## Play the project locally

1. Install **Godot 4**. The project configuration currently targets **Godot 4.7** with the GL Compatibility renderer; use a compatible Godot 4 build.
2. Clone or download this repository.
3. Open Godot Project Manager → **Import** and select `MARS_GAME/project.godot`.
4. Open the project and press **F5** to start from the main menu.
5. Choose **New Game** to configure the mission, then start the simulation.

This repository contains the **Godot source project**. The link above is not a browser-playable build.

## Mission setup (Pregame)

| Choice | Available options |
| --- | --- |
| Nuclear fission | Required |
| Battery bank | Required |
| Photovoltaic solar power | Optional |
| Wind power | Optional |
| Astronauts | 2–5 |
| Rovers | 1–3 |

The setup influences the available power sources, number of crew members, and number of rovers. Choosing a system in Pregame means it is included in the starting base, **not** that it is always operating at maximum output.

## Four interconnected gameplay panels

### 1. Energy

Monitor electrical generation, power demand, stored battery energy, and system failures. The simulation models a fission source, optional solar and wind generation, and battery charge/discharge. Crew members assigned to Energy can be given maintenance duties.

### 2. Life Support

Monitor oxygen reserves (kg), water reserves (L), and habitat temperature (°F). Life-support equipment can fail, and assigned crew members can repair affected systems.

### 3. Lab

**Rovers collect raw data; only processed data counts toward the 150 GB mission objective.** Players can process collected data using astronauts or automated equipment, and repair rovers manually or automatically. Automation is faster but demands more electrical power.

### 4. Operations

Assign astronauts to **Rest**, **Energy**, **Life Support**, or **Lab**, then give them tasks in the corresponding panel. Astronaut energy decreases while performing a task and recovers when idle. Manage rover batteries, mechanical health, charging, maintenance, and data collection missions.

## How the systems interact

```text
Energy generation ──> Electrical power ──> Lab / Life Support / Rover charging
        │                    │
        └──────────────> Battery bank

Rovers ──> Raw scientific data ──> Lab processing ──> Processed data progress

Operations ──> Crew assignments ──> Research / Maintenance / Repairs

Equipment failures ──> Reduced availability ──> Repair decisions
```

### Examples of simplified model parameters

| Parameter | Value in the published simulation | Meaning |
| --- | ---: | --- |
| Mission duration | 6 sols | Time limit |
| Processed-data objective | 150 GB | Scientific target |
| Sol duration | 1,479 simulated minutes | Martian day |
| Fission generation | 40 kW | Steady nominal supply when available |
| Solar generation | Up to 20 kW | Varies with the simplified day cycle |
| Battery capacity | 300 kWh | Stored electrical energy |
| Initial battery energy | 210 kWh | Start-of-mission storage |
| Automated data processing | 2.6 GB/h | Requires extra electrical power |
| Human data processing | 1.2 GB/h per working astronaut | Uses crew effort |
| Rover raw-data collection | 2.0 GB/h per collecting rover | Does **not** directly advance the objective |

These are **game-design assumptions** and should not be quoted as measured outputs of NASA hardware. The authoritative values for this version are in [`MARS_GAME/scripts/mars_simulation.gd`](MARS_GAME/scripts/mars_simulation.gd).

## Mission results

At the end, the simulation reports performance using a weighted score based on processed scientific data, life-support continuity, power availability, and repairs. It also records indicators such as collected raw data, completed repairs, failures, and unmet electrical demand.

## Technology and project structure

- **Engine:** Godot 4, using **GDScript** and `.tscn` scenes.
- **Entry point:** `MARS_GAME/scenes/main_menu/main_menu.tscn`.
- **Simulation logic:** [`MARS_GAME/scripts/mars_simulation.gd`](MARS_GAME/scripts/mars_simulation.gd).
- **Mission setup:** `MARS_GAME/scripts/game_setup.gd`.
- **Audio manager:** `MARS_GAME/scripts/music_manager.gd`.
- **Engineering reference spreadsheet:** [`Modulos Base Marte.xlsx`](Modulos%20Base%20Marte.xlsx).

## Scientific background and references

The project draws on publicly available resources about power and life support in space exploration, including:

1. [NASA — Fission Surface Power](https://www.nasa.gov/exploration-systems-development-mission-directorate/fission-surface-power/)
2. [NASA — Environmental Control and Life Support Systems (ECLSS)](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/)
3. [NASA — Mars Exploration](https://science.nasa.gov/mars/)
4. [NASA — Mars Facts](https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html)

These references inform the **concepts**, not every value in the game. The project is an independent student prototype and **is not an official NASA product or endorsement**.

## AI assistance and media credits

Team ElektroLab used AI assistance during ideation, interface illustration, coding support, and documentation preparation. Human team members selected the design goals, integrated and adapted the Godot project, and reviewed its gameplay. **AI-generated media and source-code contributions should be labeled and credited in accordance with the NASA Space Apps Challenge submission rules.**

**Before final submission:** verify the origin and reuse permissions of all audio files (including `MARS_GAME/eee.ogg`), confirm attribution for third-party fonts/assets, and visibly mark AI-generated images or videos where the event rules require it. Do not describe a track as team-original without confirming its provenance.

## Team

**ElektroLab** — NASA Space Apps Challenge 2026.

Source repository: <https://github.com/Mariana1011/Mars-Mission-Trainer>
