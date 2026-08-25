extends Control
class_name Dialog


func appear_dialog():
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate = Color(1, 1, 1, 0)
	scale = Vector2(0.8, 0.8)
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
	await tween.finished


func _on_button_pressed() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	await tween.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
