extends RigidBody2D
class_name Player

@onready var gun_rig: Node2D = $GunRig
@onready var floor_ray_cast: RayCast2D = $FloorRayCast
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var spin_dash_direction: Node2D = $SpinDashDirection
@onready var spin_dash_hitbox: Area2D = $SpinDashHitbox
@onready var spin_dash_hitbox_shape: CollisionShape2D = $SpinDashHitbox/CollisionShape2D

@export var normal_mode: PlayerMode
@export var ball_mode: PlayerMode

const MAX_JUMPS: int = 2
const DRILLING_ANIM := &"drilling"
const SPIN_DASH_CHARGE_ANIM := &"ball_charge_spin"

var current_mode: PlayerMode
var jumps_remaining: int = 1
var _air_jumps_consumed: int = 0
var _wall_contact_this_frame: bool = false
var _gun_active: bool = true

func _ready() -> void:
	assert(normal_mode != null, "Player requires normal_mode")
	assert(ball_mode != null, "Player requires ball_mode")
	contact_monitor = true
	max_contacts_reported = 8
	current_mode = normal_mode
	reset_jumps()
	update_gun_visibility()
	spin_dash_direction.visible = false
	set_spin_dash_hitbox_active(false)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_wall_contact_this_frame = false
	for i in state.get_contact_count():
		if absf(state.get_contact_local_normal(i).y) < 0.3:
			_wall_contact_this_frame = true
			break

func had_wall_contact() -> bool:
	return _wall_contact_this_frame

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("transition_modes"):
		switch_mode()

func switch_mode() -> void:
	var previous_mode := current_mode
	var entering_ball := current_mode == normal_mode
	current_mode = ball_mode if entering_ball else normal_mode
	sync_jumps_remaining("mode_switch")
	update_gun_visibility()
	state_machine.on_mode_changed()
	EventBus.player_mode_switched.emit(
		previous_mode.anim_prefix,
		current_mode.anim_prefix,
		entering_ball,
		get_jump_debug_state(),
		state_machine.get_state_name() if state_machine.current_state else "none",
	)

func is_ball_mode() -> bool:
	return current_mode == ball_mode

func max_jumps_allowed() -> int:
	if is_ball_mode() and ball_mode.can_double_jump:
		return MAX_JUMPS
	return 1

func sync_jumps_remaining(reason: String = "") -> void:
	jumps_remaining = clampi(max_jumps_allowed() - _air_jumps_consumed, 0, MAX_JUMPS)
	EventBus.player_jump_sync.emit(reason, get_jump_debug_state())

func clamp_jumps() -> void:
	jumps_remaining = clampi(jumps_remaining, 0, MAX_JUMPS)

func consume_jump() -> void:
	_air_jumps_consumed += 1
	jumps_remaining = maxi(jumps_remaining - 1, 0)
	clamp_jumps()
	EventBus.player_jump_consumed.emit(get_jump_debug_state())

func set_gun_active(active: bool) -> void:
	_gun_active = active
	update_gun_visibility()

func can_fire_gun() -> bool:
	return _gun_active and current_mode.can_shoot

func update_gun_visibility() -> void:
	gun_rig.visible = can_fire_gun()

func reset_jumps() -> void:
	_air_jumps_consumed = 0
	jumps_remaining = max_jumps_allowed()
	clamp_jumps()
	EventBus.player_jump_reset.emit(get_jump_debug_state())

func get_move_dir() -> float:
	return Input.get_axis("move_left", "move_right")

func wants_jump() -> bool:
	var pressed := Input.is_action_just_pressed("jump")
	if not pressed:
		return false
	if jumps_remaining > 0:
		EventBus.player_jump_requested.emit(get_jump_debug_state())
		return true
	EventBus.player_jump_denied.emit("no_jumps_remaining", get_jump_debug_state())
	return false

func set_facing(dir: float) -> void:
	if dir > 0:
		anim_sprite.flip_h = false
	elif dir < 0:
		anim_sprite.flip_h = true
		
func get_drill_transition_animation() -> StringName:
	return StringName("%s_drill_transition" % current_mode.anim_prefix)

func play_drilling() -> void:
	var frames := anim_sprite.sprite_frames
	if frames.has_animation(DRILLING_ANIM) and frames.get_frame_count(DRILLING_ANIM) > 0:
		anim_sprite.play(DRILLING_ANIM)

func apply_drill_force() -> void:
	apply_central_force(Vector2(0.0, current_mode.drill_down_force))

func show_spin_dash_arrow() -> void:
	spin_dash_direction.visible = true
	update_spin_dash_arrow()

func hide_spin_dash_arrow() -> void:
	spin_dash_direction.visible = false

func set_spin_dash_hitbox_active(active: bool) -> void:
	spin_dash_hitbox.monitoring = active
	spin_dash_hitbox.monitorable = active
	spin_dash_hitbox_shape.disabled = not active

func update_spin_dash_arrow() -> void:
	var dir := get_global_mouse_position() - global_position
	if dir.length_squared() < 0.001:
		dir = Vector2.UP
	spin_dash_direction.rotation = dir.angle() + PI / 2.0

func get_spin_dash_launch_direction() -> Vector2:
	return Vector2.UP.rotated(spin_dash_direction.rotation).normalized()

func launch_spin_dash() -> void:
	var direction := get_spin_dash_launch_direction()
	linear_velocity = direction * ball_mode.spin_dash_speed

func play_spin_dash_charge_animation() -> void:
	var frames := anim_sprite.sprite_frames
	if frames.has_animation(SPIN_DASH_CHARGE_ANIM):
		anim_sprite.play(SPIN_DASH_CHARGE_ANIM)

func play_mode_animation(suffix: String) -> void:
	var frames := anim_sprite.sprite_frames
	var anim_name := "%s_%s" % [current_mode.anim_prefix, suffix]
	if frames.has_animation(anim_name) and frames.get_frame_count(anim_name) > 0:
		anim_sprite.play(anim_name)
		return
	var fallback := "%s_idle" % current_mode.anim_prefix
	if frames.has_animation(fallback) and frames.get_frame_count(fallback) > 0:
		anim_sprite.play(fallback)

func apply_air_strafe(dir: float, mode: PlayerMode) -> void:
	if dir == 0:
		return
	var vx := linear_velocity.x
	if (dir > 0 and vx < mode.air_max_speed) or (dir < 0 and vx > -mode.air_max_speed):
		apply_central_force(Vector2(dir * mode.air_accel, 0))
	set_facing(dir)

func get_landing_state(dir: float) -> String:
	if dir == 0:
		return PlayerStateMachine.STATE_IDLE
	if horizontal_speed() >= current_mode.sprint_enter_speed:
		return PlayerStateMachine.STATE_SPRINT
	return PlayerStateMachine.STATE_RUN

func is_on_floor() -> bool:
	return floor_ray_cast.is_colliding()

func horizontal_speed() -> float:
	return absf(linear_velocity.x)

func get_jump_debug_state() -> Dictionary:
	return {
		"jumps_remaining": jumps_remaining,
		"air_jumps_consumed": _air_jumps_consumed,
		"max_allowed": max_jumps_allowed(),
		"mode": current_mode.anim_prefix,
		"on_floor": is_on_floor(),
	}
