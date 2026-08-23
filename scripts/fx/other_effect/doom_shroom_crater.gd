extends Node2D
class_name DoomShroomCrater

#陆地白天、黑夜
#泳池白天、黑夜
#屋顶中间、左边

## 当前坑洞
var curr_crater:Node2D
var curr_crater_0:Sprite2D
var curr_crater_1:Sprite2D
@export var creater_time := 180.0

func init_crater(cell_type:int, plant_cell:PlantCell=null):
	curr_crater = get_child(cell_type)
	curr_crater.visible = true
	curr_crater_0 = curr_crater.get_child(0)
	curr_crater_1 = curr_crater.get_child(1)
	curr_crater_0.visible = true
	await get_tree().create_timer(creater_time/2).timeout
	curr_crater_0.visible = false
	curr_crater_1.visible = true
	await get_tree().create_timer(creater_time/2).timeout

	curr_crater_1.visible = false
	plant_cell.delete_crater_update_plant_cell_data()


	queue_free()
