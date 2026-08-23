extends Zombie000Base
class_name Zombie006Paper

@export_group("动画状态")
@export var is_gasp:bool = false

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	hp_component = hp_component as HpComponentZombie
	hp_component.signal_armor2_death.connect(drop_paper)
	## 连接修改每分钟攻击值
	hp_component.signal_armor2_death.connect(attack_component.update_attack_value.bind(2, attack_component.E_AttackValueFactor.Speed))

## 报纸掉落
func drop_paper():
	is_gasp = true
	SoundManager.play_character_SFX("Rarrgh")
	SoundManager.play_character_SFX("Rip")
