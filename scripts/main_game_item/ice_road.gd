extends Node2D
class_name IceRoad
## 冰道使用TextureRect节点,
## 为了方便使用,左右反过来的(scale=[-1,1]),位置固定,修改大小,从而延申冰道
## 使用事件总线推送当前冰道,让plant_cell连接信号

@onready var texture_rect: TextureRect = $TextureRect
@onready var ice_road_disappear_timer: Timer = $IceRoadDisappearTimer

## 冰冻生成结束后30秒消失
@export var exist_time:float = 30

## 当前冰道行
var lane :int
## 当前行植物格子(植物格子顺序为从左到右)
var curr_lane_plant_cells : Array
## 植物格子到达的位置即算覆盖该格子(覆盖格子1/3的位置)
var x_plant_cell_target:Array[float]
## 当前覆盖的格子索引(从size()到0,倒序)
var curr_i_plant_cell := 0
## 冰道最左边x值
var left_x:float

## 冰道消失信号
signal signal_ice_road_disappear

## 冰道初始化,生产冰道的节点调用
func ice_road_init(curr_lane:int):
	self.lane = curr_lane
	self.curr_lane_plant_cells = Global.main_game.plant_cell_manager.all_plant_cells[lane]
	for plant_cell:PlantCell in self.curr_lane_plant_cells:
		x_plant_cell_target.append(plant_cell.global_position.x + plant_cell.size.x*2/3)

	## 从地图右边出现
	if global_position.x >= x_plant_cell_target[-1]:
		curr_i_plant_cell = x_plant_cell_target.size()
	else:
		## 从左到右,判断冰道位置
		for i in range(x_plant_cell_target.size()):
			if global_position.x < x_plant_cell_target[i]:
				curr_i_plant_cell = i + 1
				break
	## 更新冰道数据
	Global.main_game.zombie_manager.all_ice_roads[lane].append(self)

## 冰道每次更新, 将冰冻的scale.x设置为-1，右边缘不变，修改大小即可
func expand_size(expand_x:float):
	texture_rect.size.x += expand_x
	left_x = texture_rect.global_position.x - texture_rect.size.x
	## 冰道已经覆盖所有植物格子
	if curr_i_plant_cell == 0:
		return

	## 覆盖到新的plant_cell时
	if left_x < x_plant_cell_target[curr_i_plant_cell - 1]:
		curr_i_plant_cell -= 1
		var plant_cell:PlantCell = curr_lane_plant_cells[curr_i_plant_cell]
		plant_cell.add_new_ice_road(self)

## 开始计算消失计时器
func start_disappear_timer():
	ice_road_disappear_timer.wait_time = exist_time
	ice_road_disappear_timer.start()

## 冰道消失
func _on_ice_road_disappear_timer_timeout() -> void:
	ice_road_disappear()

func ice_road_disappear():
	Global.main_game.zombie_manager.all_ice_roads[lane].erase(self)
	signal_ice_road_disappear.emit()
	queue_free()
