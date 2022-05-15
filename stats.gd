extends Node

@export var _max_health = 1
var max_health:
	get:
		return _max_health
	set(value):
		_max_health = value
		health = min(health, _max_health)
		max_health_changed.emit(_max_health)

var _health
var health: int:
	get: 
		return _health
	set(value):
		_health = value
		health_changed.emit(_health)
		if _health <= 0:
			no_health.emit()

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func _ready():
	_health = _max_health
