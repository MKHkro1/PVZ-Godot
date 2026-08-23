extends Control
class_name wood_sign

@onready var label: Label = $TextureRect/Panel/Label



func _ready() -> void:
	label.text = Global.curr_user_name
	Global.signal_users_update.connect(_on_update_curr_user)


func _on_update_curr_user():
	label.text = Global.curr_user_name

