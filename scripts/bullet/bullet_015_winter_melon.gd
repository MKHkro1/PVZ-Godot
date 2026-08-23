extends Bullet000ParabolaBase
class_name Bullet015WinterMelon


@export var time_be_decelerated :float = 3.0
@onready var spatter_component: SpatterComponentWinterMelon = $SpatterComponent

func _ready() -> void:
	super()
	spatter_component.time_be_decelerated = time_be_decelerated

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	spatter_component.spatter_all_area_zombie(enemy, lane)
	if enemy != null:
		enemy.be_ice_decelerate(time_be_decelerated)
