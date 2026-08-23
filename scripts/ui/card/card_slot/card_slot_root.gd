extends Control
class_name CardSlotRoot

## 卡片
var curr_cards:Array[Card]
## 铲子
@onready var ui_shovel: UIShovel = %UIShovel

## 快捷键
@warning_ignore("unused_parameter")
func _unhandled_key_input(event):
	## 铲子快捷键
	if Input.is_action_just_pressed("ShortcutKeys_Shovel"):
		if ui_shovel.visible:
			ui_shovel._on_button_pressed()
		return
	## 卡片快捷键
	for i in range(1,11):
		## 卡片快捷键
		if Input.is_action_just_pressed("ShortcutKeys_Card" + str(int(i))):
			## 0-9
			var card_i = i - 1
			if card_i < curr_cards.size():
				curr_cards[card_i]._on_button_pressed()
			else:
				return

