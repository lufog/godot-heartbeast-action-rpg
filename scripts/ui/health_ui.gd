extends Control

var _hearts = 4
var hearts:
	set(value):
		_hearts = clamp(value, 0, _max_hearts)
		if heart_ui_full != null:
			heart_ui_full.size.x = _hearts * 15

var _max_hearts = 4
var max_hearts:
	set(value):
		_max_hearts = max(value, 1)
		hearts = min(_hearts, _max_hearts)
		if heart_ui_empty != null:
			heart_ui_empty.size.x = _max_hearts * 15

@onready var heart_ui_empty = $HeartUiEmpty
@onready var heart_ui_full = $HeartUiFull

func _ready():
	max_hearts = PlayerStats.max_health
	hearts = PlayerStats.health
	PlayerStats.health_changed.connect(set_hearts)
	PlayerStats.max_health_changed.connect(set_max_hearts)

func set_hearts(value):
	hearts = value

func set_max_hearts(value):
	max_hearts = value
