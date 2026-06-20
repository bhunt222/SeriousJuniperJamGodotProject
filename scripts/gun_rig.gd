extends Node2D

@onready var bullet_spawn_point: Marker2D = $BulletSpawnPoint
@export var bullet_container: Node2D

@export var bullet_speed : float = 600.0
@export var bullet_scene : PackedScene


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
func shoot_bullet() -> void:
	if !bullet_scene:
		print("No bullet scene set on gun_rig")
		return

	var player := get_parent() as Player
	var bullet : Bullet = bullet_scene.instantiate()
	bullet_container.add_child(bullet)
	bullet.global_position = bullet_spawn_point.global_position
	bullet.global_rotation = global_rotation

	var direction := Vector2.RIGHT.rotated(bullet.global_rotation)
	var inherited_velocity := player.linear_velocity if player else Vector2.ZERO
	bullet.velocity = inherited_velocity + direction * bullet_speed
