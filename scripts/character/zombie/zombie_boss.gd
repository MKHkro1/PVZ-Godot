extends Node2D
class_name ZombossBoss
## 僵王博士 Boss —— 冒险模式 5-10 最终关 & 小游戏
## 机制忠实原版/HE: 休息计时→动作队列(投放/踩踏/RV/天降), 头部吐火球/冰球独立循环
## 血量40000, 阶段阈值80%/50%/10%(提速), 死亡后爆炸→奖杯

signal boss_died

const HP_MAX := 40000.0
const BALL_DAMAGE := 1800
## reanim 部件局部锚点(Boss_body2/腿等), 场景原点与此错位 ~660px
const REANIM_ANCHOR_X := 660.0
const REANIM_ANCHOR := Vector2(REANIM_ANCHOR_X, -100.0)
## 手臂投放点 / 吐球 X(相对机体原点)
const SPAWN_MARKER := Vector2(REANIM_ANCHOR_X - 40.0, -60.0)
const BALL_MARKER := Vector2(REANIM_ANCHOR_X - 55.0, -90.0)
const TEX_EYEGLOW := preload("res://assets/reanim/Zombie_boss_eyeglow.png")
const TEX_MOUTHGLOW := preload("res://assets/reanim/Zombie_boss_mouthglow.png")
const TEX_EYEGLOW_RED := preload("res://assets/reanim/Zombie_boss_eyeglow_red.png")
const TEX_EYEGLOW_BLUE := preload("res://assets/reanim/Zombie_boss_eyeglow_blue.png")
const TEX_MOUTHGLOW_RED := preload("res://assets/reanim/Zombie_boss_mouthglow_red.png")
const TEX_MOUTHGLOW_BLUE := preload("res://assets/reanim/Zombie_boss_mouthglow_blue.png")
const TEX_NECK := preload("res://assets/reanim/Zombie_boss_neck.png")
const TEX_UPPERBODY := preload("res://assets/reanim/Zombie_boss_upperbody.png")
## 破损阶段贴图(原版: 8000/20000 伤害后切换)
const DAMAGE_PARTS: Dictionary = {
	"Boss_head": [
		preload("res://assets/reanim/Zombie_boss_head.png"),
		preload("res://assets/reanim/Zombie_boss_head_damage1.png"),
		preload("res://assets/reanim/Zombie_boss_head_damage2.png"),
	],
	"Boss_jaw": [
		preload("res://assets/reanim/Zombie_boss_jaw.png"),
		preload("res://assets/reanim/Zombie_boss_jaw_damage1.png"),
		preload("res://assets/reanim/Zombie_boss_jaw_damage2.png"),
	],
	"Boss_outerleg_foot": [
		preload("res://assets/reanim/Zombie_boss_foot.png"),
		preload("res://assets/reanim/Zombie_boss_foot_damage1.png"),
		preload("res://assets/reanim/Zombie_boss_foot_damage2.png"),
	],
	"Boss_outerarm_hand": [
		preload("res://assets/reanim/Zombie_boss_outerarm_hand.png"),
		preload("res://assets/reanim/Zombie_boss_outerarm_hand_damage1.png"),
		preload("res://assets/reanim/Zombie_boss_outerarm_hand_damage2.png"),
	],
	"Boss_outerarm_thumb1": [
		preload("res://assets/reanim/Zombie_boss_outerarm_thumb1.png"),
		preload("res://assets/reanim/Zombie_boss_outerarm_thumb_damage1.png"),
		preload("res://assets/reanim/Zombie_boss_outerarm_thumb_damage2.png"),
	],
	"Boss_outerarm_thumb2": [
		preload("res://assets/reanim/Zombie_boss_outerarm_thumb2.png"),
		preload("res://assets/reanim/Zombie_boss_outerarm_thumb_damage1.png"),
		preload("res://assets/reanim/Zombie_boss_outerarm_thumb_damage2.png"),
	],
}
## 各动画时长(与 tres 一致)
const T_ENTER := 3.25
const T_IDLE := 1.166667
const T_DEATH := 8.833333
const T_RV := 3.083333
const T_BUNGEE_IN := 2.0
const T_BUNGEE_OUT := 1.416667
const T_HEAD_ENTER := 4.666667
const T_HEAD_LEAVE := 3.666667
## 阶段休息时间(Stage1/2/3)
const REST_BY_STAGE:Array[float] = [5.0, 4.5, 4.0]
## 投放间隔(Stage1/2/3)
const SPAWN_GAP_BY_STAGE:Array[float] = [3.5, 3.0, 2.6]
## 初级出怪池(前两轮) / 高级池
const POOL_EARLY:Array[int] = [Global.ZombieType.Z001Norm, Global.ZombieType.Z003Cone, Global.ZombieType.Z005Bucket]
const POOL_LATE:Array[int] = [
	Global.ZombieType.Z006Paper, Global.ZombieType.Z007ScreenDoor, Global.ZombieType.Z004PoleVaulter,
	Global.ZombieType.Z008Football, Global.ZombieType.Z016Jackbox, Global.ZombieType.Z022Ladder,
	Global.ZombieType.Z024Gargantuar, Global.ZombieType.Z013Zamboni, Global.ZombieType.Z023Catapult,
]

