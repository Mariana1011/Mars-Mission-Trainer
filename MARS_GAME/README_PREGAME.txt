MARS BASE GAME — PRE-GAME IMPLEMENTATION

Open project.godot with Godot 4.3 or newer. Press F6 / run project.
New Game -> PRE-GAME SETUP -> ENERGY / OPERATIONS.

ENERGY
- Nuclear Fission Reactor: always required.
- Battery Bank: always required.
- Photovoltaic Solar Panels: optional; click SELECT to toggle.
- Wind Energy Turbine: optional; click SELECT to toggle.

OPERATIONS
- Humans: -/+ between 2 and 5; starts at 2.
- Rovers: -/+ between 1 and 3; starts at 1.

CONTINUE on the submenus returns to the setup overview.
CONTINUE on the overview shows a review panel.
CONFIRM SETUP marks GameSetup.prepared = true but DOES NOT start the Game scene yet.

All state lives in Autoload GameSetup and is preserved when navigating.
The game and settings scenes from the original project are preserved.
Images under assets/pregame are static art. Click zones and dynamic counters are native Godot nodes.

Visual quality check: best played at 16:9 (1672x941 reference); other sizes letterbox.
Godot was not available in this creation environment, so please test in the editor.
