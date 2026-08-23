extends ItemBase
class_name Chocolate



func _input(event):
	if is_activate :
		## 如果是 点击鼠标左键
		if event is InputEventMouseButton:
			deactivate_it()
