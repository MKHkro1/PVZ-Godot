extends Plant000Base
class_name Plant024TallNut

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent

func ready_norm_signal_connect():
	super()
	## 连接信号
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)

func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie:Zombie000Base = area.owner
	if zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)

