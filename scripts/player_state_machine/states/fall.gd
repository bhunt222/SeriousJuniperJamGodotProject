extends PlayerState

func enter() -> void:
	player.play_mode_animation("fall")

func refresh_for_mode_change() -> void:
	player.play_mode_animation("fall")

func physics_update(_delta: float) -> void:
	var dir := player.get_move_dir()

	player.apply_air_strafe(dir, player.current_mode)

	if try_transition_spin_dash_charge():
		pass
	elif try_transition_drill():
		pass
	elif try_transition_jump():
		pass
	elif player.is_on_floor():
		player.reset_jumps()
		transitioned.emit(self, player.get_landing_state(dir))
