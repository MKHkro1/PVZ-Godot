extends Sprite2D
class_name GardenBgPage

@export var garden_bg_type:GardenManager.E_GardenBgType
var curr_bg_page := 0
var curr_bg_plant_cell_num :int
## 所有植物格子的父节点
@onready var garden_plant_cell_all: Node2D = $GardenPlantCellAll
## 当前所有的植物格子
var all_plant_cells :Array

var garden_manager :GardenManager


func _ready() -> void:
	garden_manager = get_tree().current_scene
	all_plant_cells = garden_plant_cell_all.get_children()
	if garden_bg_type == GardenManager.E_GardenBgType.Aquarium:
		for i in range(all_plant_cells.size()):
			var plant_cell_garden_aquarium:PlantCellGardenAquarium = all_plant_cells[i]
			garden_manager.wheel_barrow.signal_wheel_barrow_activate.connect(plant_cell_garden_aquarium.wheel_barrow_activate)
			garden_manager.wheel_barrow.signal_wheel_barrow_deactivate.connect(plant_cell_garden_aquarium.wheel_barrow_deactivate)

			garden_manager.glove.signal_glove_activate.connect(plant_cell_garden_aquarium.wheel_barrow_activate)
			garden_manager.glove.signal_glove_deactivate.connect(plant_cell_garden_aquarium.wheel_barrow_deactivate)


## 初始化当前背景页，花园管理器调用调用,返回当前页的空闲植物格子列表
func init_curr_gb_page(bg_page_data:Dictionary, page:int) -> Array[Node]:

	curr_bg_page = page
	var empty_plant_cells :Array[Node] = []
	if bg_page_data:
		for i in range(all_plant_cells.size()):
			var plant_data = bg_page_data.get("第"+str(i)+"个植物格子", {})
			var plant_cell_garden:PlantCellGarden = all_plant_cells[i]
			## 如果该植物格子有植物
			if plant_data:
				plant_cell_garden.init_curr_plant_cell(plant_data, garden_bg_type, curr_bg_page)
			else:
				plant_cell_garden.init_curr_plant_cell({}, garden_bg_type, curr_bg_page)
				empty_plant_cells.append(plant_cell_garden)

	else:
		for i in range(all_plant_cells.size()):
			var plant_cell_garden:PlantCellGarden = all_plant_cells[i]
			## 如果该植物格子有植物
			plant_cell_garden.init_curr_plant_cell({}, garden_bg_type, curr_bg_page)

		empty_plant_cells = all_plant_cells

	return empty_plant_cells


## 初始化添加新植物
func init_add_plant(add_plant_num:int):
	for i in range(add_plant_num):
		pass
