extends ItemPlantCellBase
class_name GardenGlove

var is_have_plant := false
@onready var plant_cell_garden: PlantCellGarden = $PlantCellGarden
var choosed_plant_data := {}
## 当前手套目标植物格子
var target_plant_cell:PlantCellGarden


signal signal_glove_activate
signal signal_glove_deactivate

func _input(event):
	if is_activate :
		## 如果是 点击鼠标左键
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			## 安卓端等待两帧移动到对应的位置
			is_mouse_button_pressed_wait = true
			global_position = get_global_mouse_position()
			body.visible = false
			await get_tree().physics_frame
			await get_tree().physics_frame
			## 当前手套有植物格子，但还未选择植物
			if curr_plant_cell and curr_plant_cell.plant_in_cell and not is_have_plant:
				use_it()
			## 已经选择植物,且当前格子有植物虚影
			elif target_plant_cell and target_plant_cell.is_shadow and is_have_plant:
				lay_plant()
			else:
				deactivate_it()
			is_mouse_button_pressed_wait = false
		## 如果是鼠标右键
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			deactivate_it()

func activete_it():
	super.activete_it()
	body.visible = true
	signal_glove_activate.emit()


## 使用手套
func use_it():
	is_have_plant = true
	body.visible = false
	choosed_plant_data = curr_plant_cell.get_curr_plant()
	curr_plant_cell.glove = self
	plant_cell_garden.init_curr_plant_cell(choosed_plant_data)


## 更新手套植物，当植物本体发芽随机新植物时
func update_shadow_plant_cell(curr_plant_cell_data:Dictionary):
	plant_cell_garden.free_curr_plant()
	choosed_plant_data = curr_plant_cell_data
	plant_cell_garden.init_curr_plant_cell(curr_plant_cell_data)
	## 如果当前有植物虚影
	if target_plant_cell and target_plant_cell.is_shadow:
		target_plant_cell.free_curr_plant()
		target_plant_cell.init_curr_plant_cell_shadow(choosed_plant_data)


## 放置植物
func lay_plant():
	curr_plant_cell.glove = null
	choosed_plant_data = curr_plant_cell.get_curr_plant()
	target_plant_cell.shadow_fixed()
	curr_plant_cell.free_curr_plant()
	target_plant_cell = null
	deactivate_it()


func deactivate_it(is_play_sfx:=true):

	signal_glove_deactivate.emit()
	glove_free_hand_plant()
	## 当前植物格子还有植物，说明为右键取消
	if curr_plant_cell and curr_plant_cell.plant_in_cell:
		#curr_plant_cell.free_curr_plant()
		curr_plant_cell.plant_cell_color_restore()

	if target_plant_cell:
		target_plant_cell.shadow_fixed()
		target_plant_cell.free_curr_plant()
		target_plant_cell = null
	choosed_plant_data = {}

	super(is_play_sfx)

func glove_free_hand_plant():
	if is_have_plant:
		is_have_plant = false
		plant_cell_garden.free_curr_plant()

## 检测到进入的植物格子
func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_have_plant:
		super._on_area_2d_area_entered(area)
	else:
		var new_plant_cell:PlantCellGarden = area.get_parent()
		if new_plant_cell != curr_plant_cell and new_plant_cell.plant_in_cell == null:
			target_plant_cell = new_plant_cell
			target_plant_cell.init_curr_plant_cell_shadow(choosed_plant_data)

## 检测到出去的植物格子
func _on_area_2d_area_exited(area: Area2D) -> void:
	if not is_have_plant:
		super._on_area_2d_area_exited(area)
	else:
		var new_plant_cell:PlantCellGarden = area.get_parent()
		if target_plant_cell == new_plant_cell:
			target_plant_cell.shadow_fixed()
			target_plant_cell.free_curr_plant()
			target_plant_cell = null

