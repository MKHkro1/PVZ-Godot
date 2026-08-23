extends CharredComponent
class_name CharredComponentZombieNorm
## 灰烬组件

## 灰烬动画
@onready var anim_lib: AnimationPlayer = $ZombieCharred/CharredCorrect/AnimLib
@onready var body: BodyCharacter = %Body

@export var anim_lib_name := "ALL_ANIMS"

## 播放灰烬动画
func play_charred_anim():
	super()
	anim_lib.play(anim_lib_name)
	await anim_lib.animation_finished
	queue_free()
