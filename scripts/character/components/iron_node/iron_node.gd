extends Node2D
class_name IronNode

## 是否已经被吸走
var is_be_magnet := false
## 铁器被吸走掉落需要隐藏的节点,铁器防具需要隐藏掉落铁器
@export var all_disappear_nodes:Array[Node2D]

## 被吸走预处理
func preprocessing_be_magnet():
	for node in all_disappear_nodes:
		node.visible = false
