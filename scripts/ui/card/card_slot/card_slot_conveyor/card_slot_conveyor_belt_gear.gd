extends Panel
class_name ConveyorBeltGear

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


## 开始齿轮运动
func start_gear():
	animated_sprite_2d.play(&"default")

## 结束齿轮运动
func stop_gear():
	animated_sprite_2d.stop()

func change_gear_speed(speed:float):
	animated_sprite_2d.speed_scale = speed
