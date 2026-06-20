extends Node
class_name PlayerState

signal transitioned(old_state: PlayerState, new_state: String)

var player: Player

func enter() -> void: pass
func exit() -> void: pass
func update(delta: float) -> void: pass
func physics_update(delta: float) -> void: pass
func handle_input(event: InputEvent) -> void: pass
