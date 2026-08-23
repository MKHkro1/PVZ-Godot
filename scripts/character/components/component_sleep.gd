extends ComponentNormBase
class_name SleepComponent


@onready var anim_sleep: AnimationPlayer = $AnimSleep

## 是否正在睡觉
var is_sleeping:bool = false

signal signal_is_sleep
signal signal_not_is_sleep

## 睡眠影响的节点,在植物本体中调用judge_is_sleeping()使对应节点disable
@export var sleep_influence_components:Array[ComponentNormBase]

## 植物本体_ready节点调用
func judge_is_sleeping() -> void:
	var curr_root = get_tree().current_scene
	## 如果是主游戏根节点
	if curr_root is MainGameManager:
		if curr_root.game_para.is_day:
			start_sleep()
		else:
			end_sleep()
	## 如果是花园场景
	elif curr_root is GardenManager:
		if curr_root.curr_bg_type == GardenManager.E_GardenBgType.GreenHouse:
			start_sleep()
		else:
			end_sleep()


func start_sleep():
	visible = true
	anim_sleep.play("zzz")
	signal_is_sleep.emit()


func end_sleep():
	visible = false
	anim_sleep.stop()
	signal_not_is_sleep.emit()

## 更新动画速度
func owner_update_speed(speed_product:float):
	anim_sleep.speed_scale = speed_product


