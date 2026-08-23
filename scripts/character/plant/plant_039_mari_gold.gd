extends Plant000Base
class_name Plant039MariGold

@onready var create_coin_component: CreateCoinComponent = $CreateCoinComponent

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(create_coin_component.owner_update_speed)
