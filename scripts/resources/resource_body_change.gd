extends Resource
class_name ResourceBodyChange
## body变化时使用的资源文件

## 改变纹理的精灵节点
@export_node_path("Sprite2D")  var sprite_change:Array[NodePath]

## 改变纹理的精灵节点对应的纹理
@export var sprite_change_texture:Array[Texture2D]

## 出现的精灵节点
@export var sprite_appear:Array[NodePath]
## 消失的精灵节点
@export var sprite_disappear:Array[NodePath]
## 掉落的节点
@export_node_path("ZombieDropBase") var node_drop:NodePath


func update_body(curr_node:Node):
	for i in range(sprite_change.size()):
		var sprite:Sprite2D = curr_node.get_node(sprite_change[i])
		sprite.texture = sprite_change_texture[i]

	for i in range(sprite_appear.size()):
		var node:Node2D = curr_node.get_node(sprite_appear[i])
		node.visible = true

	for i in range(sprite_disappear.size()):
		var node:Node2D = curr_node.get_node(sprite_disappear[i])
		node.visible = false

	if not node_drop.is_empty():
		if curr_node.has_node(node_drop):
			var drop:ZombieDropBase = curr_node.get_node(node_drop)
			drop.acitvate_it()


func get_drop_node(curr_node:Node) -> ZombieDropBase:
	if not node_drop.is_empty():
		if curr_node.has_node(node_drop):
			var drop:ZombieDropBase = curr_node.get_node(node_drop)
			return drop
	return null