var _anim_players: Dictionary = {}
var _active_anim_player: AnimationPlayer

var curr_hp := HP_MAX
var stage := 1						## 当前阶段 1..3
var is_resting := true
var rest_timer := 0.0
var rest_time := REST_BY_STAGE[0]
var round_count := 0					## 已完成动作轮数
var action_queue: Array[String] = []		## 本轮待执行动作
var head_cooldown := 10.0				## 吐球冷却计时
var is_busy := false					## 正在播放攻击动画
var is_dead := false
var spawn_early_rounds := 2				## 前N轮用初级池
var _head_attack_lane := 2
var damage_level := 0
var _head_glow_fire := true
var _head_glow_active := false
var is_head_vulnerable := false
var _hurt_area: Area2D

func _ready() -> void:
	## 绘制层级高于背景与普通单位
	z_index = 260
	_setup_hurt_box()
	_cache_anim_players()
	_apply_neck_texture()
	_play_enter()

func _setup_hurt_box() -> void:
	var area := Area2D.new()
	area.name = "HurtBoxReal"
	area.collision_layer = 512
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = false
	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(160.0, 320.0)
	shape_node.shape = rect
	shape_node.position = REANIM_ANCHOR + Vector2(-80.0, -60.0)
	area.add_child(shape_node)
	add_child(area)
	_hurt_area = area

func _set_head_vulnerable(v: bool) -> void:
	is_head_vulnerable = v
	if _hurt_area == null:
		return
	_hurt_area.monitorable = v
	var mon := _hurt_area.monitoring
	_hurt_area.monitoring = not mon
	_hurt_area.monitoring = mon

func _cache_anim_players() -> void:
	for child in get_children():
		if child is AnimationPlayer:
			var player := child as AnimationPlayer
			for anim_name in player.get_animation_list():
				_anim_players[anim_name] = player
	if _anim_players.is_empty():
		push_error("僵王: 未找到 AnimationPlayer")


func _get_anim_player(anim_name: String) -> AnimationPlayer:
	if _anim_players.has(anim_name):
		return _anim_players[anim_name]
	var node_name := "Anim_" + anim_name
	var player := get_node_or_null(node_name) as AnimationPlayer
	if player != null:
		_anim_players[anim_name] = player
		return player
	push_warning("僵王: 缺少动画 %s" % anim_name)
	return _active_anim_player if _active_anim_player != null else get_child(0) as AnimationPlayer


func _play_anim(anim_name: String, loop := false) -> void:
	var player := _get_anim_player(anim_name)
	if player == null:
		return
	_active_anim_player = player
	if player.has_animation(anim_name):
		var anim := player.get_animation(anim_name)
		if loop:
			anim.loop_mode = Animation.LOOP_LINEAR
		player.play(anim_name)
	_update_cockpit_visibility(anim_name)


func _update_cockpit_visibility(_anim_name: String) -> void:
	pass


func _apply_damage_look() -> void:
	_apply_neck_texture()
	for node_name in DAMAGE_PARTS:
		var spr := get_node_or_null(node_name) as Sprite2D
		if spr == null:
			continue
		var texs: Array = DAMAGE_PARTS[node_name]
		spr.texture = texs[mini(damage_level, texs.size() - 1)]


