extends Panel
class_name DaveDialogMousePress
## 戴夫对话时检测鼠标点击，发出信号，同时截断鼠标点击时间

## 戴夫对话时，检查鼠标是否点击
signal signal_dave_dialog_press

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			signal_dave_dialog_press.emit()
