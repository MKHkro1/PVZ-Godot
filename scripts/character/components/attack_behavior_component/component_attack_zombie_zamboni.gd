extends AttackComponentBase
class_name AttackComponentZombieZamboni

## 开始攻击
func attack_start():
	if is_instance_valid(detect_component.enemy_can_be_attacked):
		detect_component.enemy_can_be_attacked.be_flattened_from_enemy(owner)
	elif is_instance_valid(detect_component.brain):
		var brain:BrainOnZombieMode = detect_component.brain
		brain.be_flattened()

## 结束攻击
func attack_end():
	pass

## 修改速度
func owner_update_speed(_speed_product:float):
	pass
