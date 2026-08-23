extends Node2D
class_name BrainBody

## 角色被压扁,复制一份body更新其为根节点父节点
## 角色被压扁时死亡消失,copy body保留两秒后消失
func be_flattened_body():
	var body_copy = duplicate()
	owner.get_parent().add_child(body_copy)
	body_copy.copy_be_flattened()
	body_copy.global_position = global_position

## 复制体被压扁,两秒后删除
func copy_be_flattened():
	scale.y *= 0.4
	await_free(2)

## 设置等待一段时间后删除
func await_free(time:float = 2):
	await get_tree().create_timer(time, false).timeout
	queue_free()
