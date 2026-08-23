extends Plant000Base
class_name Plant027Cactus

@export_group("动画状态")
@export var is_rise:= false
@onready var attack_component: AttackComponentBulletCactus = $AttackComponent


## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	attack_component.signal_is_have_zombie_in_sky.connect(func(value):is_rise=value)
	signal_update_speed.connect(attack_component.owner_update_speed)

## 起落动画开始，设置不能攻击
func anim_rise_start():
	attack_component.update_is_attack_factors(false, AttackComponentBase.E_IsAttackFactors.Anim)

## 起落动画结束，设置可以攻击
func anim_rise_end():
	attack_component.update_is_attack_factors(true, AttackComponentBase.E_IsAttackFactors.Anim)

