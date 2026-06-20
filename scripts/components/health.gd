extends Node
class_name HealthComponent

signal health_depleted
signal health_changed

@export var max_health : int = 3
var current_health: int

func _ready() -> void:
	current_health = max_health

func remove_health(amount) -> void:
	pass

func add_health(amount) -> void:
	pass
