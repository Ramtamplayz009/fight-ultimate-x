extends Control

signal go_to_level(level: int)

@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	for panel in grid_container.get_children():
		for button in panel.get_children():
			if button is LevelButton:
				button.go_to_level.connect(_go_to_level)

func _go_to_level(level: int) -> void:
	go_to_level.emit(level)
