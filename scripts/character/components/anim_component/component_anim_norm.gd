extends AnimComponentBase
class_name AnimComponentNorm
## 普通动画组件,使用AnimationTree的角色使用

@onready var animation_tree: AnimationTree = $"../AnimationTree"

func _ready() -> void:
	animation_origin_speed = animation_tree.get("parameters/TimeScale/scale")
	animation_tree.animation_finished.connect(_on_animation_finished)

## 更新动画速度
func owner_update_speed(speed_factor_product:float):
	animation_tree.set("parameters/TimeScale/scale", animation_origin_speed * speed_factor_product)

## 更新动画速度(动画播放速度)
func update_anim_speed_scale(speed_scale:float):
	animation_tree.set("parameters/TimeScale/scale", speed_scale)

## 停止动画
func stop_anim():
	animation_tree.active = false
