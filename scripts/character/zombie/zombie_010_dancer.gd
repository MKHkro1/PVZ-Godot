extends Zombie009Jackson
class_name Zombie010Dancer

## 是否为被召唤的伴舞僵尸
var is_call := false
## 是否被魅惑舞王召唤
var is_call_be_hypno:bool = false

## 初始化伴舞赋值，被召唤的伴舞，舞王管理器调用
func init_dancer_be_call(curr_dancer_id, curr_animation_origin_speed, animation_curr_speed, jackson_init_random_speed, curr_jackson_manager, is_hypnotized):
	is_call = true
	self.dancer_id = curr_dancer_id
	self.jackson_manager = curr_jackson_manager
	## 如果舞王被魅惑
	is_call_be_hypno = is_hypnotized
	call_deferred(&"init_anim_speed_dance", curr_animation_origin_speed, animation_curr_speed, jackson_init_random_speed)

## 重写舞王初始方法，ready调用
func _init_dance():
	if not is_call:
		jackson_manager = SceneRegistry.JACKSON_MANAGER.instantiate()
		add_child(jackson_manager)
		dancer_id = 0
		jackson_manager.zombie_dancers[0] = self
		state_machine.jackson_manager = jackson_manager
		state_machine.init_state(JacksonStateMachine.E_JacksonStatus.Norm)

	else:
		state_machine.jackson_manager = jackson_manager
		## 初始化状态为入场状态,伴舞入场状态不攻击
		state_machine.init_state(JacksonStateMachine.E_JacksonStatus.Enter)
		await zombie_appear_from_ground()
		state_machine.change_jackson_anim_status(state_machine.curr_jackson_status,state_machine.judge_curr_status())

	if is_call_be_hypno:
		be_hypno()

## 召唤伴舞初始化时重置动画播放速度, 舞王管理器调用
func init_anim_speed_dance(curr_animation_origin_speed, curr_speed, jackson_init_random_speed):
	## 获取动画初始速度
	self.animation_origin_speed = curr_animation_origin_speed
	update_speed_factor(jackson_init_random_speed, E_Influence_Speed_Factor.InitRandomSpeed)
	anim_component.set_animation_origin_speed(animation_origin_speed)
	anim_component.owner_update_speed(jackson_init_random_speed)
	anim_component.update_anim_speed_scale(curr_speed)

## 随机初始化角色速度,继承重写
func init_random_speed():
	if is_call:
		return
	super()

## 伴舞僵尸从地下出现
func zombie_appear_from_ground():
	await zombie_up_from_ground()
	#dirt.start_dirt()
	#body.visible = false
	#mask.visible = true
	#body_in_mask.position.y = 300.0
	#var tween = create_tween()
	##await get_tree().process_frame
	#tween.tween_property(body_in_mask, ^"global_position", body.global_position, 1.0)
	#await tween.finished
	#body.visible = true
	#mask.visible = false

## 初始化展示角色
func _init_show_jackon():
	while true:
		animation_player.play("armraise")
		await animation_player.animation_finished
		body.scale.x = -body.scale.x

## 伴舞被魅惑额外操作
func jackson_be_hypno():
	## 如果是被魅惑舞王召唤、无需处理
	if is_call_be_hypno:
		return

	dancer_manager_change()

	jackson_manager = SceneRegistry.JACKSON_MANAGER.instantiate()
	state_machine.jackson_manager = jackson_manager
	add_child(jackson_manager)
	jackson_manager.zombie_dancers[0] = self

	jackson_manager.start_anim()
	jackson_manager.init_anim_speed(animation_origin_speed, influence_speed_factors[E_Influence_Speed_Factor.InitRandomSpeed])
	jackson_manager.is_hypnotized = true
	#print("舞王或伴舞被魅惑")
