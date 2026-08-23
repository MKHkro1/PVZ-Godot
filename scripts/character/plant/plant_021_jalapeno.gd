extends Plant000Base
class_name Plant021Jalapeno

@onready var bomb_component: BombComponentBase = %BombComponent

## 亡语
func death_language():
	bomb_component.judge_death_bomb()
