extends Node2D
class_name PotHammer
## 罐子的锤子

@onready var hammer_animation_player: AnimationPlayer = $HammerAnimationPlayer

func activate_it():
	reparent(owner.plant_cell)

	visible = true
	hammer_animation_player.play(&"Hammer_whack_zombie")
	SoundManager.play_other_SFX("swing")

	await hammer_animation_player.animation_finished
	queue_free()
