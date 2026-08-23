extends ZombieDropBase


func _ready() -> void:
	super()
	x_v = randf_range(-70, 70)
	velocity = Vector2(x_v, randf_range(-200, -100))
	rotation_speed = x_v/50
