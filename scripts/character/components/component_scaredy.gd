extends ComponentNormBase
class_name ScaredyComponent


signal signal_scaredy_start
signal signal_scaredy_end

## 害怕时影响的节点
@export var scaredy_influence_components:Array[ComponentNormBase]
## 检测到的敌人
var enemies_can_be_attacked: Array[Character000Base]


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for node in get_children():
		if node is Area2D:
			var area_2d = node as Area2D
			area_2d.monitoring = true
			# 启用后立即检查当前区域内的重叠对象
			for overlap_area in area_2d.get_overlapping_areas():
				_on_area_2d_area_entered(overlap_area)

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for node in get_children():
		if node is Area2D:
			var area_2d = node as Area2D
			area_2d.monitoring = false
	enemies_can_be_attacked.clear()
	signal_scaredy_end.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_enabling:
		var enemy = area.owner
		if enemy is Character000Base:
			## 第一次检测到敌人
			if enemies_can_be_attacked.is_empty():
				signal_scaredy_start.emit()
			if enemy not in enemies_can_be_attacked:
				enemies_can_be_attacked.append(enemy)
		else:
			push_error("检测到非角色类敌人")

func _on_area_2d_area_exited(area: Area2D) -> void:
	if is_enabling:
		var enemy = area.owner
		if enemy is Character000Base and enemy in enemies_can_be_attacked:
			enemies_can_be_attacked.erase(enemy)
			if enemies_can_be_attacked.is_empty():
				signal_scaredy_end.emit()
		else:
			push_error("检测到非角色类敌人")
