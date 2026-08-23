extends Plant000Base
class_name Plant032MagnetShroom

@onready var magnet_component: MagnetComponent = $MagnetComponent

@export_group("动画状态")
@export var is_attack:=false

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	magnet_component.signal_attack_start.connect(func():is_attack=true)
	magnet_component.signal_attack_cd_end.connect(func():is_attack=false)

	signal_update_speed.connect(magnet_component.owner_update_speed)

