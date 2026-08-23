extends Zombie000Base
class_name Zombie004PoleVaulter

@onready var jump_component: JumpComponent = $JumpComponent
@onready var detect_component: DetectComponent = %DetectComponent

@export var is_jumping := false
var is_jump_stop := false
var jump_stop_postion :Vector2

## 监测到脑子
var is_detect_brain:=false

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

	## 我是僵尸模式检测到脑子
	jump_component.signal_detect_brain.connect(_on_jump_detect_brain)

## 开始跳跃,跳跃组件信号发射调用
func jump_start():
	is_jumping = true
	curr_be_attack_status = E_BeAttackStatusZombie.IsJump
	signal_status_update.emit()

## 僵尸跳跃结束,跳跃组件信号发射调用
func jump_end():
	is_jumping = false
	jump_component.disable_component(ComponentNormBase.E_IsEnableFactor.Jump)

## 僵尸跳跃后摇结束
func jump_end_end():
	curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
	signal_status_update.emit()
	is_trigger_squash_pos_judge = false
	is_trigger_tall_nut_stop_jump = false

## 跳跃被强行停止,高坚果调用
func jump_be_stop(plant:Plant000Base):
	jump_component.jump_be_stop(plant)

## 跳跃之前检测到脑子
func _on_jump_detect_brain():
	is_detect_brain=true
	detect_component.enable_component(ComponentNormBase.E_IsEnableFactor.Jump)
