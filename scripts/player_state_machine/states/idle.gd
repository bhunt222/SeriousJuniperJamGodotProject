extends PlayerState

func enter() -> void:
	player.anim_sprite.play(player.current_mode.anim_prefix + "_idle")
	print("Enter Idle State")

func exit() -> void:
	print("Exit Idle State")

func physics_update(delta: float) -> void:
	var mode : PlayerMode = player.current_mode
	var dir : float = Input.get_axis("move_left", "move_right")

	player.linear_velocity.x = move_toward(player.linear_velocity.x, 0, mode.friction * delta)

	if not player.is_on_floor():
		transitioned.emit(self, "fall")
	elif dir != 0:
		transitioned.emit(self, "run")
	elif Input.is_action_just_pressed("jump") and player.jumps_remaining > 0:
		transitioned.emit(self, "jump")
