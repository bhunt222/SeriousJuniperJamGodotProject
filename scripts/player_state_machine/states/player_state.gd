extends Node
class_name PlayerState

signal transitioned(old_state: PlayerState, new_state: String)

var player: Player

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func refresh_for_mode_change() -> void:
	enter()

func try_transition_spin_dash_charge() -> bool:
	if not player.is_ball_mode():
		return false
	if not Input.is_action_just_pressed("spin_dash"):
		return false
	transitioned.emit(self, PlayerStateMachine.STATE_SPIN_DASH_CHARGE)
	return true

func try_transition_drill() -> bool:
	if not Input.is_action_just_pressed("drill"):
		return false
	transitioned.emit(self, PlayerStateMachine.STATE_DRILL)
	return true

func try_transition_jump() -> bool:
	if not player.wants_jump():
		return false
	transitioned.emit(self, PlayerStateMachine.STATE_JUMP)
	return true

func check_airborne_transition() -> bool:
	if not player.is_on_floor():
		transitioned.emit(self, PlayerStateMachine.STATE_FALL)
		return true
	return false
