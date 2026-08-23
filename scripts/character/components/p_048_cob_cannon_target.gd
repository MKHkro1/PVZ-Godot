extends Sprite2D
class_name CobCannonTarget

var is_activate:= false

## 加农炮攻击信号
signal signal_cannon_fire(target_global_pos:Vector2)

func _process(_delta: float) -> void:
	if is_activate:
		global_position = get_global_mouse_position()

func _unhandled_input(event):
	## 激活状态下
	if is_activate:
		## 左键点击
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			signal_cannon_fire.emit(global_position)
			deactivate_it()

		## 右键点击
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			deactivate_it()



func activate_it():
	is_activate = true
	visible = true

func deactivate_it():
	is_activate = false
	visible = false


