extends PlayerState

const END_SPEED := 120.0

var _grace_frames: int = 0
var _was_airborne: bool = false
var _is_ending: bool = false

func enter() -> void:
	_is_ending = false
	_grace_frames = 4
	_was_airborne = not player.is_on_floor()
	player.hide_spin_dash_arrow()
	player.set_spin_dash_hitbox_active(true)
	player.launch_spin_dash()
	player.play_spin_dash_charge_animation()

func exit() -> void:
	player.set_spin_dash_hitbox_active(false)

func refresh_for_mode_change() -> void:
	_finish_spin_dash()

func physics_update(_delta: float) -> void:
	if _is_ending:
		return

	if try_transition_drill():
		return

	if not player.is_on_floor():
		_was_airborne = true

	if _grace_frames > 0:
		_grace_frames -= 1
		return

	if player.had_wall_contact():
		_finish_spin_dash()
		return

	if _was_airborne and player.is_on_floor():
		_finish_spin_dash()
		return

	if player.linear_velocity.length() <= END_SPEED:
		_finish_spin_dash()

func _finish_spin_dash() -> void:
	if _is_ending:
		return
	_is_ending = true
	var dir := player.get_move_dir()
	if player.is_on_floor():
		player.reset_jumps()
		transitioned.emit(self, player.get_landing_state(dir))
	else:
		transitioned.emit(self, PlayerStateMachine.STATE_FALL)
