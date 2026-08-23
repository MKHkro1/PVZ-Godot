extends Camera2D
class_name MainGameCamera

## 屏幕震动状态(用 offset 实现, 不干扰 move_to 的位移)
var _shake_intensity := 0.0
var _shake_duration := 0.0
var _shake_elapsed := 0.0


func _ready() -> void:
	set_process(false)


# 返回 Tween 对象，供外部 await
func move_to(target_pos: Vector2, duration: float) -> Signal:
	var tween = create_tween()

	tween.tween_property(self, "global_position", target_pos, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	return tween.finished


## 开始游戏查看僵尸
func move_look_zombie():
	return move_to(Vector2(120, 0), 2)

## 返回原点
func move_back_ori():
	return move_to(Vector2(-150, 0), 2)


## 屏幕震动(爆炸/重击反馈): 随机偏移随时间线性衰减
## 连续触发时强度取较高者, 时长顺延
func shake(intensity := 7.0, duration := 0.4) -> void:
	if _shake_elapsed < _shake_duration:
		_shake_intensity = maxf(_shake_intensity * 0.6, intensity)
		_shake_duration += duration
	else:
		_shake_intensity = intensity
		_shake_duration = duration
	_shake_elapsed = 0.0
	set_process(true)


func _process(delta: float) -> void:
	if _shake_elapsed >= _shake_duration:
		offset = Vector2.ZERO
		set_process(false)
		return
	_shake_elapsed += delta
	var decay := 1.0 - _shake_elapsed / _shake_duration
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_intensity * decay
