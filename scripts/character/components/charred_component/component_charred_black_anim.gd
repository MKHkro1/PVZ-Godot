extends CharredComponent
class_name CharredComponentBlackAnim
## 变黑动画,无动画,只变黑

@onready var body: BodyCharacter = %Body


## 播放灰烬动画
func play_charred_anim():
	super()
	body.body_charred_black()
	var black_body:Node2D = body.duplicate()
	add_child(black_body)
	black_body.global_position = body.global_position
	await get_tree().create_timer(1, false).timeout
	queue_free()
