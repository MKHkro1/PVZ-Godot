extends Node
class_name TombStoneManager

@onready var plant_cell_manager: PlantCellManager = %PlantCellManager

## 是否有墓碑(二维)
var all_is_tombstone:Array[Array]
## 墓碑数量
var tombstone_num := 0

func _ready() -> void:
	## 注册创建墓碑全局事件
	EventBus.subscribe("create_tombstone", create_tombstone)

## 初始化墓碑管理器
func init_tomb_stone_manager(_game_para:ResourceLevelData):
	# 植物种植区域信号，更新植物位置列号,更新墓碑信息
	for plant_cells_row_i in range(plant_cell_manager.all_plant_cells.size()):
		var plant_cells_row = plant_cell_manager.all_plant_cells[plant_cells_row_i]
		var is_tombstone_row := []
		for plant_cells_col_j in range(plant_cells_row.size() - 1, -1, -1):
			var plant_cell:PlantCell = plant_cells_row[plant_cells_col_j]
			plant_cell.row_col = Vector2(plant_cells_row_i, plant_cells_col_j)
			## 该位置没有墓碑
			is_tombstone_row.append(false)

		all_is_tombstone.append(is_tombstone_row)

#region 墓碑相关
## 生成待选位置,没有墓碑的行和列
func _candidates_position(rows:int, cols_start:int, cols_end:int=plant_cell_manager.row_col.y) -> Array[Vector2i]:
	# 构建可选位置列表
	var candidates: Array[Vector2i]= []
	for r in range(rows):
		for c in range(cols_start, cols_end):
			## 如果没有墓碑
			if not all_is_tombstone[r][c]:
				candidates.append(Vector2i(r, c))

	# 打乱顺序确保随机性
	candidates.shuffle()
	return candidates

## 随机生成墓碑的位置
func _reandom_tombstone_pos(new_num:int) ->  Array[Vector2i]:
	var rows = plant_cell_manager.row_col.x
	var cols = plant_cell_manager.row_col.y

	# 如果请求的数量超过所有格子总数，就返回所有格子
	if new_num + tombstone_num >= rows * cols:
		var all_positions = _candidates_position(rows, cols)
		return all_positions

	var usable_cols : int
	## 当场上墓碑数量小于 6列 * 行数时
	if tombstone_num < 6 * rows:
		usable_cols = cols - 6
	else:
		usable_cols = cols

	# 构建可选位置列表
	var candidates = _candidates_position(rows, usable_cols)
	print("待选位置", candidates)
	# 取前n个作为随机选择位置
	var selected_positions = candidates.slice(0, min(new_num, candidates.size()))

	if len(selected_positions) < new_num:
		# 构建可选位置列表
		var new_candidates = _candidates_position(rows, 0, usable_cols)
		var add_pos = new_candidates.slice(0, min(new_num- len(selected_positions), new_candidates.size()))

		selected_positions.append_array(add_pos)

	print("墓碑生成位置：",  selected_positions)

	return selected_positions

## 创建一个墓碑
func _create_one_tombstone(plant_cell: PlantCell, pos:Vector2i):
	assert(not is_instance_valid(plant_cell.tombstone))
	assert(not all_is_tombstone[pos.x][pos.y], "第"+str(pos)+"墓碑有问题")

	## plant_cell生成墓碑并连接信号
	plant_cell.create_tombstone()
	plant_cell.signal_cell_delete_tombstone.connect(_delete_tombstone)

	# 创建墓碑相关参数变化
	all_is_tombstone[pos.x][pos.y] = true
	tombstone_num += 1


## 删除墓碑修改对应的参数并断开信号连接
func _delete_tombstone(plant_cell:PlantCell, _tombstone:TombStone):
	var pos:Vector2i = plant_cell.row_col
	all_is_tombstone[pos.x][pos.y] = false
	tombstone_num -= 1
	plant_cell.signal_cell_delete_tombstone.disconnect(_delete_tombstone)


## 黑夜关卡生成墓碑（生成数量）
func create_tombstone(new_num:int):
	await get_tree().process_frame
	## 最大数量： 最大可生成列数 * 行数
	## 生成随机位置
	print("墓碑生成数量", new_num)
	var selected_positions :Array[Vector2i]= _reandom_tombstone_pos(new_num)

	print("墓碑生成位置", selected_positions)
	for pos in selected_positions:
		var plant_cell:PlantCell = plant_cell_manager.all_plant_cells[pos.x][pos.y]

		_create_one_tombstone(plant_cell, pos)


#endregion

#region 存档

func get_save_game_data_tomb_stone_manager()->Dictionary:
	var save_game_data_tomb_stome_manager:Dictionary = {}
	save_game_data_tomb_stome_manager["all_is_tombstone"] = all_is_tombstone

	return save_game_data_tomb_stome_manager

func load_game_data_tomb_stone_manager(save_game_data_tomb_stome_manager:Dictionary):
	var new_all_is_tombstone:Array[Array] = save_game_data_tomb_stome_manager.get("all_is_tombstone", all_is_tombstone)
	for i in range(new_all_is_tombstone.size()):
		for j in range(new_all_is_tombstone[i].size()):
			var pos:Vector2i = Vector2i(i,j)
			if new_all_is_tombstone[i][j]:
				var plant_cell:PlantCell = plant_cell_manager.all_plant_cells[pos.x][pos.y]
				_create_one_tombstone(plant_cell, pos)

#endregion
