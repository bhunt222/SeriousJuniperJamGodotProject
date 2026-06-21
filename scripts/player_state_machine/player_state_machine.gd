extends Node
class_name PlayerStateMachine

const STATE_IDLE := "idle"
const STATE_RUN := "run"
const STATE_SPRINT := "sprint"
const STATE_JUMP := "jump"
const STATE_FALL := "fall"
const STATE_DRILL := "drill"
const STATE_SPIN_DASH_CHARGE := "spin_dash_charge"
const STATE_SPIN_DASH := "spin_dash"

@export var initial_state: PlayerState

var current_state: PlayerState
var states: Dictionary = {}

func _ready() -> void:
	var player: Player = get_parent()
	for child in get_children():
		var state_key := _state_key_from_node_name(String(child.name))
		states[state_key] = child
		child.player = player
		child.transitioned.connect(_on_transition)
	if initial_state:
		current_state = initial_state
		current_state.enter.call_deferred()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _state_key_from_node_name(node_name: String) -> String:
	var key := ""
	for i in node_name.length():
		var character := node_name[i]
		if character >= "A" and character <= "Z" and i > 0:
			key += "_"
		key += character.to_lower()
	return key

func get_state_name() -> String:
	if not current_state:
		return "none"
	for state_name in states:
		if states[state_name] == current_state:
			return state_name
	return "unknown"

func _on_transition(old: PlayerState, name: String) -> void:
	if old != current_state:
		return
	var new: PlayerState = states.get(name.to_lower())
	if not new:
		push_warning("PlayerStateMachine: unknown state '%s'" % name)
		return
	var from_name := get_state_name()
	current_state.exit()
	current_state = new
	new.enter()
	var player := get_parent() as Player
	EventBus.player_state_transition.emit(
		from_name,
		name.to_lower(),
		player.get_jump_debug_state() if player else {},
	)

func on_mode_changed() -> void:
	if not current_state:
		return
	var player := get_parent() as Player
	var state_name := get_state_name()
	current_state.refresh_for_mode_change()
	EventBus.player_state_mode_refresh.emit(
		state_name,
		player.get_jump_debug_state() if player else {},
	)
