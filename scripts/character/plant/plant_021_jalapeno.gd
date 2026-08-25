extends Plant000Base
class_name Plant021Jalapeno

@onready var bomb_component: BombComponentBase = %BombComponent

## 亡语
func death_language():
	## 火爆辣椒: 强力全屏震动
	if is_instance_valid(Global.main_game) and is_instance_valid(Global.main_game.camera_2d):
		Global.main_game.camera_2d.shake(8.0, 0.5)
	bomb_component.judge_death_bomb()
