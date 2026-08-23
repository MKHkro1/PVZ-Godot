extends Node
## 手持管理器，铲子（植物僵尸）
class_name HM_Item

@onready var ui_shovel: UIShovel = %UIShovel
@onready var real_shovel: RealShovel = %RealShovel

## 手持道具状态
enum E_HmItemStatus{
	Null,
	Shovel
}
var curr_hm_item_status := E_HmItemStatus.Null

## 当前鼠标所在格子
var curr_plant_cell :PlantCell

## 当前铲子选择植物
var plant_be_shovel_look:Plant000Base
## 当前铲子所在格子植物数量
var curr_shovel_look_plant_num:int = 0


func click_shovel():
	curr_hm_item_status = E_HmItemStatus.Shovel
	real_shovel.change_is_using(true)

func item_process() -> void:
	## 如果有预铲植物并且当前格子有多个植物时
	if plant_be_shovel_look and curr_shovel_look_plant_num >= 2:
		var new_plant_be_shovel_look = curr_plant_cell.return_plant_be_shovel_look()
		if new_plant_be_shovel_look == plant_be_shovel_look:
			pass
		else:
			plant_be_shovel_look.be_shovel_look_end()
			plant_be_shovel_look = new_plant_be_shovel_look
			plant_be_shovel_look.be_shovel_look()

## 鼠标进入cell
func mouse_enter(plant_cell:PlantCell):
	curr_plant_cell = plant_cell
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			## 获取当前格子植物数量
			curr_shovel_look_plant_num = plant_cell.get_curr_plant_num()
			if curr_shovel_look_plant_num >= 1:
				plant_be_shovel_look = plant_cell.return_plant_be_shovel_look()
				plant_be_shovel_look.be_shovel_look()

## 鼠标移出cell
@warning_ignore("unused_parameter")
func mouse_exit(plant_cell:PlantCell):
	curr_plant_cell = null

	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			## 如果有被铲子关注的植物
			if plant_be_shovel_look:
				plant_be_shovel_look.be_shovel_look_end()
				plant_be_shovel_look = null
				curr_shovel_look_plant_num = 0


## 点击铲掉植物
@warning_ignore("unused_parameter")
func click_cell(plant_cell:PlantCell):
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			## 如果有被铲子关注的植物
			if plant_be_shovel_look:
				SoundManager.play_other_SFX("plant2")
				plant_be_shovel_look.be_shovel_kill()


## 退出当前状态
func exit_status():
	curr_hm_item_status = E_HmItemStatus.Null
	if plant_be_shovel_look:
		plant_be_shovel_look.be_shovel_look_end()
	plant_be_shovel_look = null
	curr_shovel_look_plant_num = 0
	real_shovel.change_is_using(false)
	ui_shovel.ui_shovel_appear()
