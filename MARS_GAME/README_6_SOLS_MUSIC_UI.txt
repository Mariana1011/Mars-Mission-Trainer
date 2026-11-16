MARS / 6 SOLS — GODOT EDITABLE EDITION
=======================================
Open project.godot in Godot 4. Recommended version: 4.4+.

GAME RULES
- 6 Martian sols; target: 150 GB PROCESSED scientific data.
- Rover: 2 GB of RAW scientific data / game hour; rovers do not increase the HUD progress directly.
- Astronaut lab work: 1.2 GB/hour. Automatic computer: 2.6 GB/hour, consuming an additional 9 kW.
- Crew energy: +12%/hour while idle; -9%/hour processing data and -11%/hour for other jobs.
- Solar failures: 20%/sol nominal; wind 7%/sol; fission 1.5%/sol; each life-support device 3.5%/sol.

SCENES TO EDIT VISUALLY
- scenes/game/Marcian_base.tscn (HUD + Mute button)
- scenes/game/panels/mission_modal.tscn (pause screen AND final results, fully editable)
- scenes/game/panels/lab.tscn, energy.tscn, life_support.tscn, operations.tscn

AUDIO
- scripts/music_manager.gd is an Autoload added to project.godot.
- assets/audio/mars_ambient_original.wav is an ORIGINAL 16-second ambient loop, included because no music was uploaded.
- The HUD MUTE and pause-screen MUTE buttons control the same global soundtrack.
- To replace the track with your own licensed music: replace audio file and MusicManager MUSIC constant.

CHANGES
- HUD progress now displays dynamic 150 GB target instead of a fixed 100 GB.
- Pause/report rebuilt as reusable, editable scene.
- At mission end, final report displays score, data, failures, repairs, oxygen, water and temperature.

NOTE
Code and resource paths were checked here; Godot graphical runtime was not available in this environment.
