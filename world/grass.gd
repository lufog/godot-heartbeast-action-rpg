extends Node2D

var destroy_effect_scene = preload("res://effects/grass_effect.tscn")

func create_grass_effect():
	var destroy_effect = destroy_effect_scene.instantiate()
	get_parent().add_child(destroy_effect)
	destroy_effect.global_position = global_position

func _on_hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
