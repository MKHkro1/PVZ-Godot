extends BulletLinear000Base
class_name Bullet002PeaSnow

@export var time_be_decelerated :float = 3.0

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	if enemy is Zombie000Base:
		if enemy.hp_component.curr_hp_armor2 <= 0:
			enemy.be_ice_decelerate(time_be_decelerated)


