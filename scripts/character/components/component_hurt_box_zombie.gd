extends HurtBoxComponent
## 僵尸被被攻击盒子组件
class_name HurtBoxComponentZombie

## 被检测受击框
@onready var hurt_box_detection: Area2D = %HurtBoxDetection
## 攻击时被检测受击框（大嘴花、窝瓜可以检测到）
@onready var hurt_box_detection_on_attack: Area2D = %HurtBoxDetectionOnAttack
## 攻击时受击框修正x位置
@export var x_correct_on_attack:float = -20

## 攻击时受击框出现
func change_area_attack_appear(value: bool):
	if is_instance_valid(hurt_box_detection_on_attack):
		if value:
			hurt_box_detection_on_attack.position.x = x_correct_on_attack
		else:
			hurt_box_detection_on_attack.position.x = 0

## 被魅惑
func owner_be_hypno():
	hurt_box_detection.collision_layer = 32
	hurt_box_real.collision_layer = 1024
	hurt_box_detection_on_attack.queue_free()
