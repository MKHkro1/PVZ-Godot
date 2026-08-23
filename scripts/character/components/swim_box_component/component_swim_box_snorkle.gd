extends SwimBoxComponent
class_name SwimBoxComponentBaseSnorkle
## 潜水僵尸游泳组件

## 检测到泳池
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is Pool:
		signal_change_is_swimming.emit(true)

## 离开泳池
func _on_area_2d_area_exited(area: Area2D) -> void:
	if not owner_is_death:
		if area.owner is Pool:
			appear_splash()
			signal_change_is_swimming.emit(false)

