extends Button
class_name OneUserButton

const ON_CHOOSE_ONE_USER_BUTTON = preload("res://resources/button_styles/on_choose_one_user_button.tres")
@onready var label: Label = $Label
var user_name_on_curr_button :String

## 当该用户名的button被选择
func on_user_be_choosed():
	add_theme_stylebox_override(&"normal", ON_CHOOSE_ONE_USER_BUTTON)

## 当该用户名的button取消选择时
func on_user_cancel_choosed():
	remove_theme_stylebox_override(&"normal")

func set_button_user_name(user_name:String):
	label.text = user_name
	user_name_on_curr_button = user_name
