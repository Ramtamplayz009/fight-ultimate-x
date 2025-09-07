extends Control

const fight_scene = preload("res://fight.tscn")
const level_select_scene = preload("res://level_select.tscn")

func _ready() -> void:
	var level_select := level_select_scene.instantiate()
	level_select.go_to_level.connect(_go_to_level)
	add_child(level_select)
	
func _go_to_level(level: int) -> void:
	var fight := fight_scene.instantiate() as Fight
	fight.level = level
	fight.home.connect(func() -> void:
		remove_child(fight)
	)
	add_child(fight)
