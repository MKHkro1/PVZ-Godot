@abstract
extends Node2D
class_name AnimComponentBase
## 动画组件基类
## 由于部分僵尸可能没有AnimationTree或者AnimationPlayer
## 使用该组件统一进行一些动画速度的控制
## 子类实现具体方法

## 动画结束信号
signal signal_animation_finished(anim_name:StringName)

## 角色动画原始速度
var animation_origin_speed :float = -1


## 获取动画原始速度
func get_animation_origin_speed():
	if animation_origin_speed == -1:
		push_error("动画速度为-1")
	return animation_origin_speed

## 设置初始化速度(伴舞使用)
func set_animation_origin_speed(value:float):
	animation_origin_speed = value

## 更新动画速度(根据速度倍率)
@abstract
func owner_update_speed(speed_factor_product:float)

## 更新动画速度(动画播放速度)
@abstract
func update_anim_speed_scale(speed_scale:float)

## 停止动画
func stop_anim():
	pass

## 动画结束时发射信号
func _on_animation_finished(anim_name:StringName):
	signal_animation_finished.emit(anim_name)
	#print("当前动画结束")

