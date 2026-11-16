MARS BASE — GAME IMPLEMENTATION (Godot 4)
========================================= 
WHAT CHANGED
- Kept the original pregame selection system and 1678x937 main_control.png artwork.
- After New Game > Pre-Game > Continue > CONFIRM SETUP, click START GAME.
- The game starts in res://scenes/game/Marcian_base.tscn.
- Four HUD buttons open LAB / ENERGY / LIFE SUPPORT / OPERATIONS.
- Operations dynamically renders exactly the humans (2-5) and rovers (1-3) chosen in Pregame.
- All states run in MarsSimulation (Autoload), not inside view scenes.

ASTRONAUTS
- Default assignment REST.
- REST restores +15 energy points per game hour.
- LAB, ENERGY, LIFE SUPPORT consume -9 energy points per game hour.
- At 0 energy, automatic rest. Values are GAME BALANCING parameters, not NASA figures.
- The astronaut's energy does not decrease when resting or simply switching screens.

ROVERS
- Start with 100% battery and 100% health, READY.
- Collect Data drains battery 18 percentage points / game hour, and health 2.5 / game hour.
- Charge replenishes battery 30 percentage points / game hour.
- Maintenance restores health 40 percentage points / game hour.
- Below 25% health, rover becomes NEEDS MAINTENANCE; collection requires READY, battery >=25%, health >25%.
- Collecting stops at battery <=10%. Player can stop a collecting rover manually.
- These percentages are GAME PARAMETERS, not real rover specs.

CLOCK / DATA
- One real-world second advances 10 Martian minutes; change MarsSimulation.time_scale.
- One sol = 1479 game minutes (rounded).
- LAB workers produce 0.12 GB per game hour; collecting rovers 0.8 GB per game hour.
- DATA PROGRESS goal is 150 GB. This is a game goal, not real NASA data throughput.
- Pause freezes the global simulation.

TECHNICAL
- scenes/game/marcian_base.gd draws native Godot UI over assets/main_control.png.
- scripts/mars_simulation.gd owns persistent humans, rovers, time, and data.
- scripts/game_setup.gd owns pregame options and crew counts.
- The other three tabs show basic information; detailed mission/power/life support mechanics have not been implemented.
- Never put world state inside a visual scene that will be changed/reloaded.

HOW TO RUN
1. Extract the ZIP.
2. Import the project.godot file with Godot 4.
3. F5 > New Game > select modules and quantities > Continue > CONFIRM SETUP > START GAME.
4. Use OPERATIONS to assign personnel and send commands to rovers.
5. Use the four lower buttons to change views; pause at the top-right.

NOTE: The Godot engine isn't installed in the generation environment. Source files and ZIP integrity were checked but the runtime must be verified in the user's Godot editor.
