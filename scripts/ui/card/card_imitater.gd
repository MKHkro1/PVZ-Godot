extends Card
class_name CardImitater
## 模仿者卡片,只用于备选卡槽中的额外模仿者

## 是否已经选择模仿者卡片
var is_be_choosed_imitater:= false

## 点击卡片时
func _on_button_pressed() -> void:
	if not is_be_choosed_imitater:
		signal_card_click.emit()

## 模仿者选卡时被选择
func imitater_card_be_choosed():
	_cool_mask.visible = true
	is_be_choosed_imitater = true

## 模仿者选卡时被取消选择
func imitater_card_be_choosed_cancal():
	_cool_mask.visible = false
	is_be_choosed_imitater = false
