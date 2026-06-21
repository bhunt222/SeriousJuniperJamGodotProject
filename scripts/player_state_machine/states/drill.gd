extends PlayerState

enum Phase { TRANSITION, DRILLING, EXIT_TRANSITION }

var _phase: Phase = Phase.TRANSITION
var _is_exiting: bool = false

func enter() -> void:
	_is_exiting = false
	_phase = Phase.TRANSITION
	player.set_gun_active(false)
	_play_enter_transition()

func exit() -> void:
	_disconnect_transition_signals()
	player.anim_sprite.speed_scale = 1.0
	player.set_gun_active(true)

func refresh_for_mode_change() -> void:
	if _phase == Phase.EXIT_TRANSITION:
		return
	if _phase == Phase.TRANSITION:
		_play_enter_transition()
	elif _phase == Phase.DRILLING:
		player.play_drilling()

func physics_update(_delta: float) -> void:
	if _phase == Phase.EXIT_TRANSITION or _is_exiting:
		return

	if _phase == Phase.DRILLING:
		player.apply_drill_force()
		var dir := player.get_move_dir()
		if dir != 0:
			player.apply_air_strafe(dir, player.current_mode)

	if not Input.is_action_pressed("drill"):
		_begin_exit_transition()

func _play_enter_transition() -> void:
	_disconnect_transition_signals()
	player.anim_sprite.speed_scale = 1.0
	var anim_name := player.get_drill_transition_animation()
	var frames := player.anim_sprite.sprite_frames
	if not frames.has_animation(anim_name) or frames.get_frame_count(anim_name) == 0:
		_begin_drilling()
		return
	player.anim_sprite.animation_finished.connect(_on_enter_transition_finished, CONNECT_ONE_SHOT)
	player.anim_sprite.play(anim_name)

func _on_enter_transition_finished() -> void:
	if player.anim_sprite.animation != player.get_drill_transition_animation():
		return
	_begin_drilling()

func _begin_drilling() -> void:
	_phase = Phase.DRILLING
	if not Input.is_action_pressed("drill"):
		_begin_exit_transition()
		return
	player.play_drilling()

func _begin_exit_transition() -> void:
	if _phase == Phase.EXIT_TRANSITION:
		return
	_phase = Phase.EXIT_TRANSITION
	_is_exiting = true
	_disconnect_transition_signals()
	player.anim_sprite.speed_scale = 1.0

	var anim_name := player.get_drill_transition_animation()
	var sprite := player.anim_sprite
	var frames := sprite.sprite_frames
	if not frames.has_animation(anim_name) or frames.get_frame_count(anim_name) == 0:
		_complete_exit()
		return

	sprite.animation_finished.connect(_on_exit_transition_finished, CONNECT_ONE_SHOT)

	if sprite.animation == anim_name and sprite.is_playing() and sprite.speed_scale > 0.0:
		sprite.speed_scale = -1.0
	else:
		sprite.play_backwards(anim_name)

func _on_exit_transition_finished() -> void:
	if player.anim_sprite.animation != player.get_drill_transition_animation():
		return
	player.anim_sprite.speed_scale = 1.0
	_complete_exit()

func _complete_exit() -> void:
	var dir := player.get_move_dir()
	if player.is_on_floor():
		player.reset_jumps()
		transitioned.emit(self, player.get_landing_state(dir))
	else:
		transitioned.emit(self, PlayerStateMachine.STATE_FALL)

func _disconnect_transition_signals() -> void:
	var sprite := player.anim_sprite
	if sprite.animation_finished.is_connected(_on_enter_transition_finished):
		sprite.animation_finished.disconnect(_on_enter_transition_finished)
	if sprite.animation_finished.is_connected(_on_exit_transition_finished):
		sprite.animation_finished.disconnect(_on_exit_transition_finished)
