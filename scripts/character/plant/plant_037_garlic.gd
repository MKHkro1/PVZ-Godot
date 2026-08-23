extends Plant000Base
class_name Plant037Garlic

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent

func ready_norm_signal_connect():
	super()
	## 连接信号
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)

## 被僵尸啃食一次特殊效果,魅惑\大蒜
func _be_zombie_eat_once_special(attack_zombie:Zombie000Base):
	attack_zombie.update_lane_on_eat_garlic()