func _damage_level_from_hp() -> int:
	if curr_hp <= 20000.0:
		return 2
	if curr_hp <= 32000.0:
		return 1
	return 0


func _apply_neck_texture() -> void:
	var neck := get_node_or_null("Boss_neck") as Sprite2D
	if neck != null:
		neck.texture = TEX_NECK


func _apply_upperbody_texture() -> void:
	var body1 := get_node_or_null("Boss_body1") as Sprite2D
	if body1 != null and body1.visible:
		body1.texture = TEX_UPPERBODY


func _play_enter() -> void:
	is_busy = true
	_play_anim("Zombie_boss_enter")
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if _head_glow_active:
		_apply_head_glow(_head_glow_fire)
	_apply_neck_texture()
	_apply_upperbody_texture()
	if is_resting and not is_busy:
		rest_timer += delta
		head_cooldown -= delta
		if head_cooldown <= 0.0:
			head_cooldown = 10.0
			_do_head_attack()
			return
		if rest_timer >= rest_time:
			rest_timer = 0.0
			_build_round_queue()
			is_resting = false
			_run_next_action()
	elif not is_resting and not is_busy:
		head_cooldown -= delta
		if head_cooldown <= 0.0:
			head_cooldown = 10.0
			_do_head_attack()
		elif not action_queue.is_empty():
			_run_next_action()
		else:
			is_resting = true

## ===== 动作队列(参考 HE SetStateList 规则) =====
func _build_round_queue() -> void:
	action_queue.clear()
	round_count += 1
	## stage>1: 有植物可踩则优先踩踏; 75%天降 / 25%RV
	if stage > 1:
		var stomp_rows := _rows_with_plants_in_stomp_range()
		if not stomp_rows.is_empty():
			action_queue.append("Stomp")
		if randf() < 0.75:
			action_queue.append("BungeeDrop")
		else:
			action_queue.append("RV")
	action_queue.append("Spawn")
	rest_time = REST_BY_STAGE[stage - 1]

func _run_next_action() -> void:
	if action_queue.is_empty():
		is_resting = true
		return
	var act: String = action_queue.pop_front()
	match act:
		"Spawn":
			_do_spawn()
		"Stomp":
			_do_stomp()
		"BungeeDrop":
			_do_bungee_drop()
		"RV":
			_do_rv_attack()

## ===== 投放僵尸(手臂掉落, 每次一只) =====
func _do_spawn() -> void:
	is_busy = true
	var row := randi_range(0, 4)
	var pool := POOL_EARLY if round_count <= spawn_early_rounds else POOL_LATE
	_play_anim("Zombie_boss_spawn_%d" % (row + 1))
	get_tree().create_timer(0.85).timeout.connect(func():
		if not is_dead:
			_spawn_zombie(_pick_spawn_type(pool), row))
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

func _pick_spawn_type(pool: Array[int]) -> int:
	## 高级池中巨人/冰车/投石车为稀有项
	for i in range(pool.size(), 0, -1):
		var t: int = pool[randi() % pool.size()]
		if t in [Global.ZombieType.Z024Gargantuar, Global.ZombieType.Z013Zamboni, Global.ZombieType.Z023Catapult]:
			if randf() < 0.75:
				continue
		return t
	return Global.ZombieType.Z001Norm

func _spawn_zombie(ztype: int, row: int, at_pos := Vector2.ZERO) -> void:
	var zm = Global.main_game.zombie_manager
	if zm == null or zm.all_zombie_rows.size() <= row:
		return
	var row_node = zm.all_zombie_rows[row]
	var pos := at_pos
	if pos == Vector2.ZERO:
		pos = Vector2(global_position.x + SPAWN_MARKER.x, _row_y(row))
	var init_para: Dictionary = {
		Zombie000Base.E_ZInitAttr.CharacterInitType: Character000Base.E_CharacterInitType.IsNorm,
		Zombie000Base.E_ZInitAttr.Lane: row,
	}
	zm.create_norm_zombie(ztype, row_node, init_para, pos)

