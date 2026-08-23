extends ZombieDropBase


func _ready() -> void:
	super()
	x_v = randf_range(-15, 15)
	velocity = Vector2(x_v, 0)
	#rotation_speed = randf_range(1.3, 2.1)
	rotation_speed = randf_range(-2, 2)
