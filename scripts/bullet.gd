extends Area2D
class_name Bullet

@export var bullet_speed : float = 600.0

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _delete_bullet() -> void:
	pass
