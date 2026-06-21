extends PlayerState

func enter() -> void:
	player.play_mode_animation("idle")

func physics_update(delta: float) -> void:
	var mode := player.current_mode
	var dir := player.get_move_dir()

	player.linear_velocity.x = move_toward(player.linear_velocity.x, 0, mode.friction * delta)

	if try_transition_spin_dash_charge():
		return
	if try_transition_drill():
		return
	if check_airborne_transition():
		return
	if dir != 0:
		transitioned.emit(self, PlayerStateMachine.STATE_RUN)
	elif try_transition_jump():
		pass
