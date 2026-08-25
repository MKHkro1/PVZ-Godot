extends Sprite2D
class_name RealHammer

var is_using := false

func _process(_delta: float) -> void:
	if is_using:
		global_position = get_global_mouse_position()

func change_is_using(value: bool) -> void:
	is_using = value
	visible = value
