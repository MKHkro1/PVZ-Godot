extends ItemPlantCellBase
class_name WheelBarrow

@onready var plant_cell_garden_in_button: PlantCellGarden = $"../../PanelUI/HBoxContainer/GardenItemButton8/ItemTexture/PlantCellGarden"

var is_have_plant := false
@onready var plant_cell_garden: PlantCellGarden = $PlantCellGarden
#@onready var body: Node2D = $Body
var choosed_plant_data := {}

var garden_manager:GardenManager

signal signal_wheel_barrow_activate
signal signal_wheel_barrow_deactivate

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
			## 当前有植物格子，但还未选择植物
			if curr_plant_cell and curr_plant_cell.plant_in_cell and not is_have_plant:
				use_it()
			## 已经选择植物,且当前格子有植物虚影
			elif curr_plant_cell and curr_plant_cell.is_shadow and is_have_plant:
				lay_plant()
			else:
				deactivate_it()
			is_mouse_button_pressed_wait = false
		## 如果是鼠标右键
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			deactivate_it()


## 鼠标点击ui图标按钮，激活该物品
func activete_it():
	if not garden_manager:
		garden_manager = get_tree().current_scene

	## 如果存在植物并且植物种植类型为陆地
	if is_have_plant:
		var curr_plant_condition:int = choosed_plant_data["curr_plant_condition"]
		## 植物种植类型为陆地并且为水族馆场景
		if curr_plant_condition & 2 and garden_manager.curr_bg_type == GardenManager.E_GardenBgType.Aquarium:

			print("当前植物不可以种在水中")
			var reminder_info :ReminderInformation =  SceneRegistry.REMINDER_INFORMATION.instantiate()

			get_tree().current_scene.add_child(reminder_info)
			reminder_info._init_info(["在这你只能种水生植物，这是在水下！"])

			deactivate_it()
			return
	signal_wheel_barrow_activate.emit()
	## 如果可以种植,激活
	super()

func deactivate_it(is_play_sfx:= true):
	signal_wheel_barrow_deactivate.emit()
	## 当前植物格子还有植物虛影，说明为右键取消
	if curr_plant_cell and curr_plant_cell.is_shadow :
		curr_plant_cell.plant_cell_color_restore()
	super.deactivate_it(is_play_sfx)


## 从存档初始化独轮车
func init_from_data(curr_plant_data:Dictionary):
	if curr_plant_data:
		is_have_plant = true
		choosed_plant_data = curr_plant_data
		plant_cell_garden.init_curr_plant_cell(choosed_plant_data)
		plant_cell_garden_in_button.init_curr_plant_cell(choosed_plant_data)
		curr_plant_cell = null

## 使用独轮车
func use_it():
	is_have_plant = true
	choosed_plant_data = curr_plant_cell.get_curr_plant()
	plant_cell_garden.init_curr_plant_cell(choosed_plant_data)
	plant_cell_garden_in_button.init_curr_plant_cell(choosed_plant_data)
	curr_plant_cell.free_curr_plant()
	curr_plant_cell = null
	deactivate_it()

func lay_plant():
	_lay_success()

func _lay_success():
	is_have_plant = false
	plant_cell_garden.free_curr_plant()
	curr_plant_cell.shadow_fixed()
	plant_cell_garden_in_button.free_curr_plant()
	choosed_plant_data = {}
	deactivate_it()

func _lay_fail():
	deactivate_it()
	curr_plant_cell.shadow_fixed()
	curr_plant_cell.free_curr_plant()

## 检测到进入的植物格子
func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_have_plant:
		super._on_area_2d_area_entered(area)
	else:
		var new_plant_cell:PlantCellGarden = area.owner
		if new_plant_cell.plant_in_cell == null:
			#print("进入格子初始化格子虚影")
			curr_plant_cell = new_plant_cell
			curr_plant_cell.init_curr_plant_cell_shadow(choosed_plant_data)


## 检测到出去的植物格子
func _on_area_2d_area_exited(area: Area2D) -> void:
	if not is_have_plant:
		super._on_area_2d_area_exited(area)
	else:
		var new_plant_cell:PlantCellGarden = area.owner
		if curr_plant_cell == new_plant_cell:
			curr_plant_cell.shadow_fixed()
			curr_plant_cell.free_curr_plant()
			curr_plant_cell = null


