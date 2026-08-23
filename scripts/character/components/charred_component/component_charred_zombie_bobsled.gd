extends CharredComponent
class_name CharredComponentZombieBobsled

@onready var zombie_bobsled_1: Sprite2D = $"../ZombieBobsled1"

## 灰烬动画
@onready var zombie_charred: Array[Node2D] = [
	%ZombieCharred, %ZombieCharred2, %ZombieCharred3, %ZombieCharred4
]
@onready var all_anim_lib: Array[AnimationPlayer] = [
	$ZombieCharred/CharredCorrect/AnimLib,
	$ZombieCharred2/CharredCorrect/AnimLib,
	$ZombieCharred3/CharredCorrect/AnimLib,
	$ZombieCharred4/CharredCorrect/AnimLib,
]

## 播放灰烬动画
func play_charred_anim():
	super()
	var black_zombie_bobsled_1:Node2D = zombie_bobsled_1.duplicate()
	add_child(black_zombie_bobsled_1)
	black_zombie_bobsled_1.global_position = zombie_bobsled_1.global_position
	black_zombie_bobsled_1.modulate = Color.BLACK
	for i in range(4):
		zombie_charred[i].visible = true
		all_anim_lib[i].play("ALL_ANIMS")
	await all_anim_lib[0].animation_finished
	queue_free()
