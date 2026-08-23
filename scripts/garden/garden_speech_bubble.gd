extends Node2D
class_name GardenSpeehBubble

@onready var garden_need_items_bubble={
	GardenManager.E_NeedItem.Null:null,
	GardenManager.E_NeedItem.WateringCan:$Plantspeechbubble/Waterdrop,			## 水壶
	GardenManager.E_NeedItem.Fertilizer:$Plantspeechbubble/ZenNeedIcons,		## 肥料
	GardenManager.E_NeedItem.BugSpray:$Plantspeechbubble/ZenNeedIcons2,			## 杀虫剂
	GardenManager.E_NeedItem.Phonograph:$Plantspeechbubble/ZenNeedIcons3,		## 留声机
}
@onready var plantspeechbubble: Sprite2D = $Plantspeechbubble

@export var curr_plant_need_item :GardenManager.E_NeedItem

func _ready() -> void:
	for plant_need_item_bubble in garden_need_items_bubble.values():
		if plant_need_item_bubble != null:
			plant_need_item_bubble.visible = false
	plantspeechbubble.visible = false

## 改变当前植物需求气泡
func change_plant_need_item(new_plant_need_item :GardenManager.E_NeedItem):
	if garden_need_items_bubble[curr_plant_need_item] != null:
		garden_need_items_bubble[curr_plant_need_item].hide()

	curr_plant_need_item = new_plant_need_item

	if garden_need_items_bubble[new_plant_need_item] != null:
		plantspeechbubble.visible = true
		garden_need_items_bubble[new_plant_need_item].visible = true

		scale = Vector2(1,1)/get_parent().scale

	else:
		plantspeechbubble.visible = false

