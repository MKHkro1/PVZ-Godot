extends Node2D
class_name Splash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 水花
	SoundManager.play_other_SFX("zombie_entering_water")
	var splash_anim:AnimationPlayer = get_node("AnimLib")
	splash_anim.play("ALL_ANIMS")
	await splash_anim.animation_finished
	queue_free()
