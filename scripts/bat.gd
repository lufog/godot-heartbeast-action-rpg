extends CharacterBody2D

const death_effect_scene = preload("res://scenes/effects/enemy_death_effect.tscn")

@export var acceleration = 400
@export var max_speed = 50
@export var friction = 10
@export var target_wander_range = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

var move_velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE

@onready var sprite = $AnimatedSprite2D
@onready var stats = $Stats
@onready var player_detection_zone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var soft_collision = $SoftCollision
@onready var wander_controller = $WanderController
@onready var animation_player = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	# decrease knockback
	knockback = knockback.move_toward(Vector2.ZERO, friction)
	
	match state:
		IDLE:
			# decrease velocity
			move_velocity = move_velocity.move_toward(Vector2.ZERO, friction)
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			
		WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= target_wander_range:
				update_wander()
			
		CHASE:
			var player = player_detection_zone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	
	if soft_collision.is_colliding():
		move_velocity += soft_collision.get_push_vector() * delta * 400
	velocity = knockback + move_velocity
	move_and_slide()

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	move_velocity = move_velocity.move_toward(direction * max_speed, acceleration * delta)
	sprite.flip_h = move_velocity.x < 0

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randf_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_direction * 160
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_stats_no_health():
	var death_effect = death_effect_scene.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	queue_free()

func _on_hurtbox_invincibility_started():
	animation_player.play("Start")

func _on_hurtbox_invincibility_ended():
	animation_player.play("Stop")
