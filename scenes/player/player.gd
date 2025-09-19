extends CharacterBody2D
class_name Player

enum PLAYER_STATE {
	IDLE,
	RUN,
	JUMP,
	DOUBLE_JUMP,
	FALL,
	HURT,
	DASH
}

var DISAPPEAR_SCENE: PackedScene = preload("res://scenes/disappear/disappear.tscn")
var APPEAR_SCENE: PackedScene = preload("res://scenes/appear/appear.tscn")
var JUMP_EFFECT_SCENE: PackedScene = preload("res://scenes/jump_effect/jump_effect.tscn")
var DASH_AFTER_IMAGE_SCENE: PackedScene = preload("res://scenes/dash_after_image/dash_after_image.tscn")
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@onready var jump_buffer_timer: Timer = $Timers/JumpBufferTimer
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var dash_timer: Timer = $Timers/DashTimer
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer

@onready var HEALTH = $HUD/HEALTH
var health: int = 3

@export_group("move")
@export var move_speed: float = 200.0
var can_move: bool = true

@export_group("dash")
@export var dash_speed: float = 800.0
var dash: bool = false
var can_dash: bool = true

@export_group("jump")
@export var jump_force: float = 300.0
@export var max_y_velocity: float = 400.0
var jump_count: int = 0
var can_jump: bool = false

@export_group("hurt")
@export var hurt_velocity: Vector2 = Vector2(0, -150.0)
var is_falling: bool = false

var direction: Vector2 = Vector2.ZERO
var state: PLAYER_STATE = PLAYER_STATE.IDLE

func _ready() -> void:
	spawn_player()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	fallen_off()

	if !can_move:
		return

	get_input()
	apply_movement(delta)
	update_state()

func fallen_off():
	if global_position.y < 0:
		return

	if global_position.y > 0 and !is_falling:
		is_falling = true
		AudioManager.play_sfx("fall")

	if global_position.y > 500:
		set_state(PLAYER_STATE.IDLE)
		SignalManager.on_player_hit.emit()
		is_falling = false

func apply_gravity(delta: float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, max_y_velocity)

func get_input():
	direction.x = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer.time_left:
			can_jump = true
			jump_count = 1
		elif jump_count == 1:
			can_jump = true
			jump_count += 1

		if velocity.y > 0 and not is_on_floor():
			jump_buffer_timer.start()

	if Input.is_action_just_pressed("dash") and can_dash:
		dash_timer.start()
		dash_cooldown_timer.start()
		dash = true
		can_dash = false

func apply_movement(delta: float):
	if can_jump or jump_buffer_timer.time_left and is_on_floor():
		jump(jump_force)
	elif direction.x:
		animated_sprite_2d.flip_h = direction.x < 0

		if dash:
			velocity = Vector2(direction.x * dash_speed, 0)
		else:
			velocity.x = direction.x * move_speed
	else:
		velocity.x = 0

	var on_floor = is_on_floor()
	move_and_slide()
	if on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()

func update_state():
	if dash and velocity.x:
		spawn_dash_after_image()
		set_state(PLAYER_STATE.DASH)
	elif is_on_floor():
		jump_count = 0

		if velocity.x == 0:
			set_state(PLAYER_STATE.IDLE)
		else:
			set_state(PLAYER_STATE.RUN)
	else:
		if velocity.y > 0:
			set_state(PLAYER_STATE.FALL)
		elif jump_count == 1:
			set_state(PLAYER_STATE.JUMP)
		elif  jump_count == 2:
			set_state(PLAYER_STATE.DOUBLE_JUMP)

func set_state(new_state: PLAYER_STATE):
	if new_state == state:
		return

	state = new_state
	
	match state:
		PLAYER_STATE.IDLE:
			animated_sprite_2d.play("idle")
		PLAYER_STATE.RUN:
			animated_sprite_2d.play("run")
		PLAYER_STATE.JUMP:
			spawn_jump_effect()
			AudioManager.play_sfx("jump")
			animated_sprite_2d.play("jump")
		PLAYER_STATE.DOUBLE_JUMP:
			AudioManager.play_sfx("jump")
			animated_sprite_2d.play("double_jump")
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("fall")
		PLAYER_STATE.HURT:
			AudioManager.play_sfx("hurt")
			animated_sprite_2d.play("hurt")
		PLAYER_STATE.DASH:
			animated_sprite_2d.play("dash")

func jump(force: float):
	velocity.y = -force
	can_jump = false

func add_child_deferred(child_to_add):
	get_tree().root.add_child(child_to_add)

func call_add_child(child_to_add):
	call_deferred("add_child_deferred", child_to_add)

func spawn_dash_after_image():
	var dash_after_image = DASH_AFTER_IMAGE_SCENE.instantiate()
	dash_after_image.global_position = global_position
	dash_after_image.flip_h = animated_sprite_2d.flip_h
	call_add_child(dash_after_image)

func spawn_jump_effect():
	var jump_effect = JUMP_EFFECT_SCENE.instantiate()
	jump_effect.global_position = global_position + Vector2(0, 9.5)
	jump_effect.flip_h = animated_sprite_2d.flip_h
	call_add_child(jump_effect)

func spawn_player():
	animated_sprite_2d.flip_h = false

	var appear = APPEAR_SCENE.instantiate()
	appear.global_position = global_position
	call_add_child(appear)

	can_move = false
	await get_tree().create_timer(0.5).timeout
	can_move = true
	
func Damage():
	print("Health before:", health)
	health -= 1
	match health:
		3:
			HEALTH.frame = 0
		2:
			HEALTH.frame = 1
		1:
			HEALTH.frame = 2
		0:
			HEALTH.frame = 3

	if health == 0:
		Die()

func Die():
	get_tree().reload_current_scene()

func apply_hit():
	Damage()
	if health <= 0:
		return  

	var disappear = DISAPPEAR_SCENE.instantiate()
	disappear.global_position = global_position
	call_add_child(disappear)

	can_move = false
	velocity = Vector2.ZERO
	set_state(PLAYER_STATE.HURT)

	await animated_sprite_2d.animation_finished

	set_state(PLAYER_STATE.IDLE)
	can_move = true

func _on_hit_box_area_entered(area: Area2D) -> void:
	apply_hit()

func _on_dash_timer_timeout() -> void:
	dash = false

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
