extends Node2D
class_name Enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flash_timer: Timer = $FlashTimer
var flash_tween: Tween

func _flash(num_of_flashes: int) -> void:
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	
	flash_tween = create_tween()
	
	for i in range(num_of_flashes):
		flash_tween.tween_method(_set_flash, 0.0, 1.0, 0.0)
		flash_tween.tween_interval(0.1)
		flash_tween.tween_method(_set_flash, 1.0, 0.0, 0.0)
		flash_tween.tween_interval(0.1)

func _on_health_health_depleted() -> void:
	queue_free()

func _set_flash(value: float) -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("flash_modifier", value)

func _on_health_damage_taken() -> void:
	_flash(2)
