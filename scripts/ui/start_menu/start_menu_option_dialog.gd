extends TextureRect
class_name StartMenuOptionDialog


@onready var music_h_slider: HSlider = $Option/Music/HSlider
@onready var sound_h_slider: HSlider = $Option/SoundEffect/HSlider

@onready var unlock_all_plants_check: CheckButton = $Option/UnlockAllPlants/CheckButton


func _ready() -> void:
	## 为按钮添加音效
	SoundManager.setup_ui_main_game_sound(self)
	Global.load_config()
	music_sound_signal(music_h_slider, AudioServer.get_bus_index("BGM"))
	music_sound_signal(sound_h_slider, AudioServer.get_bus_index("SFX"))

	unlock_all_plants_check.button_pressed = Global.unlock_all_plants

func music_sound_signal(h_slider: HSlider, bus_index):
	h_slider.value = SoundManager.get_volum(bus_index)
	h_slider.value_changed.connect(func (v:float):
		SoundManager.set_volume(bus_index, v)
		Global.save_config()
	)


## 出现菜单
func appear_menu():
	await get_tree().create_timer(0.1).timeout

	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP


## 关闭菜单
func return_button_pressed():
	await get_tree().create_timer(0.1).timeout
	Global.save_config()

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_unlock_all_plants_toggled(toggled_on: bool) -> void:
	Global.unlock_all_plants = toggled_on
	Global.save_config()
