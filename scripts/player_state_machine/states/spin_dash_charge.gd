extends PlayerState

func enter() -> void:
	player.linear_velocity = Vector2.ZERO
	player.set_spin_dash_hitbox_active(false)
	player.play_spin_dash_charge_animation()
	player.show_spin_dash_arrow()

func exit() -> void:
	player.hide_spin_dash_arrow()
	player.set_spin_dash_hitbox_active(false)

func refresh_for_mode_change() -> void:
	if not player.is_ball_mode():
		_cancel_charge()

func update(_delta: float) -> void:
	player.update_spin_dash_arrow()

func physics_update(_delta: float) -> void:
	if not player.is_ball_mode():
		_cancel_charge()
		return

	player.linear_velocity = player.linear_velocity.lerp(Vector2.ZERO, 0.25)

	if not Input.is_action_pressed("spin_dash"):
		transitioned.emit(self, PlayerStateMachine.STATE_SPIN_DASH)

func _cancel_charge() -> void:
	player.hide_spin_dash_arrow()
	if player.is_on_floor():
		transitioned.emit(self, player.get_landing_state(player.get_move_dir()))
	else:
		transitioned.emit(self, PlayerStateMachine.STATE_FALL)
