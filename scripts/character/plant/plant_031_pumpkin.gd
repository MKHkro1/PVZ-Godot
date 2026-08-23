extends Plant000Base
class_name Plant031Pumpkin

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent
@onready var pumpkin_back: Sprite2D = $Body/BodyCorrect/Pumpkin_back

func ready_norm():
	super()
	pumpkin_back.z_index -= 1


func ready_norm_signal_connect():
	super()
	## 血量状态变化组件
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)
