extends Node


signal no_health
signal health_changed(value)
signal max_health_changed(value)

@export var max_health := 1:
	get:
		return max_health
	set(value):
		max_health = value
		health = min(health, max_health)
		max_health_changed.emit(max_health)

var health: int:
	get: 
		return health
	set(value):
		health = value
		health_changed.emit(health)
		if health <= 0:
			no_health.emit()


func _ready():
	health = max_health
