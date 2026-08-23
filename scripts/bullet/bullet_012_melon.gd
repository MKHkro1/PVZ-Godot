extends Bullet000ParabolaBase
class_name Bullet012Melon


@onready var spatter_component: SpatterComponent = $SpatterComponent

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	spatter_component.spatter_all_area_zombie(enemy, lane)
