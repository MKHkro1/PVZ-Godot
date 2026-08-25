extends Plant000Base
class_name Plant016DoomShroom

@onready var bomb_component: BombComponentBase = %BombComponent

func ready_norm_signal_connect():
	super()
	bomb_component.signal_bomb_once.connect(plant_cell.create_crater)


	## 亡语
func death_language():
	## 末日蘑菇: 超强屏幕震动
	if is_instance_valid(Global.main_game) and is_instance_valid(Global.main_game.camera_2d):
		Global.main_game.camera_2d.shake(10.0, 0.6)
	bomb_component.judge_death_bomb()
