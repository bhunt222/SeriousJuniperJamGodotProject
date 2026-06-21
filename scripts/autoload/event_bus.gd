extends Node
## Global signal hub. Systems emit these signals; other systems connect to react.

# Player — jumps
signal player_jump_reset(jump_state: Dictionary)
signal player_jump_consumed(jump_state: Dictionary)
signal player_jump_requested(jump_state: Dictionary)
signal player_jump_denied(reason: String, jump_state: Dictionary)
signal player_jump_sync(reason: String, jump_state: Dictionary)

# Player — mode
signal player_mode_switched(
	from_mode: String,
	to_mode: String,
	entering_ball: bool,
	jump_state: Dictionary,
	state_name: String,
)

# Player — state machine
signal player_state_transition(from_state: String, to_state: String, jump_state: Dictionary)
signal player_state_mode_refresh(state_name: String, jump_state: Dictionary)
