extends Node
## Subscribes to EventBus signals and writes a session log to disk each run.

const LOG_PATH := "user://debug.log"

var enabled: bool = ProjectSettings.get_setting("debug/log/enabled", OS.is_debug_build())
var print_to_console: bool = ProjectSettings.get_setting("debug/log/print_to_console", false)

var _log_file: FileAccess


func _ready() -> void:
	if not enabled:
		return
	if not _open_log_file():
		return
	EventBus.player_jump_reset.connect(_on_player_jump_reset)
	EventBus.player_jump_consumed.connect(_on_player_jump_consumed)
	EventBus.player_jump_requested.connect(_on_player_jump_requested)
	EventBus.player_jump_denied.connect(_on_player_jump_denied)
	EventBus.player_jump_sync.connect(_on_player_jump_sync)
	EventBus.player_mode_switched.connect(_on_player_mode_switched)
	EventBus.player_state_transition.connect(_on_player_state_transition)
	EventBus.player_state_mode_refresh.connect(_on_player_state_mode_refresh)
	_write_line("# session started %s" % Time.get_datetime_string_from_system())


func _exit_tree() -> void:
	_close_log_file()


func get_log_path() -> String:
	return ProjectSettings.globalize_path(LOG_PATH)


func _open_log_file() -> bool:
	_log_file = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if _log_file:
		return true
	push_warning("DebugLog: could not open log file at %s" % LOG_PATH)
	return false


func _close_log_file() -> void:
	if _log_file:
		_log_file.close()
		_log_file = null


func _write_line(message: String) -> void:
	if not _log_file:
		return
	_log_file.store_line(message)
	_log_file.flush()
	if print_to_console:
		print("[DebugLog] %s" % message)


func _on_player_jump_reset(jump_state: Dictionary) -> void:
	_record(&"player_jump_reset", jump_state, "jump budget reset on landing")


func _on_player_jump_consumed(jump_state: Dictionary) -> void:
	_record(&"player_jump_consumed", jump_state, "jump consumed")


func _on_player_jump_requested(jump_state: Dictionary) -> void:
	_record(&"player_jump_requested", jump_state, "jump input accepted")


func _on_player_jump_denied(reason: String, jump_state: Dictionary) -> void:
	var payload := jump_state.duplicate()
	payload["reason"] = reason
	_record(&"player_jump_denied", payload, "jump denied: %s" % reason)


func _on_player_jump_sync(reason: String, jump_state: Dictionary) -> void:
	var payload := jump_state.duplicate()
	payload["reason"] = reason
	_record(&"player_jump_sync", payload, "jump budget synced")


func _on_player_mode_switched(
	from_mode: String,
	to_mode: String,
	entering_ball: bool,
	jump_state: Dictionary,
	state_name: String,
) -> void:
	var payload := jump_state.duplicate()
	payload["from_mode"] = from_mode
	payload["to_mode"] = to_mode
	payload["entering_ball"] = entering_ball
	payload["state"] = state_name
	_record(&"player_mode_switched", payload, "mode switched %s -> %s" % [from_mode, to_mode])


func _on_player_state_transition(from_state: String, to_state: String, jump_state: Dictionary) -> void:
	var payload := jump_state.duplicate()
	payload["from_state"] = from_state
	payload["to_state"] = to_state
	_record(&"player_state_transition", payload, "state %s -> %s" % [from_state, to_state])


func _on_player_state_mode_refresh(state_name: String, jump_state: Dictionary) -> void:
	var payload := jump_state.duplicate()
	payload["state"] = state_name
	_record(&"player_state_mode_refresh", payload, "state refreshed for mode change")


func _record(event_name: StringName, payload: Dictionary, detail: String) -> void:
	var enriched := payload.duplicate()
	enriched["frame"] = Engine.get_physics_frames()
	enriched["time"] = Time.get_ticks_msec() / 1000.0
	enriched["detail"] = detail
	_write_line(_format_message(event_name, enriched))


func _format_message(event_name: StringName, payload: Dictionary) -> String:
	var frame := int(payload.get("frame", 0))
	var time_sec := float(payload.get("time", 0.0))
	var detail = payload.get("detail", "")
	var parts: PackedStringArray = [
		"F%d" % frame,
		"%.2fs" % time_sec,
		String(event_name),
	]
	if detail:
		parts.append(str(detail))
	for key in payload.keys():
		if key in ["frame", "time", "detail"]:
			continue
		parts.append("%s=%s" % [key, _stringify(payload[key])])
	return " | ".join(parts)


func _stringify(value: Variant) -> String:
	match typeof(value):
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_FLOAT:
			return "%0.2f" % value
		_:
			return str(value)
