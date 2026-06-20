extends PlayerState

func enter() -> void:
	player.anim_sprite.play(player.current_mode.anim_prefix + "_fall")
	print("Enter Fall State")

func exit() -> void:
	player.rotation = 0
	player.lock_rotation = true
	print("Exit Fall State")

func physics_update(_delta: float) -> void:
	var mode : PlayerMode = player.current_mode
	var dir : float = Input.get_axis("move_left", "move_right")

	player.apply_air_strafe(dir, mode)

	if mode.spin_in_air and dir != 0:
		player.apply_torque(player.jump_rotation_force * dir)

	if Input.is_action_just_pressed("jump") and player.jumps_remaining > 0:
		transitioned.emit(self, "jump")
	elif player.is_on_floor():
		player.reset_jumps()
		if dir == 0:
			transitioned.emit(self, "idle")
		elif player.horizontal_speed() >= mode.sprint_enter_speed:
			transitioned.emit(self, "sprint")
		else:
			transitioned.emit(self, "run")