## ===== 踩踏: 整行碾压 =====
func _do_stomp() -> void:
	is_busy = true
	var rows := _rows_with_plants_in_stomp_range()
	var row: int = rows.pick_random() if not rows.is_empty() else 2
	_play_anim("Zombie_boss_stomp_%d" % clampi(row + 1, 1, 4))
	## 踩踏落地帧(约55%)整行压扁
	get_tree().create_timer(_curr_anim_length() * 0.55).timeout.connect(func():
		if not is_dead:
			_smash_row(row))
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

func _smash_row(row: int) -> void:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	if row >= cells.size():
		return
	SoundManager.play_character_SFX("gargantuar_thump")
	for cell in cells[row]:
		cell.plant_be_flattened()

## ===== 天降(替代蹦极: 直接空投僵尸到有植物的格子旁) =====
func _do_bungee_drop() -> void:
	is_busy = true
	_play_anim("Zombie_boss_bungee_1_enter")
	var targets := _planted_cells_for_drop(3)
	get_tree().create_timer(T_BUNGEE_IN * 0.6).timeout.connect(func():
		if is_dead:
			return
		for c in targets:
			var pool := POOL_LATE if stage >= 2 else POOL_EARLY
			var cells = Global.main_game.plant_cell_manager.all_plant_cells
			var drop_pos := Vector2(c.x * 80.0 + 45.0 - 160.0, _row_y(c.y))
			if c.y < cells.size() and c.x < cells[c.y].size():
				drop_pos = cells[c.y][c.x].global_position + Vector2(40.0, 20.0)
			_spawn_zombie(_pick_spawn_type(pool), c.y, drop_pos)
	)
	await _active_anim_player.animation_finished
	_play_anim("Zombie_boss_bungee_1_leave")
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

## ===== RV 房车冲撞: 3x2 区域碾压 =====
func _do_rv_attack() -> void:
	is_busy = true
	_play_anim("Zombie_boss_RV_1")
	var target := _rv_target_cell()
	## 冲撞判定帧
	get_tree().create_timer(_curr_anim_length() * 0.5).timeout.connect(func():
		if not is_dead:
			_smash_area(target.x, target.y))
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

func _rv_target_cell() -> Vector2i:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	var candidates: Array[Vector2i] = []
	for r in range(cells.size()):
		for c in range(mini(5, cells[r].size())):
			var cell = cells[r][c]
			if cell.get_curr_plant_num() > 0 and r < cells.size() - 1:
				candidates.append(Vector2i(c, r))
	if candidates.is_empty():
		return Vector2i(2, 2)
	return candidates.pick_random()

func _smash_area(col: int, row: int) -> void:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	SoundManager.play_character_SFX("gargantuar_thump")
	for r in range(row, mini(row + 2, cells.size())):
		for c in range(maxi(col - 1, 0), mini(col + 2, cells[r].size())):
			cells[r][c].plant_be_flattened()

## ===== 头部吐球(火/冰各50%) =====
func _do_head_attack() -> void:
	if is_busy or is_dead:
		return
	is_busy = true
	_head_attack_lane = randi_range(0, 4)
	var is_fire := randf() > 0.5
	_head_glow_fire = is_fire
	_head_glow_active = true
	_apply_head_glow(is_fire)
	_play_anim("Zombie_boss_head_enter")
	await _active_anim_player.animation_finished
	if is_dead:
		return
	_set_head_vulnerable(true)
	_apply_head_glow(is_fire)
	_play_anim("Zombie_boss_head_attack_%d" % (_head_attack_lane + 1))
	## 出球帧(约40%)
	get_tree().create_timer(_curr_anim_length() * 0.4).timeout.connect(func():
		if not is_dead:
			_apply_head_glow(is_fire)
			_fire_ball(_head_attack_lane, is_fire))
	await _active_anim_player.animation_finished
	if is_dead:
		return
	_play_anim("Zombie_boss_head_leave")
	await _active_anim_player.animation_finished
	_head_glow_active = false
	_clear_head_glow()
	_set_head_vulnerable(false)
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

func _apply_head_glow(is_fire: bool) -> void:
	var mouth := get_node_or_null("Boss_mouthglow_red") as Sprite2D
	var eye := get_node_or_null("Boss_eyeglow_red") as Sprite2D
	if mouth != null:
		mouth.texture = TEX_MOUTHGLOW_RED if is_fire else TEX_MOUTHGLOW_BLUE
	if eye != null:
		eye.texture = TEX_EYEGLOW_RED if is_fire else TEX_EYEGLOW_BLUE

