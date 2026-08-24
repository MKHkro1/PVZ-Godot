extends Node
## 手持管理器，铲子与手套
class_name HM_Item

@onready var ui_shovel: UIShovel = %UIShovel
@onready var ui_glove = %UIGlove
@onready var real_shovel: RealShovel = %RealShovel
@onready var real_glove: RealGlove = %RealGlove
@onready var temporary_character: Node2D = %TemporaryCharacter

var _glove_carry_root: Node2D

## 手持道具状态
enum E_HmItemStatus {
	Null,
	Shovel,
	Glove,
}
var curr_hm_item_status := E_HmItemStatus.Null

## 当前鼠标所在格子
var curr_plant_cell: PlantCell

## 铲子预选植物
var plant_be_shovel_look: Plant000Base
var curr_shovel_look_plant_num: int = 0

## 手套搬运
var _glove_carried_plant: Plant000Base
var _glove_carried_stack: Array[Plant000Base] = []
var _glove_source_cell: PlantCell
var _glove_carry_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	call_deferred("_init_glove_carry_root")


func _init_glove_carry_root() -> void:
	if is_instance_valid(Global.main_game):
		_glove_carry_root = Global.main_game.get_node("PlantCellsRoot") as Node2D


func _get_glove_carry_root() -> Node2D:
	if is_instance_valid(_glove_carry_root):
		return _glove_carry_root
	if is_instance_valid(Global.main_game):
		_glove_carry_root = Global.main_game.get_node("PlantCellsRoot") as Node2D
	return _glove_carry_root


func click_shovel() -> void:
	curr_hm_item_status = E_HmItemStatus.Shovel
	real_shovel.change_is_using(true)


func click_glove() -> void:
	curr_hm_item_status = E_HmItemStatus.Glove
	real_glove.change_is_using(true)


func item_process() -> void:
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			_shovel_item_process()
		E_HmItemStatus.Glove:
			_glove_item_process()


func _shovel_item_process() -> void:
	if plant_be_shovel_look and curr_shovel_look_plant_num >= 2:
		var new_plant_be_shovel_look = curr_plant_cell.return_plant_be_shovel_look()
		if new_plant_be_shovel_look != plant_be_shovel_look:
			plant_be_shovel_look.be_shovel_look_end()
			plant_be_shovel_look = new_plant_be_shovel_look
			plant_be_shovel_look.be_shovel_look()


func _glove_item_process() -> void:
	if not is_instance_valid(_glove_carried_plant):
		return
	var carry_root := _get_glove_carry_root()
	if not is_instance_valid(carry_root):
		return
	var mouse_pos := carry_root.get_global_mouse_position()
	_glove_carried_plant.global_position = mouse_pos + _glove_carry_offset
	for stacked in _glove_carried_stack:
		if not is_instance_valid(stacked):
			continue
		var offset: Vector2 = stacked.get_meta("glove_offset", Vector2.ZERO)
		stacked.global_position = _glove_carried_plant.global_position + offset


func mouse_enter(plant_cell: PlantCell) -> void:
	curr_plant_cell = plant_cell
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			curr_shovel_look_plant_num = plant_cell.get_curr_plant_num()
			if curr_shovel_look_plant_num >= 1:
				plant_be_shovel_look = plant_cell.return_plant_be_shovel_look()
				plant_be_shovel_look.be_shovel_look()
		E_HmItemStatus.Glove:
			if is_instance_valid(_glove_carried_plant):
				pass
			else:
				curr_shovel_look_plant_num = plant_cell.get_curr_plant_num()
				if curr_shovel_look_plant_num >= 1:
					var plant: Plant000Base = plant_cell.return_plant_for_glove()
					if _can_glove_pick(plant):
						plant_be_shovel_look = plant
						plant_be_shovel_look.be_shovel_look()


@warning_ignore("unused_parameter")
func mouse_exit(plant_cell: PlantCell) -> void:
	curr_plant_cell = null
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			if plant_be_shovel_look:
				plant_be_shovel_look.be_shovel_look_end()
				plant_be_shovel_look = null
				curr_shovel_look_plant_num = 0
		E_HmItemStatus.Glove:
			if plant_be_shovel_look:
				plant_be_shovel_look.be_shovel_look_end()
				plant_be_shovel_look = null
				curr_shovel_look_plant_num = 0


@warning_ignore("unused_parameter")
func click_cell(plant_cell: PlantCell) -> bool:
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			if plant_be_shovel_look:
				SoundManager.play_other_SFX("plant2")
				plant_be_shovel_look.be_shovel_kill()
			return true
		E_HmItemStatus.Glove:
			return _glove_click_cell(plant_cell)
	return true


