extends Control
class_name FlagProgressBarFlag

@onready var flag: TextureRect = $Flag

## 升旗
func up_flag():
	flag.position.y = -10

func down_flag():
	flag.position.y = 0

