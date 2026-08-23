extends ItemPlantNeedBase
class_name WateringCan

@onready var zen_gold_tool_reticle_result: Sprite2D = $ZenGoldToolReticleResult
## 当前碰撞的植物格子，单格子道具使用时，每个格子之间必须有空隙，并且道具碰撞器要非常小
var curr_plant_cells:Array[PlantCellGarden]


## 判断当前是否有植物格子
func judge_is_curr_plant_cell() -> bool:
	return curr_plant_cells != []


func use_it():
	play_plant_need_item_sfx()
	var clone_item_plant_cells = curr_plant_cells.duplicate(true)
	var clone:ItemBase = clone_self()

	## 如果当前只对一个植物生效，修改道具位置
	if clone_item_plant_cells.size() == 1 and correct_position:
		clone.global_position = clone_item_plant_cells[0].global_position + correct_position

	clone.visible = true
	clone.anim_lib.play("ALL_ANIMS")

	deactivate_it(false)

	await clone.anim_lib.animation_finished
	for plant_cell in clone_item_plant_cells:
		if plant_cell and is_instance_valid(plant_cell):
			plant_cell.use_item_in_this(self)
	clone.queue_free()


## 克隆自己
func clone_self():
	var clone = super.clone_self()
	clone.zen_gold_tool_reticle_result.visible = false
	return clone


## 检测到进入的植物格子
func _on_area_2d_area_entered(area: Area2D) -> void:
	var new_plant_cell:PlantCellGarden = area.get_parent()
	curr_plant_cells.append(new_plant_cell)
	new_plant_cell.plant_cell_light()


## 检测到出去的植物格子
func _on_area_2d_area_exited(area: Area2D) -> void:
	var new_plant_cell:PlantCellGarden = area.get_parent()
	curr_plant_cells.erase(new_plant_cell)
	new_plant_cell.plant_cell_color_restore()

