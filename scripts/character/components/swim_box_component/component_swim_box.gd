extends Node2D
class_name SwimBoxComponent
## 僵尸游泳组件基类

@onready var shadow: Sprite2D = %Shadow
@onready var body: BodyCharacter = %Body

## 游泳时body变化
@export var body_change_swim:ResourceBodyChange

## 特殊水花位置(普通水花位置跟影子重叠,海豚僵尸使用)
@export var special_splash_pos_node:Node2D

var owner_is_death:=false

## 改变游泳状态信号
signal signal_change_is_swimming(is_swimming:bool)

func _on_owner_is_death():
	owner_is_death = true

## 检测到泳池
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is Pool:
		signal_change_is_swimming.emit(true)

## 离开泳池
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner is Pool:
		signal_change_is_swimming.emit(false)

## 出现水花
func appear_splash():
	## 水花
	var splash = SceneRegistry.SPLASH.instantiate()
	splash.position = shadow.global_position - owner.get_parent().global_position + Vector2(0, 15)
	owner.get_parent().add_child.call_deferred(splash)

## 特殊位置水花
func appear_splash_special_pos():
	## 水花
	var splash = SceneRegistry.SPLASH.instantiate()
	splash.position = special_splash_pos_node.global_position - owner.get_parent().global_position + Vector2(0, 15)

	owner.get_parent().add_child.call_deferred(splash)

