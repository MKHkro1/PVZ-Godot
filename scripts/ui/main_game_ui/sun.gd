extends Node2D
class_name Sun

@export var sun_value := 25

## 阳光存在时间
@export var exist_time:float = 10.0
## 消失前闪烁提醒的时长
@export var expire_blink_time:float = 2.0
var collected := false  # 是否已被点击收集
## 生产阳光移动的tween
var spawn_sun_tween:Tween
## 到期闪烁tween
var expire_blink_tween:Tween
## 按阳光价值换算的基础缩放
var base_scale := Vector2.ONE

func _ready() -> void:
	_sun_scale(sun_value)
	## 启动存在时间定时器(预留出闪烁提醒时间)
	await get_tree().create_timer(exist_time - expire_blink_time, false).timeout

	# 如果还没被点击收集，闪烁提醒后自动销毁
	if not collected and is_instance_valid(self):
		_start_expire_blink()

func init_sun(curr_sun_value:int, pos:Vector2):
	sun_value = curr_sun_value
	position = pos

func _sun_scale(new_sun_value:int):
	base_scale = Vector2.ONE * (new_sun_value / 25.0)
	scale = base_scale


func _on_button_pressed() -> void:
	if spawn_sun_tween:
		spawn_sun_tween.kill()
	_stop_expire_blink()

	if collected:
		return  # 防止重复点击

	collected = true  # 设置已被收集
	var target_position = Vector2()
	SoundManager.play_other_SFX("points")
	if is_instance_valid(Global.main_game):
		if is_instance_valid(Global.main_game.marker_2d_sun_target):
			## 出战卡槽在canvaslayer中，位置和摄像头位置有偏移
			target_position = Global.main_game.marker_2d_sun_target.global_position + Global.main_game.camera_2d.global_position
			#print(Global.main_game.marker_2d_sun_target.get_canvas_layer_node().get_final_transform())
		else:
			target_position = Global.main_game.marker_2d_sun_target_default.global_position

		EventBus.push_event("add_sun_value", [sun_value])

	$Button.queue_free()

	## 收集动画：先弹一下，再加速吸向阳光计数器，同时缩小
	var tween:Tween = create_tween()
	tween.tween_property(self, "scale", base_scale * 1.2, 0.08)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_position, 0.32)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", base_scale * 0.4, 0.32)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()


## 阳光即将消失,闪烁提醒(类似原版)
func _start_expire_blink() -> void:
	expire_blink_tween = create_tween()
	var half := expire_blink_time / 6.0
	for i in 3:
		expire_blink_tween.tween_property(self, "modulate:a", 0.25, half)
		expire_blink_tween.tween_property(self, "modulate:a", 1.0, half)
	await expire_blink_tween.finished
	if not collected:
		queue_free()

## 停止到期闪烁并恢复透明度
func _stop_expire_blink() -> void:
	if expire_blink_tween and expire_blink_tween.is_valid():
		expire_blink_tween.kill()
	modulate.a = 1.0

func on_sun_tween_finished():
	if Global.auto_collect_sun:
		_on_button_pressed()
