extends Control


var hearts := 4:
	set(value):
		hearts = clamp(value, 0, max_hearts)
		if heart_ui_full != null:
			heart_ui_full.size.x = hearts * 15

var max_hearts := 4:
	get:
		return max_hearts
	set(value):
		max_hearts = max(value, 1)
		hearts = min(hearts, max_hearts)
		if heart_ui_empty != null:
			heart_ui_empty.size.x = max_hearts * 15

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
