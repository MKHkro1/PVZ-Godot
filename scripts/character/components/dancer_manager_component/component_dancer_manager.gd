extends ComponentNormBase
class_name DancerManagerComponent

## 舞王和伴舞僵尸，0表示舞王
var zombies_dancer :Dictionary[int, Zombie000Base]

@export_group("动画相关")
## 开始动画、舞王入场召唤结束
@export var is_start_anim := true
## 是否为跳舞动画
@export var is_dance := true

## 同步动画，舞王或者伴舞修改攻击动画时
func sync_anim_once_zombie():
	pass
