extends PVZButtonBase
class_name TimeStopButton

@onready var label: Label = $Label
@onready var shortcut_hint: Label = $ShortcutHint


func _ready() -> void:
	super._ready()
	toggle_mode = true
	pressed.connect(_on_pressed)
	Global.time_stop_changed.connect(_sync_visual)
	_sync_visual(Global.is_time_stop)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_toggle():
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.is_action("ShortcutKeys_TimeStop") or event.keycode == KEY_E:
			Global.toggle_time_stop()
			get_viewport().set_input_as_handled()


func _on_pressed() -> void:
	if _can_toggle():
		Global.toggle_time_stop()
	else:
		_sync_visual(Global.is_time_stop)


func _sync_visual(active: bool) -> void:
	button_pressed = active
	label.text = "时停中" if active else "时停"
	shortcut_hint.visible = not active


func _process(_delta: float) -> void:
	var show_btn := _is_in_play_phase()
	visible = show_btn
	if not show_btn and Global.is_time_stop:
		Global.clear_time_stop()


func _is_in_play_phase() -> bool:
	if not is_instance_valid(Global.main_game):
		return false
	var progress: int = Global.main_game.main_game_progress
	return progress == MainGameManager.E_MainGameProgress.PREPARE \
		or progress == MainGameManager.E_MainGameProgress.MAIN_GAME


func _can_toggle() -> bool:
	if not _is_in_play_phase():
		return false
	var menu := Global.main_game.get_node_or_null("%MainGameMenuOptionDialog") as MainGameMenuOptionDialog
	if menu and menu.visible:
		return false
	if menu:
		var almanac := menu.get_node_or_null("%CanvasLayerAlmanac")
		if almanac and almanac.get_child_count() > 0:
			return false
	return true
