extends CharacterBody2D


const PLAYER_HURT_SOUND_SCENE = preload("res://player/player_hurt_sound.tscn")

enum { MOVE, ROLL, ATTACK }

@export var acceleration = 600.0
@export var friction = 600.0
@export var move_speed = 80.0
@export var roll_speed = 100.0

var state = MOVE;
var roll_direction = Vector2.DOWN
var stats = PlayerStats

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var sword_hitbox = $SwordHitboxPivot/SwordHitbox
@onready var hurtbox = $Hurtbox
@onready var blink_animation_player = $BlinkAnimationPlayer


func _ready():
	randomize()
	stats.no_health.connect(queue_free.bind())
	sword_hitbox.knockback_direction = roll_direction
	animation_tree.active = true


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()


func move_state(delta):
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"), # X
		Input.get_axis("move_up", "move_down")     # Y
	)
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		roll_direction = direction
		sword_hitbox.knockback_direction = direction
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Run/blend_position", direction)
		animation_tree.set("parameters/Roll/blend_position", direction)
		animation_tree.set("parameters/Attack/blend_position", direction)
		animation_state.travel("Run")
		velocity = velocity.move_toward(
			direction * move_speed, acceleration * delta
		)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(
			Vector2.ZERO, friction * delta
		)

	move_and_slide()


func roll_state():
	animation_state.travel("Roll")
	velocity = roll_direction * roll_speed
	move_and_slide()
	await animation_tree.animation_finished
	velocity = Vector2.ZERO
	state = MOVE

func attack_state():
	animation_state.travel("Attack")
	velocity = Vector2.ZERO
	await animation_tree.animation_finished
	state = MOVE


func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var player_hurt_sound = PLAYER_HURT_SOUND_SCENE.instantiate()
	get_tree().current_scene.add_child(player_hurt_sound)


func _on_hurtbox_invincibility_started():
	blink_animation_player.play("Start")


func _on_hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
