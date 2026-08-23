extends Bullet000ParabolaBase

## 黄油控制时间
@export var butter_time:float = 4.0

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	if enemy is Zombie000Base:
		enemy.be_butter(butter_time)
