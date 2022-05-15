extends Area2D

const hit_effect_scene = preload("res://effects/hit_effect.tscn")

@onready var invincibility_timer = $InvincibilityTimer
@onready var collision_shape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

var _invincible = false
var invincible:
	set(value):
		_invincible = value
		if _invincible == true:
			invincibility_started.emit()
			#emit_signal("invincibility_ended")
		else:
			invincibility_ended.emit()

func start_invincibility(duration):
	invincible = true
	invincibility_timer.start(duration)

func create_hit_effect():
	var effect = hit_effect_scene.instantiate()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func _on_invincibility_timer_timeout():
	invincible = false

func _on_invincibility_started():
	collision_shape.set_deferred("disabled", true)

func _on_invincibility_ended():
	collision_shape.disabled = false
