extends RigidBody2D
class_name Player

@onready var gun_rig: Node2D = $GunRig
@onready var floor_ray_cast: RayCast2D = $FloorRayCast
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var normal_mode: PlayerMode
@export var ball_mode: PlayerMode
var current_mode: PlayerMode = normal_mode

var jumps_remaining: int = 1
var jump_rotation_force : float = 5000.0

func _ready() -> void:
	current_mode = normal_mode
	reset_jumps()
	update_gun_visibility()

func _enter_tree() -> void:
	current_mode = normal_mode

func _physics_process(_delta: float) -> void:
	if current_mode.can_shoot and Input.is_action_just_pressed("shoot"):
		gun_rig.shoot_bullet()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("transition_modes"):
		switch_mode()

func switch_mode() -> void:
	current_mode = ball_mode if current_mode == normal_mode else normal_mode
	if not is_on_floor() and current_mode.can_double_jump and jumps_remaining == 0:
		jumps_remaining = 1
	update_gun_visibility()
	$StateMachine.on_mode_changed()

func update_gun_visibility() -> void:
	gun_rig.visible = current_mode.can_shoot

func get_max_jumps() -> int:
	return 2 if current_mode.can_double_jump else 1

func reset_jumps() -> void:
	jumps_remaining = get_max_jumps()

func apply_air_strafe(dir: float, mode: PlayerMode) -> void:
	if dir == 0:
		return
	var vx := linear_velocity.x
	if (dir > 0 and vx < mode.air_max_speed) or (dir < 0 and vx > -mode.air_max_speed):
		apply_central_force(Vector2(dir * mode.air_accel, 0))
	if dir > 0:
		anim_sprite.flip_h = false
	elif dir < 0:
		anim_sprite.flip_h = true

func is_on_floor() -> bool:
	return floor_ray_cast.is_colliding()

func horizontal_speed() -> float:
	return absf(linear_velocity.x)
