extends Sprite2D
class_name WallnutBowlingStripe

var plant_cell_manager:PlantCellManager

func init_item(plant_cell_col_j:int=2, plant_cell_can_use:Dictionary = {}):
	## 确定红线位置
	var target_plant_cell:PlantCell= Global.main_game.plant_cell_manager.all_plant_cells[0][plant_cell_col_j]
	var target_global_pos_x:float = target_plant_cell.global_position.x
	var target_global_pos_y:float = target_plant_cell.global_position.y

	## 如果存在屋顶斜面
	if is_instance_valid(Global.main_game.main_game_slope):
		scale.y = 0.88
		## 后面一格，屋顶时确定y
		if Global.main_game.plant_cell_manager.all_plant_cells[0].get(plant_cell_col_j + 1):
			target_global_pos_y = Global.main_game.plant_cell_manager.all_plant_cells[0][plant_cell_col_j + 1].global_position.y

	global_position = Vector2(target_global_pos_x + target_plant_cell.size.x - 11, target_global_pos_y)


	for plant_cells_row in Global.main_game.plant_cell_manager.all_plant_cells:
		## 左边不可以种植
		if not plant_cell_can_use["left_can_plant"]:
			for j in range(plant_cell_col_j + 1):
				var plant_cell:PlantCell = plant_cells_row[j]
				plant_cell.set_bowling_no_plant()
		## 右边不可以种植
		if not plant_cell_can_use["right_can_plant"]:
			for j in range(plant_cell_col_j + 1, plant_cells_row.size()):
				var plant_cell:PlantCell = plant_cells_row[j]
				plant_cell.set_bowling_no_plant()

		## 左边不可以僵尸
		if not plant_cell_can_use["left_can_zombie"]:
			for j in range(plant_cell_col_j + 1):
				var plant_cell:PlantCell = plant_cells_row[j]
				plant_cell.set_bowling_no_zombie()
		## 右边不可以僵尸
		if not plant_cell_can_use["right_can_zombie"]:
			for j in range(plant_cell_col_j + 1, plant_cells_row.size()):
				var plant_cell:PlantCell = plant_cells_row[j]
				plant_cell.set_bowling_no_zombie()

