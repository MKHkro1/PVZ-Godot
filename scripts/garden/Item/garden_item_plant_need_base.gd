extends ItemPlantCellBase
class_name ItemPlantNeedBase

## 当前物品对应的植物需要的物品
@export var plant_need_item :GardenManager.E_NeedItem
@onready var anim_lib: AnimationPlayer = $AnimLib
## 单个植物道具位置修正，黄金水壶无位置修正
@export var correct_position :Vector2

@export var sfx_string_name:StringName

## 黄金水壶重写该函数
func use_it():
	play_plant_need_item_sfx()
	var clone_item_plant_cell = curr_plant_cell
	var clone:ItemBase = clone_self()

	## 修改道具位置
	clone.global_position = clone_item_plant_cell.global_position + correct_position

	deactivate_it(false)

	clone.visible = true
	clone.anim_lib.play("ALL_ANIMS")
	await clone.anim_lib.animation_finished
	## 是否跳到下一页
	if clone_item_plant_cell and is_instance_valid(clone_item_plant_cell):
		clone_item_plant_cell.use_item_in_this(self)

	clone.queue_free()

func play_plant_need_item_sfx():
	await get_tree().create_timer(0.2).timeout
	SoundManager.play_other_SFX(sfx_string_name)
