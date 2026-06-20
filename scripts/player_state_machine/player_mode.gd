extends Resource
class_name PlayerMode

@export var anim_prefix : String = "normal"
@export var run_speed : float = 300.0
@export var sprint_speed : float = 450.0
@export var sprint_enter_speed : float = 350.0
@export var sprint_exit_speed : float = 300.0
@export var air_accel : float = 400.0
@export var air_max_speed : float = 300.0
@export var jump_power: float = 500.0
@export var friction: float = 500.0
@export var gravity: float = 980.0
@export var can_shoot: bool = true
@export var can_double_jump: bool = false
@export var spin_in_air: bool = false
