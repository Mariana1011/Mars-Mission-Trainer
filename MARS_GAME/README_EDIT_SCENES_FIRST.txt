MARS — EDITAR DESDE GODOT SIN LEER EL SCRIPT GRANDE

Abre escenas/game/Marcian_base.tscn y podrás ver en el árbol:
  ArtSpace/MarsBackground (arte), HUD/ModuleSlot (módulo activo),
  HUD/LabButton, EnergyButton, LifeSupportButton y OperationsButton.

Los cuatro paneles editables están en:
  scenes/game/panels/lab.tscn
  scenes/game/panels/energy.tscn
  scenes/game/panels/life_support.tscn
  scenes/game/panels/operations.tscn

Las tarjetas de personas y robots están en:
  scenes/game/cards/crew_card.tscn
  scenes/game/cards/rover_card.tscn

Puedes modificar tamaños, colores, títulos y distribución desde la vista 2D de Godot.
No borres ni cambies los NOMBRES de nodos existentes sin actualizar las rutas $Body/... de sus scripts.
Los paneles tienen scripts pequeños para mostrar la simulación, pero las matemáticas
permanecen unificadas en scripts/mars_simulation.gd.

MISIÓN: 6 soles. DATA PROGRESS: solo datos procesados (150 GB).
No se han cambiado las fórmulas ni los límites del Pregame.

NOTA: no se pudo ejecutar el editor Godot aquí; confirma con F5 en tu equipo.
