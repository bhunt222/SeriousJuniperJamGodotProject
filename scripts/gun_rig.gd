extends Node2D

const CHARGE_ANIM := &"charge_throw"
const THROW_ANIM := &"throw"

@onready var arm_sprite: AnimatedSprite2D = $ArmSprite
@onready var bullet_spawn_point: Marker2D = $BulletSpawnPoint
@export var bullet_container: Node2D

@export var bullet_speed: float = 600.0
@export var bullet_scene: PackedScene

var _is_charging: bool = false
var _is_throwing: bool = false

func _process(_delta: float) -> void:
	var player := get_parent() as Player
	if player and player.can_fire_gun() and visible:
		look_at(get_global_mouse_position())

func _physics_process(_delta: float) -> void:
	var player := get_parent() as Player
	if not player or not player.can_fire_gun() or not visible:
		_cancel_charge()
		return

	if _is_throwing:
		return

	if Input.is_action_just_pressed("shoot"):
		_begin_charge()
	elif Input.is_action_pressed("shoot") and _is_charging:
		_maintain_charge()
	elif Input.is_action_just_released("shoot") and _is_charging:
		_release_charge()

func _begin_charge() -> void:
	_is_charging = true
	arm_sprite.play(CHARGE_ANIM)

func _maintain_charge() -> void:
	if arm_sprite.animation != CHARGE_ANIM or not arm_sprite.is_playing():
		arm_sprite.play(CHARGE_ANIM)

func _release_charge() -> void:
	_is_charging = false
	_is_throwing = true
	arm_sprite.play(THROW_ANIM)
	_spawn_bullet()
	if arm_sprite.animation_finished.is_connected(_on_throw_finished):
		arm_sprite.animation_finished.disconnect(_on_throw_finished)
	arm_sprite.animation_finished.connect(_on_throw_finished, CONNECT_ONE_SHOT)

func _cancel_charge() -> void:
	if not _is_charging and not _is_throwing:
		return
	_is_charging = false
	if _is_throwing:
		return
	if arm_sprite.animation_finished.is_connected(_on_throw_finished):
		arm_sprite.animation_finished.disconnect(_on_throw_finished)
	if arm_sprite.sprite_frames.has_animation(CHARGE_ANIM):
		arm_sprite.play(CHARGE_ANIM)
		arm_sprite.pause()

func _on_throw_finished() -> void:
	if arm_sprite.animation != THROW_ANIM:
		return
	_is_throwing = false

func _spawn_bullet() -> void:
	if not bullet_scene:
		push_warning("GunRig: bullet_scene is not assigned")
		return
	if not bullet_container:
		push_warning("GunRig: bullet_container is not assigned")
		return

	var player := get_parent() as Player
	var bullet: Bullet = bullet_scene.instantiate()
	bullet_container.add_child(bullet)
	bullet.global_position = bullet_spawn_point.global_position
	bullet.global_rotation = global_rotation

	var direction := Vector2.RIGHT.rotated(bullet.global_rotation)
	var inherited_velocity := player.linear_velocity if player else Vector2.ZERO
	bullet.velocity = inherited_velocity + direction * bullet_speed
