extends BombComponentBase
class_name BombComponentJalapeno

var owner_plant:Plant000Base

func _ready() -> void:
	owner_plant = owner as Plant000Base

## 爆炸特效\冰道\梯子
func _start_bomb_fx():
	EventBus.push_event("jalapeno_bomb_effect", [owner_plant.row_col.x])

## 炸死所有敌人
func _bomb_all_enemy():
	EventBus.push_event("jalapeno_bomb_lane_zombie", [owner_plant.row_col.x])
	## 销毁当前行道具[冰道和梯子]
	EventBus.push_event("jalapeno_bomb_item_lane", [owner_plant.row_col.x])

