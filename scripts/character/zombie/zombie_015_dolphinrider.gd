extends Zombie000Base
class_name Zombie015Dolphinrider


@onready var jump_component: JumpComponent = $JumpComponent
@onready var detect_component: DetectComponent = %DetectComponent

@export var is_jumping := false
var is_jump_stop := false
var jump_stop_postion :Vector2

## 是否骑着海豚(出泳池时,骑海豚时切换动画移动本体位置\死亡时判断(没有对应死亡动画))
var is_ride := true

func ready_norm() -> void:
	super()
	detect_component.disable_component(ComponentNormBase.E_IsEnableFactor.Jump)

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	jump_component.signal_jump_start.connect(jump_start)
	jump_component.signal_jump_end.connect(jump_end)
	jump_component.signal_jump_end_end.connect(jump_end_end)

	jump_component.signal_jump_end_end.connect(detect_component.enable_component.bind(ComponentNormBase.E_IsEnableFactor.Jump))
	## 跳跃对移动影响
	jump_component.signal_jump_start.connect(move_component.update_move_factor.bind(true, MoveComponent.E_MoveFactor.IsJump))
	jump_component.signal_jump_end_end.connect(move_component.update_move_factor.bind(false, MoveComponent.E_MoveFactor.IsJump))


## 开始跳跃,跳跃组件信号发射调用
func jump_start():
	print("开始跳跃")
	is_jumping = true
	is_ride = false
	curr_be_attack_status = E_BeAttackStatusZombie.IsJump
	signal_status_update.emit()

## 僵尸跳跃结束,跳跃组件信号发射调用
func jump_end():
	is_jumping = false
	jump_component.disable_component(ComponentNormBase.E_IsEnableFactor.Jump)


## 僵尸跳跃后摇结束
func jump_end_end():
	curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
	move_component.update_move_mode(MoveComponent.E_MoveMode.Ground)
	is_trigger_squash_pos_judge = false
	is_trigger_tall_nut_stop_jump = false
	print("是否触发倭瓜位置判断修改")

## 跳跃被强行停止,高坚果调用
func jump_be_stop(plant:Plant000Base):
	jump_component.jump_be_stop(plant)

## 改变游泳状态,
func change_is_swimming(value:bool):
	is_swimming = value
	#move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsSwimingChange)
	#shadow.visible = not value
	## 如果是跳入泳池
	if is_swimming:
		curr_be_attack_status = E_BeAttackStatusZombie.IsJumpInPool
		#print("当前状态:", curr_be_attack_status)
		signal_status_update.emit()
	else:
		move_component.update_move_mode(MoveComponent.E_MoveMode.Ground)
		## 如果骑海豚到泳池边缘离开泳池
		if is_ride:
			await get_tree().process_frame
			global_position.x -= 62
			move_component._walking_start()


## 动画调用函数
## 僵尸跳入泳池动画
func zombie_jump_in_pool_end():
	curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
	signal_status_update.emit()
	move_component.update_move_mode(MoveComponent.E_MoveMode.Speed)
	shadow.visible = false

	jump_component.enable_component(ComponentNormBase.E_IsEnableFactor.Default)

## 角色死亡
func character_death():
	super()
	## 如果骑着海豚死亡,没有对应死亡动画
	if is_ride:
		await get_tree().create_timer(2.0, false).timeout
		queue_free()
