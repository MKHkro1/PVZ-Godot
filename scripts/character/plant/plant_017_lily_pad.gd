extends Plant000DownBase
class_name Plant017LilyPad


func _ready() -> void:
	super._ready()
	tween_up_and_down()

func tween_up_and_down():
	await get_tree().physics_frame
	var tween = create_tween()
	tween.set_loops()  # 无限循环
	tween.set_trans(Tween.TRANS_SINE)  # 平滑缓动

	# 向上移动
	tween.tween_property(
		self,
		"position:y",
		position.y - 5,
		2 + randf()
	).set_ease(Tween.EASE_IN_OUT)

	# 向上移动（返回原点）
	tween.tween_property(
		self,
		"position:y",
		position.y ,
		2 + randf()
	).set_ease(Tween.EASE_IN_OUT)
