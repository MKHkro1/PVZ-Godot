extends AnimComponentBase
class_name AnimComponentEmpty
## 空动画,保龄球植物使用,保龄球放置后发射一颗保龄球子弹删除植物本体

## 更新动画速度
@warning_ignore("unused_parameter")
func owner_update_speed(speed_factor_product:float):
	pass

## 更新动画速度(动画播放速度)
@warning_ignore("unused_parameter")
func update_anim_speed_scale(speed_scale:float):
	pass

## 停止动画
func stop_anim():
	pass
