extends AttackComponentBulletBase
class_name AttackComponentBulletCactus

var is_have_zombie_in_sky := false

signal signal_is_have_zombie_in_sky(value:bool)

func _ready() -> void:
	super()
	## 检测到空中敌人时，将信号传递给角色本体
	detect_component.signal_is_have_zombie_in_sky.connect(update_is_have_zombie_in_sky)

## 更新是否有空中敌人，将信号传递给角色本体
func update_is_have_zombie_in_sky(value:bool):
	is_have_zombie_in_sky = value
	if value:
		can_attack_zombie_status = 8
	else:
		can_attack_zombie_status = 1
	signal_is_have_zombie_in_sky.emit(value)

## 攻击间隔后触发执行攻击
func _on_bullet_attack_cd_timer_timeout() -> void:
	if is_have_zombie_in_sky:
		animation_tree.set("parameters/StateMachine/BlendTree 2/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		animation_tree.set("parameters/StateMachine/BlendTree/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func set_cancel_attack():
	animation_tree.set("parameters/StateMachine/BlendTree/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
	animation_tree.set("parameters/StateMachine/BlendTree 2/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
