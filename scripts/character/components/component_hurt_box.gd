extends ComponentNormBase
## 被攻击组件
class_name HurtBoxComponent

@onready var hurt_box_real: Area2D = %HurtBoxReal

 #在碰撞区域内修改属性似乎没有作用
## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	if is_enabling:
		for area:Area2D in get_children():
			#area.set_deferred("monitorable", true)
			call_deferred("update_area_monitorable", area, true)

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	#print_debug("受击组件")
	super(is_enable_factor)
	if not is_enabling:
		for area:Area2D in get_children():
			call_deferred("update_area_monitorable", area, false)
			#area.set_deferred("monitorable", false)

## 更新区域是否可以被检查
func update_area_monitorable(area:Area2D, v:bool):
	area.monitorable = v

	## INFO: 更新 monitoring 才会更新 monitorable
	area.monitoring = not area.monitoring
	area.monitoring = not area.monitoring

