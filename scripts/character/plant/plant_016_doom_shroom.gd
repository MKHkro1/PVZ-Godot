extends Plant000Base
class_name Plant016DoomShroom

@onready var bomb_component: BombComponentBase = %BombComponent

func ready_norm_signal_connect():
	super()
	bomb_component.signal_bomb_once.connect(plant_cell.create_crater)


## 亡语
func death_language():
	bomb_component.judge_death_bomb()
