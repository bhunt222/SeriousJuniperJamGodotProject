extends PlayerState

func enter() -> void:
	player.anim_sprite.play(player.current_mode.anim_prefix + "_run")
	print("Enter Run State")

func exit() -> void:
	print("Exit Run State")

func physics_update(_delta: float) -> void:
	var mode : PlayerMode = player.current_mode
	var dir : float = Input.get_axis("move_left", "move_right")

	player.apply_central_force(Vector2(dir * mode.run_speed, 0))

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
	elif player.horizontal_speed() >= mode.sprint_enter_speed:
		transitioned.emit(self, "sprint")
