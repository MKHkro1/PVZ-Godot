extends Control
class_name Dialog


func appear_dialog():
	await get_tree().create_timer(0.1).timeout
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_button_pressed() -> void:
	await get_tree().create_timer(0.1).timeout
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

