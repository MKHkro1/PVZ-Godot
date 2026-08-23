extends IronNode
class_name IronNodeArmor

## 铁器防具对应的精灵图
@export var iron_armor_sprite:Sprite2D
## boyd防具对应的精灵图
@export var body_armor_sprite:Sprite2D

## 被吸走预处理
func preprocessing_be_magnet():
	super()
	iron_armor_sprite.texture = body_armor_sprite.texture
