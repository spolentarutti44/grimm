extends Node

# Central scene-transition helper. Call from any scene script.

const TITLE       := "res://scenes/TitleScreen.tscn"
const INVESTIGATE := "res://scenes/InvestigationScene.tscn"
const COMBAT      := "res://scenes/CombatScene.tscn"
const AFTERMATH   := "res://scenes/AftermathScreen.tscn"

func go_title()       -> void: _go(TITLE)
func go_investigation() -> void: _go(INVESTIGATE)
func go_combat()      -> void: _go(COMBAT)
func go_aftermath()   -> void: _go(AFTERMATH)

func _go(path: String) -> void:
	get_tree().call_deferred("change_scene_to_file", path)
