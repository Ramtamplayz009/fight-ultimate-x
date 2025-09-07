extends TextureButton
class_name LevelButton

signal go_to_level(level: int)

@onready var label: Label = $Label

@export var level: int

func _ready() -> void:
	label.text = "Level " + str(level)
	
	pressed.connect(_go_to_level)

func _go_to_level() -> void:
	go_to_level.emit(level)