func _clear_head_glow() -> void:
	var mouth := get_node_or_null("Boss_mouthglow_red") as Sprite2D
	var eye := get_node_or_null("Boss_eyeglow_red") as Sprite2D
	if mouth != null:
		mouth.texture = TEX_MOUTHGLOW
	if eye != null:
		eye.texture = TEX_EYEGLOW

func _fire_ball(lane: int, is_fire: bool) -> void:
	var ball_scene: PackedScene = load("res://scenes/main_game_item/zomboss_ball.tscn")
	if ball_scene == null:
		return
	var ball = ball_scene.instantiate()
	ball.setup(self, lane, is_fire, BALL_DAMAGE)
	Global.main_game.add_child(ball)
	ball.global_position = Vector2(
		global_position.x + BALL_MARKER.x,
		_row_y(lane) - 52.0
	)

## ===== 受击(供植物子弹调用, 签名对齐 Character000Base) =====
func be_attacked_bullet(attack_value: int, _bullet_mode: Global.AttackMode = Global.AttackMode.Norm, _is_drop := true, _sfx := true) -> void:
	if is_dead or not is_head_vulnerable:
		return
	curr_hp -= attack_value
	body_flash()
	_update_stage()
	if curr_hp <= 0.0:
		_die()

func body_flash() -> void:
	modulate = Color(1.6, 1.2, 1.2)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.12)

func _update_stage() -> void:
	var new_dmg := _damage_level_from_hp()
	if new_dmg != damage_level:
		damage_level = new_dmg
		_apply_damage_look()
	var pct := curr_hp / HP_MAX
	if pct <= 0.10 and stage < 3:
		stage = 3
		rest_time = REST_BY_STAGE[2]
	elif pct <= 0.50 and stage < 2:
		stage = 2
		rest_time = REST_BY_STAGE[1]
	elif pct <= 0.80 and stage < 2:
		stage = 2
		rest_time = REST_BY_STAGE[1]

## ===== 死亡: 加速演出+爆炸闪烁 → 奖杯 =====
func _die() -> void:
	is_dead = true
	_set_head_vulnerable(false)
	is_busy = true
	var death_player := _get_anim_player("Zombie_boss_death")
	death_player.speed_scale = 1.5
	_play_anim("Zombie_boss_death")
	_explosion_sequence()
	await _active_anim_player.animation_finished
	death_player.speed_scale = 1.0
	EventBus.push_event("boss_defeated", [global_position])
	boss_died.emit()
	EventBus.push_event("create_trophy", [global_position])

func _explosion_sequence() -> void:
	for i in range(6):
		create_tween().tween_interval(0.9).finished.connect(func():
			if not is_instance_valid(self):
				return
			modulate = Color(2.0, 2.0, 2.0)
			SoundManager.play_character_SFX("gargantuar_thump")
			create_tween().tween_property(self, "modulate", Color.WHITE, 0.25))

## ===== 工具 =====
func _rows_with_plants_in_stomp_range() -> Array[int]:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	var out: Array[int] = []
	for r in range(mini(4, cells.size())):
		for cell in cells[r]:
			if cell.get_curr_plant_num() > 0:
				out.append(r)
				break
	return out

func _planted_cells_for_drop(max_n: int) -> Array[Vector2i]:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	var out: Array[Vector2i] = []
	for r in range(cells.size()):
		for c in range(cells[r].size()):
			if cells[r][c].get_curr_plant_num() > 0 and c <= 4:
				out.append(Vector2i(c, r))
	out.shuffle()
	return out.slice(0, max_n)

func _row_y(row: int) -> float:
	var zm = Global.main_game.zombie_manager
	if zm != null and row < zm.all_zombie_rows.size():
		return zm.all_zombie_rows[row].zombie_create_position.global_position.y
	return 282.0

func _curr_anim_length() -> float:
	if _active_anim_player == null or _active_anim_player.current_animation == "":
		return 1.0
	return _active_anim_player.current_animation_length
