extends ItemBase
class_name ItemPlantCellBase

## 当前选择的植物格子
var curr_plant_cell :PlantCellGarden

func _input(event):
	## 不是克隆体且当前为激活状态
	if not is_clone and is_activate:
		## 鼠标左键按下
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			## 安卓端等待两帧移动到对应的位置
			is_mouse_button_pressed_wait = true
			global_position = get_global_mouse_position()
			body.visible = false
			await get_tree().physics_frame
			await get_tree().physics_frame
			## 如果当前有植物格子
			if judge_is_curr_plant_cell():
				use_it()
			## 如果当前没有植物格子
			else:
				deactivate_it()
			is_mouse_button_pressed_wait = false
		## 鼠标右键
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			deactivate_it()

## 判断当前是否有植物格子
func judge_is_curr_plant_cell() -> bool:
	return curr_plant_cell != null and curr_plant_cell.plant_in_cell

## 检测到进入的植物格子
func _on_area_2d_area_entered(area: Area2D) -> void:
	curr_plant_cell = area.owner
	curr_plant_cell.plant_cell_light()

## 检测到出去的植物格子,每个格子不连在一起
func _on_area_2d_area_exited(area: Area2D) -> void:
	var new_plant_cell:PlantCellGarden = area.owner
	new_plant_cell.plant_cell_color_restore()
	curr_plant_cell = null
