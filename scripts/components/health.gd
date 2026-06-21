extends Node
class_name HealthComponent

signal health_depleted
signal health_changed
signal damage_taken

@export var max_health : int = 3
var current_health: int

func _ready() -> void:
	current_health = max_health

func add_health(amount) -> void:
	if current_health == max_health:
		return
	elif current_health + amount > max_health:
		current_health = max_health
	else:
		current_health += amount

func remove_health(amount) -> void:
	if current_health - amount <= 0:
		health_depleted.emit()
	else:
		current_health -= amount
		damage_taken.emit()
