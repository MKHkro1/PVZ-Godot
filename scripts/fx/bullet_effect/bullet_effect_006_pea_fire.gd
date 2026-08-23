extends BulletEffect000Base
class_name BulletEffect006PeaFire

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate_bullet_effect():
	super()
	visible = true
	animation_player.play("fire_done")
	await animation_player.animation_finished
	queue_free()
