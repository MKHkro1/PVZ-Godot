extends Resource
class_name ResourceSaveGameMainGame

@export var curr_game_round:int

@export_group("植物数据")
## 植物数据
@export var plant_cell_manager_data:ResourceSaveGamePlantCellManager
@export_group("僵尸数据")
## 当前最大波次,每轮增加该值
@export var curr_max_wave :int = -1
## 当前波次
@export var curr_wave :int = -1

@export_group("天降阳光数据")
## 天降阳光已生产阳光数量
@export var day_sun_curr_sun_sum_value :int = 0

@export_group("卡槽数据")
@export var card_manager_data :Dictionary = {}

@export_group("小推车数据")
@export var lawn_mover_manager_data:Dictionary = {}
