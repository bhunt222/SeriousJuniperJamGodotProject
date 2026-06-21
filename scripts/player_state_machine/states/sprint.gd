extends PlayerState

func enter() -> void:
	player.play_mode_animation("sprint")

func physics_update(_delta: float) -> void:
	var mode := player.current_mode
	var dir := player.get_move_dir()

	player.apply_central_force(Vector2(dir * mode.sprint_speed, 0))
	player.set_facing(dir)

	if try_transition_spin_dash_charge():
		return
	if try_transition_drill():
		return
	if dir == 0:
		transitioned.emit(self, PlayerStateMachine.STATE_IDLE)
	elif check_airborne_transition():
		pass
	elif try_transition_jump():
		pass
	elif player.horizontal_speed() < mode.sprint_exit_speed:
		transitioned.emit(self, PlayerStateMachine.STATE_RUN)
