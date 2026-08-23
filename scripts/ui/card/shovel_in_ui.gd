extends TextureRect
class_name UIShovel

@onready var shovel: TextureRect = $Shovel

## 鼠标点击铲子
func _on_button_pressed() -> void:
	shovel.visible = false
	EventBus.push_event("main_game_click_shovel")

func ui_shovel_appear():
	shovel.visible = true
