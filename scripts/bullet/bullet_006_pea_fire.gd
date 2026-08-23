extends BulletLinear000Base
class_name Bullet006PeaFire

@onready var anim_lib: AnimationPlayer = $Body/AnimLib
@onready var spatter_component: SpatterComponent = $SpatterComponent

func _ready() -> void:
	super()
	anim_lib.play(&"ALL_ANIMS")

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	enemy.cancel_ice()
	spatter_component.spatter_all_area_zombie(enemy)
