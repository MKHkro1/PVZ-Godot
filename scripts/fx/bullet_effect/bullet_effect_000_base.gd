extends Node2D
class_name BulletEffect000Base
## 子弹特效基类

## 是否有子弹特效
@export var is_bullet_effect := true

## 激活子弹特效
func activate_bullet_effect():
	## 子弹父类
	var bullet_parent = owner.get_parent()
	z_index = owner.z_index
	#GlobalUtils.child_node_change_parent(self, bullet_parent)

	reparent(bullet_parent)
