extends Node2D
class_name Hammer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var pow_effect: Sprite2D = $Pow

const COOL_TIME := 60.0

enum State { IDLE, ACTIVE, COOLDOWN }

var state := State.IDLE
var _cool_timer := 0.0
var _hit_this_strike := false


func _ready() -> void:
	visible = false
	area_2d.monitoring = false
	EventBus.subscribe("main_game_click_hammer", _on_activate_request)
	EventBus.subscribe("main_game_exit_hammer", force_deactivate)


func _process(delta: float) -> void:
	match state:
		State.ACTIVE:
			position = get_global_mouse_position()
		State.COOLDOWN:
			_cool_timer -= delta
			if _cool_timer <= 0.0:
				state = State.IDLE


func _on_activate_request() -> void:
	if state == State.COOLDOWN:
		if Global.hammer_no_cooldown:
			state = State.IDLE
		else:
			SoundManager.play_other_SFX("buzzer")
			return
	elif state != State.IDLE:
		return
	## 退出手持管理器状态(避免手套/铲子重叠)
	EventBus.push_event("main_game_exit_hand_status")
	state = State.ACTIVE
	visible = true
	area_2d.monitoring = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event: InputEvent) -> void:
	if state != State.ACTIVE:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_do_strike()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_deactivate(false)


## 锤击: 播放动画+音效+立即检测, 无间隔可连续锤
func _do_strike() -> void:
	_hit_this_strike = false
	## 播放锤击动画
	animation_player.stop()
	animation_player.play("Hammer_whack_zombie")
	SoundManager.play_other_SFX("swing")
	## 立即检测重叠的僵尸
	_detect_and_hit()
	## 小游戏模式无冷却可继续锤, 其他模式锤到僵尸退出并冷却
	if _hit_this_strike and not _is_mini_game_mode():
		_deactivate(true)


## 检测并攻击僵尸
func _detect_and_hit() -> void:
	if not area_2d.monitoring:
		return
	var overlapping = area_2d.get_overlapping_areas()
	if overlapping.is_empty():
		return
	## 选最左边的僵尸
	var closest: Area2D = null
	for area in overlapping:
		if closest == null or area.global_position.x < closest.global_position.x:
			closest = area
	if closest == null:
		return
	var zombie: Zombie000Base = closest.owner
	if not is_instance_valid(zombie) or zombie.is_death:
		return
	## 锤击攻击
	zombie.be_attacked_hammer(1800)
	SoundManager.play_other_SFX("bonk")
	_hit_this_strike = true
	## 特效
	var new_pow: Sprite2D = pow_effect.duplicate()
	new_pow.visible = true
	new_pow.global_position = global_position
	new_pow.z_as_relative = false
	new_pow.z_index = 951
	get_parent().add_child(new_pow)
	get_tree().create_timer(0.5).timeout.connect(new_pow.queue_free)


func _deactivate(enter_cooldown: bool) -> void:
	if state != State.ACTIVE:
		return
	state = State.COOLDOWN if enter_cooldown else State.IDLE
	visible = false
	area_2d.monitoring = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if is_instance_valid(Global.main_game):
		var ui = Global.main_game.get_node_or_null("%UIHammer")
		if ui:
			if enter_cooldown:
				ui.start_cooldown()
			else:
				## 取消模式, 图标恢复
				ui.hammer_icon.visible = true


## 外部强制退出(切换工具时调用)
func force_deactivate() -> void:
	if state == State.ACTIVE:
		_deactivate(false)


func is_on_cooldown() -> bool:
	return state == State.COOLDOWN


func _is_mini_game_mode() -> bool:
	if not is_instance_valid(Global.main_game):
		return false
	return Global.main_game.game_para.is_hammer