func _glove_click_cell(plant_cell: PlantCell) -> bool:
	if is_instance_valid(_glove_carried_plant):
		if _glove_try_place(plant_cell):
			ui_glove.start_cooldown()
			return true
		SoundManager.play_other_SFX("buzzer")
		return false
	return _glove_try_pick(plant_cell)


func _glove_try_pick(plant_cell: PlantCell) -> bool:
	var plant: Plant000Base = plant_cell.return_plant_for_glove()
	if not _can_glove_pick(plant):
		SoundManager.play_other_SFX("buzzer")
		return false
	## 玉米加农炮占两格, 以后轮格子为准
	if plant is Plant048CobCannon and is_instance_valid(plant.plant_cell):
		plant_cell = plant.plant_cell
	SoundManager.play_other_SFX("seedlift")
	var detach_cell: PlantCell = plant_cell
	if plant is Plant048CobCannon and is_instance_valid(plant.plant_cell):
		detach_cell = plant.plant_cell
	_glove_source_cell = detach_cell
	_glove_carried_plant = plant
	if plant_be_shovel_look == plant:
		plant_be_shovel_look.be_shovel_look_end()
		plant_be_shovel_look = null
	_glove_carried_stack = detach_cell.glove_detach_plant(plant)
	_glove_begin_carry(plant)
	return false


func _glove_begin_carry(plant: Plant000Base) -> void:
	plant.be_shovel_look_end()
	var carry_root := _get_glove_carry_root()
	if not is_instance_valid(carry_root):
		return
	var carry_global := plant.global_position
	for stacked in _glove_carried_stack:
		if is_instance_valid(stacked):
			stacked.set_meta("glove_offset", stacked.global_position - carry_global)
	if plant.get_parent() != carry_root:
		plant.reparent(carry_root, true)
	plant.global_position = carry_global
	plant.z_index = 300
	var mouse_pos := carry_root.get_global_mouse_position()
	_glove_carry_offset = carry_global - mouse_pos
	for stacked in _glove_carried_stack:
		if not is_instance_valid(stacked):
			continue
		if stacked.get_parent() != carry_root:
			stacked.reparent(carry_root, true)
		stacked.global_position = plant.global_position + stacked.get_meta("glove_offset", Vector2.ZERO)
		stacked.z_index = 300


func _glove_try_place(target_cell: PlantCell) -> bool:
	if not is_instance_valid(_glove_carried_plant):
		return false
	if target_cell == _glove_source_cell:
		_glove_cancel_carry(true)
		real_glove.change_is_using(false)
		curr_hm_item_status = E_HmItemStatus.Null
		ui_glove.ui_glove_appear()
		return true
	if not _glove_can_place_at(target_cell):
		return false
	SoundManager.play_other_SFX("plant2")
	var plant := _glove_carried_plant
	var source := _glove_source_cell
	var stack := _glove_carried_stack
	if not target_cell.glove_attach_plant(plant, stack):
		if is_instance_valid(source):
			source.glove_attach_plant(plant, stack)
		_glove_carried_plant = null
		_glove_source_cell = null
		_glove_carried_stack = []
		return false
	_glove_carried_plant = null
	_glove_source_cell = null
	_glove_carried_stack = []
	real_glove.change_is_using(false)
	curr_hm_item_status = E_HmItemStatus.Null
	return true


func _glove_cancel_carry(play_sfx: bool = false) -> bool:
	if not is_instance_valid(_glove_carried_plant):
		_glove_carried_stack = []
		return true
	var plant := _glove_carried_plant
	var source := _glove_source_cell
	var stack := _glove_carried_stack
	_glove_carried_plant = null
	_glove_source_cell = null
	_glove_carried_stack = []
	if is_instance_valid(source):
		source.glove_attach_plant(plant, stack)
	if play_sfx:
		SoundManager.play_other_SFX("tap2")
	return true


func _glove_can_place_at(target_cell: PlantCell) -> bool:
	if not is_instance_valid(_glove_carried_plant):
		return false
	return target_cell.glove_can_attach_plant(_glove_carried_plant)


func _can_glove_pick(plant: Plant000Base) -> bool:
	return is_instance_valid(plant)


func exit_status() -> void:
	match curr_hm_item_status:
		E_HmItemStatus.Shovel:
			if plant_be_shovel_look:
				plant_be_shovel_look.be_shovel_look_end()
			plant_be_shovel_look = null
			curr_shovel_look_plant_num = 0
			real_shovel.change_is_using(false)
			ui_shovel.ui_shovel_appear()
		E_HmItemStatus.Glove:
			_glove_cancel_carry()
			if plant_be_shovel_look:
				plant_be_shovel_look.be_shovel_look_end()
			plant_be_shovel_look = null
			curr_shovel_look_plant_num = 0
			real_glove.change_is_using(false)
			ui_glove.ui_glove_appear()
	curr_hm_item_status = E_HmItemStatus.Null
