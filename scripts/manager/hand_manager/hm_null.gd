extends Node
## 手持管理器，无东西
class_name HM_NUll

## 当前鼠标所在格子
var curr_plant_cell :PlantCell

func null_process() -> void:
	return

## 鼠标进入cell
func mouse_enter(plant_cell:PlantCell):
	curr_plant_cell = plant_cell
	if is_instance_valid(curr_plant_cell.pot):
		curr_plant_cell.pot.mouse_enter_pot()

## 鼠标移出cell
func mouse_exit(plant_cell:PlantCell):
	if is_instance_valid(plant_cell.pot):
		plant_cell.pot.mouse_exit_pot()
	curr_plant_cell = null

func click_cell(plant_cell:PlantCell):
	if is_instance_valid(plant_cell.pot):
		plant_cell.pot.open_pot_be_hammar()

## 退出当前状态
func exit_status():
	if curr_plant_cell != null:
		if is_instance_valid(curr_plant_cell.pot):
			curr_plant_cell.pot.mouse_exit_pot()
		curr_plant_cell = null
