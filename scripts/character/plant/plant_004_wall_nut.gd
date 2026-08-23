extends Plant000Base
class_name Plant004WallNut

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent

func ready_norm_signal_connect():
	super()
	## 连接信号
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)
