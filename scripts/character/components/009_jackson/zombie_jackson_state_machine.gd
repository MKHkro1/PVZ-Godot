extends Node
## 舞王状态机,与舞王相关节点高度耦合，就这一个用状态机的，不想写太麻烦的代码
class_name JacksonStateMachine

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var charred_component: CharredComponent = %CharredComponent
@onready var attack_component: AttackComponentZombieNorm = %AttackComponent
@onready var move_component: MoveComponent = %MoveComponent
@onready var node_drop: Node2D = %NodeDrop

@onready var zombie_009_jackson: Zombie009Jackson = $".."
var jackson_manager: JacksonManager

## 舞王动画状态
enum E_JacksonStatus{
	Enter,	## 入场状态
	Point,	## 召唤僵尸状态
	Norm,	## 正常移动、跳舞状态（该状态下舞王管理器管理）
	Attack,	## 攻击状态
	Death,	## 死亡状态
}

@export var curr_jackson_status = E_JacksonStatus.Norm

## 初始化状态机，舞王根节点调用
func init_state(init_status:E_JacksonStatus):
	curr_jackson_status = init_status
	animation_player.set_blend_time('armraise', 'walk', 0.2)
	if init_status == E_JacksonStatus.Enter:
		## 非攻击状态下，攻击力为0
		attack_component.update_attack_value(0, AttackComponentZombieNorm.E_AttackValueFactor.JacksonEnter)
		## 方向
		zombie_009_jackson.update_direction_x_body(-1)
	## 非召唤伴舞初始化为Norm状态
	else:
		jackson_manager.start_anim()
		allow_dance()
	## 舞王
	if not owner is Zombie010Dancer:
		for i in range(zombie_009_jackson.num_moon_walk):
			## 入场状态（还未死亡）
			if curr_jackson_status == E_JacksonStatus.Enter:
				animation_player.play("moonwalk")
				animation_player.seek(0)
				await animation_player.animation_finished

		## 召唤僵尸动画
		change_jackson_anim_status(curr_jackson_status, E_JacksonStatus.Point)
		jackson_manager.start_anim()
	else:
		if init_status == E_JacksonStatus.Enter:
			animation_player.play("pose_be_call")		## 方向
		zombie_009_jackson.update_direction_x_body(1)

## 舞王动画状态改变
func change_jackson_anim_status(ori_value:E_JacksonStatus, new_value:E_JacksonStatus):
	move_component._walking_end()
	curr_jackson_status = new_value
	match ori_value:
		## 舞王入场状态
		E_JacksonStatus.Enter:
			enter_status(new_value)

		E_JacksonStatus.Point, E_JacksonStatus.Norm:
			enter_status(new_value)

		E_JacksonStatus.Attack:
			## 非攻击状态，攻击值为0
			attack_component.update_attack_value(0, AttackComponentZombieNorm.E_AttackValueFactor.JacksonEnter)
			enter_status(new_value)

		E_JacksonStatus.Death:
			#print("僵尸原始为死亡状态")
			return

## 进入新状态
func enter_status(new_value:E_JacksonStatus):
	match new_value:
		E_JacksonStatus.Point:
			curr_jackson_status = new_value
			## 召唤僵尸动画
			animation_player.play("point")
			## 控制舞王方向
			#zombie_009_jackson.body.scale = Vector2(1,1)
			zombie_009_jackson.body.scale = Vector2(
				abs(zombie_009_jackson.body.scale.x) * sign(1),
				abs(zombie_009_jackson.body.scale.y) * sign(1)
			)
			await animation_player.animation_finished
			change_jackson_anim_status(curr_jackson_status, judge_curr_status())
		E_JacksonStatus.Norm:
			allow_dance()

		## 非攻击状态，攻击值为0
		E_JacksonStatus.Attack:
			## 修改攻击力为原始值
			attack_component.update_attack_value(1, AttackComponentZombieNorm.E_AttackValueFactor.JacksonEnter)
			animation_player.play(&"eat", -1, 2)
			#zombie_009_jackson.body.scale = Vector2(1,1)
			zombie_009_jackson.body.scale = Vector2(
				abs(zombie_009_jackson.body.scale.x) * sign(1),
				abs(zombie_009_jackson.body.scale.y) * sign(1)
			)
		E_JacksonStatus.Death:
			animation_player.play(&"death", 0.2)

## 判断当前状态(召唤僵尸动画、入场结束后调用)
func judge_curr_status() -> JacksonStateMachine.E_JacksonStatus:
	if zombie_009_jackson.is_death:
		return JacksonStateMachine.E_JacksonStatus.Death
	if zombie_009_jackson.is_attack:
		return JacksonStateMachine.E_JacksonStatus.Attack

	return JacksonStateMachine.E_JacksonStatus.Norm

## 从特殊状态（舞王入场、攻击）修改跟随跳舞
func allow_dance():
	var anim_info = jackson_manager.get_current_animation_info()
	anim_play(anim_info['name'], anim_info['curr_scale'], anim_info['current_time'], anim_info['speed'], true)

## 舞王管理器管理动画播放
## Norm状态更新
func anim_play(anim_name, curr_scale, start_time, _speed, is_follow:=false):
	if curr_jackson_status == E_JacksonStatus.Norm:
		move_component._walking_end()
		## 如果是唤伴舞动画,入场标志已结束使用，这里重复使用一下
		if anim_name == "point":
			change_jackson_anim_status(curr_jackson_status, E_JacksonStatus.Point)
			return
		## 最后一次举手需要举起，舞王管理器重新创建了新动画控制播放时间
		if anim_name == "armraise_end":
			anim_name = "armraise"

		if is_follow:
			animation_player.play_section(anim_name, start_time, -1, 0.2)
		else:
			animation_player.play(anim_name)
			animation_player.seek(0)

		## 控制舞王方向
		zombie_009_jackson.update_direction_x_body(curr_scale.x)

		if anim_name == "walk":
			#await get_tree().create_timer(0.1).timeout
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().process_frame
			move_component._walking_start()

