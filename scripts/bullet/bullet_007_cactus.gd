extends BulletLinear000Base
class_name BulletLinear007Cactus

func _ready() -> void:
	super()
	## 如果是空中子弹
	if can_attack_zombie_status & 8:
		bullet_shadow.position.y = 100

