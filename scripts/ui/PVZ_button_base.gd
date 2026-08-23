extends BaseButton
class_name PVZButtonBase

## 按钮基础交互反馈:悬停放大回弹 + 按下右下位移

var original_pos
var current_tween: Tween = null
var scale_tween: Tween = null

const HOVER_SCALE := 1.06

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## 连接信号
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## 记录悬停前的位置(布局稳定后刷新,避免入场动画期间误记录)
func _on_mouse_entered() -> void:
	if not button_pressed:
		original_pos = position
	if size != Vector2.ZERO:
		pivot_offset = size / 2.0
	if scale_tween and scale_tween.is_valid():
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * HOVER_SCALE, 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	if scale_tween and scale_tween.is_valid():
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _on_button_down() -> void:
	if current_tween:
		current_tween.kill()  # 停止上一个 Tween
	current_tween = create_tween()
	if original_pos == null:
		original_pos = position
	var target_pos = original_pos + Vector2(2, 2)
	# 移动到右下（立即执行）
	current_tween.tween_property(self, "position", target_pos, 0.1)



func _on_button_up() -> void:
	if current_tween:
		current_tween.kill()  # 停止上一个 Tween
	current_tween = create_tween()
	current_tween.tween_property(self, "position", original_pos, 0.1)
