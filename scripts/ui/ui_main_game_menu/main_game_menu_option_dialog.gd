extends TextureRect
class_name MainGameMenuOptionDialog

@onready var dialog: Dialog = $"../Dialog"

@onready var music_h_slider: HSlider = $Option/VBoxContainer/Music/HSlider
@onready var sound_h_slider: HSlider = $Option/VBoxContainer/SoundEffect/HSlider
@onready var time_scale_h_slider: HSlider = $Option/VBoxContainer/TimeScale/HSlider
@onready var time_sacle_label: Label = $Option/VBoxContainer/TimeScale/Label
@onready var unlock_all_plants_check: CheckBox = $Option/VBoxContainer/UnlockAllPlants
@onready var canvas_layer_console: CanvasLayerConsole = %CanvasLayerConsole
## 图鉴场景所在的画布层
@onready var canvas_layer_almanac: CanvasLayer = %CanvasLayerAlmanac
@onready var option_root: Control = $Option
@onready var option_vbox: VBoxContainer = $Option/VBoxContainer
@onready var button_encyclopedia: BaseButton = $Option/Button1
@onready var button_restart: BaseButton = $Option/Button2
@onready var button_main_menu: BaseButton = $Option/Button3
@onready var button_console: BaseButton = $Option/Button4
@onready var button_return: TextureButton = $Return

var _is_game_over_menu := false


func _ready() -> void:
	## 为按钮添加音效
	SoundManager.setup_ui_main_game_sound(self)
	Global.load_config()
	## 连接滑轨信号
	music_sound_signal(music_h_slider, AudioServer.get_bus_index("BGM"))
	music_sound_signal(sound_h_slider, AudioServer.get_bus_index("SFX"))
	time_sacle_signal(time_scale_h_slider)
	time_sacle_label.text = "倍速 " + str(Global.time_scale) + " 倍"
	unlock_all_plants_check.button_pressed = Global.unlock_all_plants


#region 空格/Esc 快捷开关菜单
## 游戏中按 空格 或 Esc 直接呼出/收起菜单
## (_unhandled_input: 被 GUI 消费的按键不会触发, 不影响滑轨/复选框操作)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE:
			toggle_menu_by_hotkey()


## 快捷键切换菜单
func toggle_menu_by_hotkey() -> void:
	if _is_game_over_menu:
		return
	## 图鉴打开时交给图鉴自己处理
	if canvas_layer_almanac.get_child_count() > 0:
		return
	if visible:
		return_button_pressed()
	else:
		## 仅在游戏进行中(准备阶段/正式阶段)响应弹出
		var progress: int = Global.main_game.main_game_progress
		if progress == MainGameManager.E_MainGameProgress.PREPARE \
				or progress == MainGameManager.E_MainGameProgress.MAIN_GAME:
			appear_menu()
#endregion


func music_sound_signal(h_slider: HSlider, bus_index):
	h_slider.value = SoundManager.get_volum(bus_index)
	h_slider.value_changed.connect(func (v:float):
		SoundManager.set_volume(bus_index, v)
		Global.save_config()
	)


func time_sacle_signal(h_slider: HSlider):
	h_slider.value_changed.connect(func (v:float):
		Global.time_scale = snapped(v, 0.1)
		time_sacle_label.text = "倍速 " + str(Global.time_scale) + " 倍"
		if not Global.is_time_stop:
			Engine.time_scale = Global.time_scale
		)

## 出现菜单
func appear_menu():
	_set_normal_menu_layout()
	await get_tree().create_timer(0.1).timeout
	# 游戏暂停

	Global.start_tree_pause(Global.E_PauseFactor.Menu)
	SoundManager.play_other_SFX("pause")

	visible = true
	## 聚焦到关闭按钮: 空格/回车可直接继续游戏, 方向键可导航菜单
	button_return.grab_focus()
	#mouse_filter = Control.MOUSE_FILTER_STOP


## 失败后弹出: 仅重新开始 / 返回主菜单
func appear_game_over_menu() -> void:
	_is_game_over_menu = true
	_set_game_over_menu_layout()
	visible = true
	button_restart.grab_focus()


func _set_normal_menu_layout() -> void:
	_is_game_over_menu = false
	option_vbox.visible = true
	button_encyclopedia.visible = true
	button_console.visible = true
	button_restart.visible = true
	button_main_menu.visible = true
	button_return.visible = true


func _set_game_over_menu_layout() -> void:
	option_vbox.visible = false
	button_encyclopedia.visible = false
	button_console.visible = false
	button_restart.visible = true
	button_main_menu.visible = true
	button_return.visible = false

## 关闭菜单防抖时间戳(快捷键与焦点按钮可能对同一按键双触发)
var _last_close_request_ms := -10000

## 关闭菜单
func return_button_pressed():
	if _is_game_over_menu:
		return
	var now := Time.get_ticks_msec()
	if now - _last_close_request_ms < 250:
		return
	_last_close_request_ms = now
	Global.save_config()
	await get_tree().create_timer(0.1).timeout
	SoundManager.play_other_SFX("pause")
	visible = false
	## 清除焦点, 防止战场上的控件残留焦点被空格误触发
	get_viewport().gui_release_focus()

	Global.end_tree_pause(Global.E_PauseFactor.Menu)
	#mouse_filter = Control.MOUSE_FILTER_IGNORE

## 图鉴
func encyclopedia():
	var almance_node = load(Global.MainScenesMap[Global.MainScenes.Almanac]).instantiate()
	canvas_layer_almanac.add_child(almance_node)


## 重新开始
func resume_game():
	_is_game_over_menu = false
	EventBus.push_event("change_is_mouse_visibel_on_hammer", true)

	Global.main_game.re_main_game()

	Global.end_tree_pause_clear_all_pause_factors()
	Global.time_scale = 1.0
	Global.clear_time_stop()
	## 平滑过渡重开本关(与全局场景切换一致, 不再硬切)
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)


## 返回主菜单
func return_main_menu():
	_is_game_over_menu = false
	EventBus.push_event("change_is_mouse_visibel_on_hammer", true)
	Global.end_tree_pause_clear_all_pause_factors()
	Global.time_scale = 1.0
	Global.clear_time_stop()
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.StartMenu])

## 功能未实现
func _unrealized():
	dialog.appear_dialog()

## 出现控制台
func _on_button_console_pressed() -> void:
	canvas_layer_console.appear_canvas_layer_control()


func _on_unlock_all_plants_toggled(toggled_on: bool) -> void:
	Global.unlock_all_plants = toggled_on
	Global.save_config()



