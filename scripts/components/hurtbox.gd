extends Area2D
class_name HurtboxComponent

@export var health: HealthComponent

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		health.remove_health(area.damage_value)
