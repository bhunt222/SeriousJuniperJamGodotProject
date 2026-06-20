extends PlayerState

func enter() -> void:
	if player.jumps_remaining <= 0:
		return

	var mode : PlayerMode = player.current_mode
	player.apply_impulse(Vector2(0.0, -mode.jump_power))
	player.jumps_remaining -= 1
	player.lock_rotation = not mode.spin_in_air
	player.anim_sprite.play(mode.anim_prefix + "_jump")
	print("Enter Jump State")

func exit() -> void:
	print("Exit Jump State")

func physics_update(_delta: float) -> void:
	var mode : PlayerMode = player.current_mode
	var dir : float = Input.get_axis("move_left", "move_right")

	player.apply_air_strafe(dir, mode)

	if player.linear_velocity.y > 0.0:
		transitioned.emit(self, "fall")
	elif Input.is_action_just_pressed("jump") and player.jumps_remaining > 0:
		transitioned.emit(self, "jump")
