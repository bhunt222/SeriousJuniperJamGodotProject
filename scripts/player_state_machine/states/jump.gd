extends PlayerState

func enter() -> void:
	perform_jump()

func refresh_for_mode_change() -> void:
	if player.linear_velocity.y > 0.0:
		player.play_mode_animation("fall")
	else:
		player.play_mode_animation("jump")

func perform_jump() -> void:
	if player.jumps_remaining <= 0:
		EventBus.player_jump_denied.emit("perform_jump_no_jumps_remaining", player.get_jump_debug_state())
		transitioned.emit(self, PlayerStateMachine.STATE_FALL)
		return

	var mode := player.current_mode
	player.apply_impulse(Vector2(0.0, -mode.jump_power))
	player.consume_jump()
	player.play_mode_animation("jump")

func physics_update(_delta: float) -> void:
	var mode := player.current_mode
	var dir := player.get_move_dir()

	player.apply_air_strafe(dir, mode)

	if try_transition_spin_dash_charge():
		pass
	elif try_transition_drill():
		pass
	elif player.linear_velocity.y > 0.0:
		transitioned.emit(self, PlayerStateMachine.STATE_FALL)
	elif try_transition_jump():
		pass
