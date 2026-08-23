extends Control
class_name LevelInfo

@onready var round_label: Label = $RoundLabel

## 设置轮次
func set_round(curr_round:int):
	round_label.text = "当前为第" + str(curr_round) + "轮"
	round_label.visible = true
