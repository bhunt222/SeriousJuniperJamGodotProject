extends PlayerState

func enter() -> void:
	player.anim_sprite.play(player.current_mode.anim_prefix + "_sprint")
	print("Enter Sprint State")

func exit() -> void:
	print("Exit Sprint State")

func physics_update(_delta: float) -> void:
	var mode : PlayerMode = player.current_mode
	var dir : float = Input.get_axis("move_left", "move_right")

	player.apply_central_force(Vector2(dir * mode.sprint_speed, 0))

	if dir > 0:
		player.anim_sprite.flip_h = false
	elif dir < 0:
		player.anim_sprite.flip_h = true

	if dir == 0:
		transitioned.emit(self, "idle")
	elif not player.is_on_floor():
		transitioned.emit(self, "fall")
	elif Input.is_action_just_pressed("jump") and player.jumps_remaining > 0:
		transitioned.emit(self, "jump")
	elif player.horizontal_speed() < mode.sprint_exit_speed:
		transitioned.emit(self, "run")
