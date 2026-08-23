extends Node2D
## 角色身体属性，用于管理body变换（发亮、颜色）
class_name BodyCharacter

## 模仿者材质
const IMITATER = preload("res://shader_material/imitater.tres")

const BODY_MASK = preload("res://shader_material/body_mask.tres")
var hit_tween: Tween = null  # 发光动画
var light_and_dark_tween: Tween = null  # 明暗交替动画

# modulate 状态颜色变量
var base_color := Color(1, 1, 1)

var change_color:Dictionary[E_ChangeColors, Color] = {
}
enum E_ChangeColors{
	HitColor,
	IceColor,	## 冰冻和减速使用一个
	BeShovelLookColor,
	HypnoColor,
	CreateSunColor,
	LightAndDark,	## 明暗交替颜色变化(紫卡种植\咖啡豆)
	CharredBlack,	## 被炸弹炸黑
}


func owner_be_hypno():
	set_other_color(E_ChangeColors.HypnoColor, Color(1,0.5,1))


func set_other_color(change_name:E_ChangeColors, value: Color) -> void:
	change_color[change_name] = value
	_update_modulate()


## 更新最终 modulate 的合成颜色
func _update_modulate():
	var final_color = base_color
	for change_color_value in change_color.values():
		final_color *= change_color_value
	modulate = final_color


## 发光动画函数
func body_light():
	## 先直接变亮
	set_other_color(E_ChangeColors.HitColor, Color(2, 2, 2))

	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	hit_tween = create_tween()
	## 快闪快收：指数衰减，受击反馈更干脆
	hit_tween.tween_method(
		func(val): set_other_color(E_ChangeColors.HitColor, val), # 传匿名函数包一层，保证有 change_name
		change_color[E_ChangeColors.HitColor],
		Color(1, 1, 1),
		0.35
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

## 身体明暗交替(紫卡植物种植时显示)
func body_light_and_dark():
	if light_and_dark_tween and light_and_dark_tween.is_running():
		light_and_dark_tween.kill()
	light_and_dark_tween = create_tween()
	light_and_dark_tween.set_loops()
	light_and_dark_tween.tween_method(
		func(val): set_other_color(E_ChangeColors.LightAndDark, val), # 传匿名函数包一层，保证有 change_name
		Color(0.6, 0.6, 0.6),
		Color(2.0, 2.0, 2.0, 1.0),
		0.5
	)
	light_and_dark_tween.tween_method(
		func(val): set_other_color(E_ChangeColors.LightAndDark, val), # 传匿名函数包一层，保证有 change_name
		Color(2, 2, 2),
		Color(0.6, 0.6, 0.6),
		0.5
	)

## 明暗交替结束
func body_light_and_dark_end():
	if light_and_dark_tween and light_and_dark_tween.is_running():
		light_and_dark_tween.kill()
	set_other_color(E_ChangeColors.LightAndDark, Color(1,1,1))

## body被炸弹炸黑(蹦极)
func body_charred_black():
	set_other_color(E_ChangeColors.CharredBlack, Color(0,0,0))

## 模仿者更新材质
func imitater_update_material():
	material = IMITATER.duplicate()
	for child in get_children():
		if child.owner == owner:
			GlobalUtils.node_use_parent_material(child)


#region 僵尸从地下\水下出现
## 僵尸从地下出来
func zombie_body_up_from_ground(up_time:float = 1.0):
	body_mask_start()
	## 泥土特效
	var dirt_rise_effect:DirtRiseEffect = SceneRegistry.DIRT_RISE_EFFECT.instantiate()
	owner.add_child(dirt_rise_effect)
	dirt_rise_effect.start_dirt()

	position.y += 100
	var tween :Tween = create_tween()
	tween.tween_property(self, "position:y", position.y-100, up_time)
	await tween.finished
	body_mask_end()

## 僵尸从水下出来(珊瑚僵尸)
func zombie_body_up_from_pool():
	body_mask_start()
	position.y += 100
	var tween :Tween = create_tween()
	tween.tween_property(self, "position:y", position.y-100, 1)
	await tween.finished
	body_mask_end()

## 身体在当前body节点以上的显示,以下透明,需要转为画布坐标
func body_mask_start():
	material = BODY_MASK.duplicate()
	material.set_shader_parameter(&"cutoff_y", GlobalUtils.world_to_screen(owner.global_position).y)
	for child in get_children():
		GlobalUtils.node_use_parent_material(child)

## 结束身体在当前body节点以上的显示,以下透明
func body_mask_end():
	material = null

#endregion

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
