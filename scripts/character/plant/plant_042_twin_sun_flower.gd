extends Plant000Base
class_name Plant042TwinSunFlower

@onready var create_sun_component: CreateSunComponent = $CreateSunComponent


func ready_norm() -> void:
	super()
	if is_zombie_mode:
		create_sun_component.disable_component(ComponentNormBase.E_IsEnableFactor.GameMode)

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(create_sun_component.owner_update_speed)


## 被僵尸啃食一次特殊效果,魅惑\大蒜\我是僵尸生产阳光
func _be_zombie_eat_once_special(_attack_zombie:Zombie000Base):
	if is_zombie_mode:
		create_sun_component._on_be_eat_once()

## 植物死亡
func character_death():
	if is_zombie_mode:
		create_sun_component._on_character_death()
	super()
