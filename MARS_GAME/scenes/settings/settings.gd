extends Control

@export var menu_scene: PackedScene = load("res://scenes/main_menu/main_menu.tscn")

@export_category("Referencias de Nodos")
@export var first_button_path: NodePath

func _ready() -> void:
	if not first_button_path.is_empty():
		var first_button = get_node_or_null(first_button_path)
		if first_button is Button:
			first_button.grab_focus()


func _on_main_menu_pressed() -> void:
	print("Volviendo al menú...")
	get_tree().change_scene_to_packed(menu_scene)

func _on_downSound_pressed() -> void:
	print("Subiendo volumen...")

func _on_upSound_pressed() -> void:
	print("Bajando volumen...")
