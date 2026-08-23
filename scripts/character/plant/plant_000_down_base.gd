extends Plant000Base
class_name Plant000DownBase
## 底部类植物基类

## 底部类植物
## 底部植物容器节点，作为中间植物容器的父节点
## 底部植物容器节点会上下移动，带动中间植物上下移动
## 荷叶使用tween控制移动，花盆使用动画控制
## TODO：可以都改为动画类控制
#@export var down_plant_container:Node2D
@onready var down_plant_container: Node2D = $DownPlantContainer

## 底部类植物放置后，norm和shell植物位置变化
@export var plant_up_position :Vector2

## 植物初始化相关
func init_plant(plant_init_para:Dictionary) -> void:
	super(plant_init_para)
	if plant_init_para[E_PInitAttr.CharacterInitType] != E_CharacterInitType.IsNorm:
		return
	plant_cell.down_plant_change_condition(plant_cell.plant_cell_type == PlantCell.PlantCellType.Pool)

## 角色死亡时切换地形
func character_death():
	plant_cell.down_plant_change_condition(plant_cell.plant_cell_type == PlantCell.PlantCellType.Pool)
	super()
