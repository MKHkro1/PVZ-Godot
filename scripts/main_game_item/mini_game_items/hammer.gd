extends Node2D
class_name Hammer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var pow_effect: Sprite2D = $Pow

@export_group("锤击出阳光相关")
## 是否掉落阳光
@export var can_sun := true
## 掉落阳光概率
@export var pred_sun :int = 10
## 掉落阳光价值
@export var sun_value := 25
## 锤子是否正在使用
var is_used := false

func _ready() -> void:
	EventBus.subscribe("main_game_progress_update", _on_main_game_progress_update)


## 主游戏进程改变时,设置启动锤子
func _on_main_game_progress_update(curr_main_game_progress:MainGameManager.E_MainGameProgress):
	if curr_main_game_progress == MainGameManager.E_MainGameProgress.MAIN_GAME:
		set_is_used(true)
	else:
		set_is_used(false)

@warning_ignore("unused_parameter")
func _process(delta):
	if is_used:
		# 跟随鼠标移动
		position = get_global_mouse_position()

func set_is_used(value):
	is_used = value
	if is_used:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hammer_once()

## 锤击一次
func hammer_once():
	animation_player.stop()
	animation_player.play("Hammer_whack_zombie")
	SoundManager.play_other_SFX("swing")

	hammer_zombie()

## 创建阳光
func spawn_sun(create_global_position:Vector2):
	var new_sun = SceneRegistry.SUN.instantiate()
	if new_sun is Sun:

		new_sun.init_sun(sun_value, Global.main_game.suns.to_local(create_global_position))
		Global.main_game.suns.add_child(new_sun)

		## 控制阳光下落
		var tween = create_tween()

		var center_y : float = -15
		var target_y : float = 45
		tween.tween_property(new_sun, "position:y", center_y, 0.3).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_sun, "position:y", target_y, 0.6).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		var tween2 = create_tween()
		tween2.tween_property(new_sun, "position:x", randf_range(-30, 30), 0.9).as_relative()

		tween2.finished.connect(new_sun.on_sun_tween_finished)

## 对僵尸造成锤子伤害
func hammer_zombie():
	##INFO:安卓适配 等待两物理帧后锤击，可以获取当前位置僵尸碰撞体，
	if OS.get_name() == "Android":
		position = get_global_mouse_position()
		await get_tree().physics_frame
		await get_tree().physics_frame
	var overlapping_areas = area_2d.get_overlapping_areas()
	## 如果为空，直接退出该函数
	if overlapping_areas.is_empty():
		return
	## 选择最左边的僵尸area
	var area_be_choosed :Area2D = null
	# 遍历所有重叠的区域
	for area in overlapping_areas:
		if area_be_choosed == null:
			area_be_choosed = area
		else:
			if area.global_position.x < area_be_choosed.global_position.x:
				area_be_choosed = area
	var zombie_be_choosed:Zombie000Base = area_be_choosed.owner
	var global_position_zombie_be_choosed = zombie_be_choosed.global_position + Vector2(0,-100)

	## 锤子攻击僵尸,使用锤子攻击方法
	var zombie_is_death = zombie_be_choosed.be_attacked_hammer(1800)
	SoundManager.play_other_SFX("bonk")

	## 锤击僵尸掉落阳光
	if zombie_is_death:
		var curr_pred_value = randi_range(1,100)

		if curr_pred_value <= pred_sun:
			for i in range(3):
				spawn_sun(global_position_zombie_be_choosed)

	## 锤击僵尸特效
	var new_pow :Sprite2D= pow_effect.duplicate()
	new_pow.visible = true
	new_pow.global_position = global_position
	new_pow.z_as_relative = false
	new_pow.z_index = 951
	get_parent().add_child(new_pow)
	await get_tree().create_timer(0.5).timeout
	new_pow.queue_free()

