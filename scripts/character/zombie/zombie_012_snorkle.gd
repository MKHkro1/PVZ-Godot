extends Zombie000Base
class_name Zombie012Snorkle

## 角色死亡
func character_death():
	super()
	## 不在泳池中，死亡后消失
	if not is_swimming:
		await get_tree().create_timer(2.0, false).timeout
		queue_free()


## 改变攻击状态攻击
func change_is_attack(value:bool):
	is_attack = value
	if not is_attack:
		move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAnimGap)

## 继承重写
## 改变游泳状态
func change_is_swimming(value:bool):
	is_swimming = value
	## 如果是跳入泳池
	if is_swimming:
		curr_be_attack_status = E_BeAttackStatusZombie.IsJumpInPool

	## 如果是离开泳池
	else:
		curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
		shadow.visible = true
		position.x -= 40

#region 动画调用
## 跳入泳池动画结束
func jump_to_pool_end():
	move_component.update_move_mode(MoveComponent.E_MoveMode.Speed)
	curr_be_attack_status = E_BeAttackStatusZombie.IsDownPool
	shadow.visible = false

## 动画调用函数
## 从水中起来攻击植物
func up_to_attack_start():
	curr_be_attack_status = E_BeAttackStatusZombie.IsNorm

## 攻击完植物后潜入水里
func down_to_pool():
	curr_be_attack_status = E_BeAttackStatusZombie.IsDownPool
	move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsAnimGap)

#endregion
