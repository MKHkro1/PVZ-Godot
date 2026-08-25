extends Control
class_name FlagProgressBarFlag

@onready var flag: TextureRect = $Flag

## 升旗
func up_flag():
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(flag, "position:y", -10.0, 0.3)

func down_flag():
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(flag, "position:y", 0.0, 0.3)
