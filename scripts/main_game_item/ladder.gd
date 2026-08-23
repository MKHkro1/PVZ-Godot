extends Node2D
class_name Ladder

@onready var iron_node: IronNode = $IronNode
@onready var area_2d_detect: Area2D = $Area2DDetect

## 梯子所属植物格子
var plant_cell:PlantCell
## 梯子所在行
var lane:int

func _ready() -> void:
	## 斜面时更新对应的检测位置
	GlobalUtils.update_plant_cell_slope_y(plant_cell, area_2d_detect)

## 初始化梯子
func init_ladder(curr_plant_cell:PlantCell):
	self.plant_cell = curr_plant_cell
	self.lane = plant_cell.row_col.x

## 梯子死亡
func ladder_death():
	plant_cell.ladder_loss()
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var zombie :Zombie000Base = area.owner
	if lane == zombie.lane and not zombie.is_ignore_ladder:
		zombie.start_climbing_ladder()
