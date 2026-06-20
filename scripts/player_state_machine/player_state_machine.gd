extends Node
class_name PlayerStateMachine

@export var initial_state: PlayerState

var current_state: PlayerState
var states: Dictionary = {}

func _ready() -> void:
	var player: Player = get_parent()
	for child in get_children():
		states[String(child.name).to_lower()] = child
		child.player = player
		child.transitioned.connect(_on_transition)
	if initial_state:
		current_state = initial_state
		current_state.enter.call_deferred()

func _process(delta: float) -> void:
	if current_state: current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state: current_state.physics_update(delta)

func _on_transition(old: PlayerState, name: String) -> void:
	if old != current_state: return
	var new: PlayerState = states.get(name.to_lower())
	if not new: return
	current_state.exit()
	new.enter()
	current_state = new

func on_mode_changed() -> void:
	if current_state:
		current_state.enter()
