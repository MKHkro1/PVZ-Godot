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
## 投手抛物线瞄准点(相对 hurt_box; 正值=更靠下)
const PULT_AIM_OFFSET := Vector2(0, 90)
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
const COCKPIT_BODY1_POS := Vector2(528.5, 154.032)
const COCKPIT_BODY1_ROT := -0.286234
const COCKPIT_NECK_POS := Vector2(553.6, 170.46399)
const COCKPIT_NECK_ROT := -0.033161
const COCKPIT_SCALE := Vector2(0.796, 0.796)
const COCKPIT_IDLE_ANIM := "Zombie_boss_idle"
const HEAD_ANIM_PREFIX := "Zombie_boss_head"
const HEAD_PARTS: Array[String] = [
	"Boss_head",
	"Boss_jaw",
	"Boss_innerjaw",
	"Boss_mouthglow",
	"Boss_mouthglow_red",
	"Boss_eyeglow",
	"Boss_eyeglow_red",
	"Boss_head2",
	"Boss_antenna",
]
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
## 低头吐球后 idle 停留(给植物输出窗口)
const HEAD_IDLE_DWELL := 4.0
## 吐球冷却
const HEAD_COOLDOWN := 20.0
## 踩踏最右侧列数(有植物才触发)
const STOMP_COL_COUNT := 4
## 阶段休息时间(Stage1/2/3) — 给植物更多输出窗口
const REST_BY_STAGE:Array[float] = [8.0, 7.0, 6.0]
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
var head_cooldown := HEAD_COOLDOWN				## 吐球冷却计时
var is_busy := false					## 正在播放攻击动画
var is_dead := false
var spawn_early_rounds := 2				## 前N轮用初级池
var _head_attack_lane := 2
var damage_level := 0
var _head_glow_fire := true
var _head_glow_active := false
var is_head_vulnerable := false
var _is_frozen := false
var _freeze_timer: Timer
var _ice_effect: Node2D
var _anim_speed_backup: Dictionary = {}
var _hurt_area: Area2D
var _detect_area: Area2D

## 抛物线子弹追踪用(对齐 Character000Base.hurt_box_component)
var hurt_box_component: Area2D:
	get:
		return _hurt_area

## 对齐 Character000Base.is_death
var is_death: bool:
	get:
		return is_dead

func _enter_tree() -> void:
	## 场景默认是 idle 驾驶舱姿态; 进场前先全隐藏, 避免 add_child 到 _ready 之间闪一帧
	_hide_all_sprite_parts()


func _hide_all_sprite_parts() -> void:
	for child in get_children():
		if child is Sprite2D:
			(child as Sprite2D).visible = false


func _ready() -> void:
	## 绘制层级高于背景与普通单位
	z_index = 260
	_setup_hurt_box()
	_setup_detect_box()
	_cache_anim_players()
	_apply_cockpit_textures()
	EventBus.subscribe("ice_all_zombie", _on_ice_all_zombie)
	EventBus.subscribe("jalapeno_bomb_lane_zombie", _on_jalapeno_lane)
	_play_enter()

func _setup_hurt_box() -> void:
	var area := Area2D.new()
	area.name = "HurtBoxReal"
	area.collision_layer = 512
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = false
	## Area 中心对齐头部, 子弹瞄准/碰撞用 global_position
	area.position = REANIM_ANCHOR + Vector2(-80.0, -120.0)
	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(200.0, 280.0)
	shape_node.shape = rect
	area.add_child(shape_node)
	add_child(area)
	## 运行时节点必须手动设 owner, 子弹/射线用 area.owner 识别僵王
	area.owner = self
	_hurt_area = area

func _setup_detect_box() -> void:
	var area := Area2D.new()
	area.name = "HurtBoxDetection"
	area.collision_layer = 4
	area.collision_mask = 0
	area.monitorable = false
	area.monitoring = false
	## 覆盖全行高度, 方便植物水平射线重叠检测
	area.position = REANIM_ANCHOR + Vector2(-40.0, 40.0)
	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(180.0, 520.0)
	shape_node.shape = rect
	area.add_child(shape_node)
	add_child(area)
	area.owner = self
	_detect_area = area

func _set_head_vulnerable(v: bool) -> void:
	is_head_vulnerable = v
	if _hurt_area != null:
		_hurt_area.monitorable = v
		var mon := _hurt_area.monitoring
		_hurt_area.monitoring = not mon
		_hurt_area.monitoring = mon
	if _detect_area != null:
		_detect_area.monitorable = v
	## 通知植物重新判定攻击目标
	EventBus.push_event("zomboss_head_vulnerable", [v])

func _cache_anim_players() -> void:
	for child in get_children():
		if child is AnimationPlayer:
			var player := child as AnimationPlayer
			for anim_name in player.get_animation_list():
				_anim_players[anim_name] = player
				## 头部动画保留 cockpit 轨道(neck/upperbody 跟随头部运动)
				if not anim_name.begins_with(HEAD_ANIM_PREFIX):
					_strip_cockpit_texture_tracks(player.get_animation(anim_name))
	if _anim_players.is_empty():
		push_error("僵王: 未找到 AnimationPlayer")


## 驾驶舱 body1/neck 全部由脚本控制; 剥离所有相关动画轨道(含空 key 轨道, 避免 Godot 报错)
func _strip_cockpit_texture_tracks(anim: Animation) -> void:
	if anim == null:
		return
	for i in range(anim.get_track_count() - 1, -1, -1):
		var track_path := str(anim.track_get_path(i))
		if track_path.begins_with("Boss_body1:") or track_path.begins_with("Boss_neck:"):
			anim.remove_track(i)


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
	if player == null or not player.has_animation(anim_name):
		return
	var anim := player.get_animation(anim_name)
	anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	## 先让新动画第 0 帧立即生效, 再停其它播放器, 避免部件停在上一姿态闪一帧
	player.play(anim_name)
	player.seek(0.0, true)
	for child in get_children():
		if child is AnimationPlayer and child != player:
			(child as AnimationPlayer).stop()
	_active_anim_player = player
	_apply_cockpit_textures()
	_apply_damage_look()
	_post_anim_switch_fixup(anim_name)


func _snap_cockpit_pose() -> void:
	var body1 := get_node_or_null("Boss_body1") as Sprite2D
	if body1 != null:
		body1.visible = true
		body1.position = COCKPIT_BODY1_POS
		body1.rotation = COCKPIT_BODY1_ROT
		body1.scale = COCKPIT_SCALE
	var neck := get_node_or_null("Boss_neck") as Sprite2D
	if neck != null:
		neck.visible = true
		neck.position = COCKPIT_NECK_POS
		neck.rotation = COCKPIT_NECK_ROT
		neck.scale = COCKPIT_SCALE


func _hide_head_parts() -> void:
	for part_name in HEAD_PARTS:
		var spr := get_node_or_null(part_name) as Sprite2D
		if spr != null:
			spr.visible = false


func _hide_cockpit_parts() -> void:
	var body1 := get_node_or_null("Boss_body1") as Sprite2D
	if body1 != null:
		body1.visible = false
	var neck := get_node_or_null("Boss_neck") as Sprite2D
	if neck != null:
		neck.visible = false


func _post_anim_switch_fixup(anim_name: String) -> void:
	if anim_name == COCKPIT_IDLE_ANIM:
		_hide_cockpit_parts()
		_hide_head_parts()
	elif anim_name == "Zombie_boss_enter":
		## enter 第 0 帧应是整机入画(body2 可见、驾驶舱隐藏), 不能套用 idle 驾驶舱 snap
		_hide_cockpit_parts()
		_hide_head_parts()
		if is_instance_valid(_active_anim_player):
			_active_anim_player.seek(0.0, true)
	elif anim_name.begins_with(HEAD_ANIM_PREFIX):
		## 头部动画保留 cockpit 轨道, neck/upperbody 跟随头部运动
		var body1 := get_node_or_null("Boss_body1") as Sprite2D
		if body1 != null:
			body1.visible = true
		var neck := get_node_or_null("Boss_neck") as Sprite2D
		if neck != null:
			neck.visible = true
	else:
		_hide_cockpit_parts()
		_hide_head_parts()


func _apply_damage_look() -> void:
	_apply_cockpit_textures()
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


func _apply_cockpit_textures() -> void:
	var neck := get_node_or_null("Boss_neck") as Sprite2D
	if neck != null:
		neck.texture = TEX_NECK
	var body1 := get_node_or_null("Boss_body1") as Sprite2D
	if body1 != null:
		body1.texture = TEX_UPPERBODY


func _play_enter() -> void:
	is_busy = true
	_play_anim("Zombie_boss_enter")
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)

func _physics_process(delta: float) -> void:
	if is_dead or _is_frozen:
		return
	if _head_glow_active:
		_apply_head_glow(_head_glow_fire)
	if is_resting and not is_busy:
		rest_timer += delta
		head_cooldown -= delta
		if head_cooldown <= 0.0:
			head_cooldown = HEAD_COOLDOWN
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
			head_cooldown = HEAD_COOLDOWN
			_do_head_attack()
		elif not action_queue.is_empty():
			_run_next_action()
		else:
			is_resting = true

## ===== 动作队列(参考 HE SetStateList 规则) =====
func _build_round_queue() -> void:
	action_queue.clear()
	round_count += 1
	action_queue.append("Spawn")
	## stage>=2 且偶数轮才考虑踩踏/天降/RV, 降低压迫频率
	if stage >= 2 and round_count % 2 == 0:
		var stomp_rows := _rows_with_plants_in_stomp_range()
		if not stomp_rows.is_empty():
			action_queue.append("Stomp")
		elif round_count % 4 == 0:
			if randf() < 0.55:
				action_queue.append("BungeeDrop")
			else:
				action_queue.append("RV")
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

## ===== 踩踏: 最右侧4列碾压(有植物才触发) =====
func _do_stomp() -> void:
	var rows := _rows_with_plants_in_stomp_range()
	if rows.is_empty():
		return
	is_busy = true
	var row: int = rows.pick_random()
	_play_anim("Zombie_boss_stomp_%d" % clampi(row + 1, 1, 4))
	## 踩踏落地帧(约55%)碾压右侧4列
	get_tree().create_timer(_curr_anim_length() * 0.55).timeout.connect(func():
		if not is_dead:
			_smash_row_right_cols(row))
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)


func _stomp_col_start(col_count: int) -> int:
	return maxi(0, col_count - STOMP_COL_COUNT)


func _smash_row_right_cols(row: int) -> void:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	if row >= cells.size():
		return
	SoundManager.play_character_SFX("gargantuar_thump")
	var start_col := _stomp_col_start(cells[row].size())
	for c in range(start_col, cells[row].size()):
		cells[row][c].plant_be_flattened()

## ===== 天降蹦极僵尸(enter→投放蹦极→leave) =====
func _do_bungee_drop() -> void:
	is_busy = true
	_play_anim("Zombie_boss_bungee_1_enter")
	var targets := _plant_cells_for_bungee(3)
	get_tree().create_timer(T_BUNGEE_IN * 0.55).timeout.connect(func():
		if is_dead:
			return
		for cell in targets:
			if is_instance_valid(cell):
				_spawn_bungee_at_cell(cell)
	)
	await _active_anim_player.animation_finished
	_play_anim("Zombie_boss_bungee_1_leave")
	await _active_anim_player.animation_finished
	is_busy = false
	_apply_damage_look()
	_play_anim("Zombie_boss_idle", true)


func _plant_cells_for_bungee(max_n: int) -> Array[PlantCell]:
	var cells: Array[PlantCell] = Global.main_game.plant_cell_manager.get_cell_have_plant()
	cells.shuffle()
	var out: Array[PlantCell] = []
	for cell in cells:
		## 只偷前半场, 与原版蹦极落点接近
		if cell.row_col.y <= 4:
			out.append(cell)
		if out.size() >= max_n:
			break
	return out


func _spawn_bungee_at_cell(plant_cell: PlantCell) -> void:
	var zm = Global.main_game.zombie_manager
	if zm == null:
		return
	var lane: int = plant_cell.row_col.x
	if lane < 0 or lane >= zm.all_zombie_rows.size():
		return
	var row_node = zm.all_zombie_rows[lane]
	var init_para: Dictionary = {
		Zombie000Base.E_ZInitAttr.CharacterInitType: Character000Base.E_CharacterInitType.IsNorm,
		Zombie000Base.E_ZInitAttr.Lane: lane,
	}
	var pos := Vector2(
		plant_cell.global_position.x + plant_cell.size.x * 0.5,
		row_node.zombie_create_position.global_position.y
	)
	zm.create_norm_zombie(
		Global.ZombieType.Z021Bungi,
		row_node,
		init_para,
		pos,
		GlobalUtils.create_bungi.bind(plant_cell)
	)
	SoundManager.play_character_SFX("bungee_scream")

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
		_finish_head_attack(false)
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
		_finish_head_attack(false)
		return
	## 吐球后低头 idle 停留, 给植物输出时间
	_play_anim("Zombie_boss_head_idle", true)
	await get_tree().create_timer(HEAD_IDLE_DWELL).timeout
	if is_dead:
		_finish_head_attack(false)
		return
	_play_anim("Zombie_boss_head_leave")
	await _active_anim_player.animation_finished
	_finish_head_attack(true)


func _finish_head_attack(play_body_idle: bool) -> void:
	_head_glow_active = false
	_clear_head_glow()
	_set_head_vulnerable(false)
	is_busy = false
	if not is_dead and play_body_idle:
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


## 寒冰菇: 冻结僵王行动
func _on_ice_all_zombie(time_ice = null, _time_decelerate = null) -> void:
	if is_dead:
		return
	var t := 4.0
	if time_ice is float or time_ice is int:
		t = float(time_ice)
	_apply_ice_freeze(t)


func _apply_ice_freeze(time: float) -> void:
	_is_frozen = true
	modulate = Color(0.55, 0.82, 1.05)
	_pause_all_animations()
	if is_instance_valid(_ice_effect):
		_ice_effect.queue_free()
	_ice_effect = SceneRegistry.ICE_EFFECT.instantiate()
	add_child(_ice_effect)
	if _ice_effect.has_method("start_ice_effect"):
		_ice_effect.start_ice_effect(time)
	if _freeze_timer == null:
		_freeze_timer = Timer.new()
		_freeze_timer.one_shot = true
		_freeze_timer.timeout.connect(_on_ice_freeze_end)
		add_child(_freeze_timer)
	_freeze_timer.start(maxf(time, 0.1))


func _pause_all_animations() -> void:
	_anim_speed_backup.clear()
	for child in get_children():
		if child is AnimationPlayer:
			var player := child as AnimationPlayer
			_anim_speed_backup[player] = player.speed_scale
			player.speed_scale = 0.0


func _resume_all_animations() -> void:
	for child in get_children():
		if child is AnimationPlayer:
			var player := child as AnimationPlayer
			player.speed_scale = _anim_speed_backup.get(player, 1.0)
	_anim_speed_backup.clear()


func _on_ice_freeze_end() -> void:
	_is_frozen = false
	_resume_all_animations()
	if is_instance_valid(_ice_effect):
		_ice_effect.queue_free()
		_ice_effect = null
	if not is_dead:
		modulate = Color.WHITE


## 火爆辣椒: 头部可攻击时造成伤害
func _on_jalapeno_lane(_lane = null) -> void:
	if is_dead or not is_head_vulnerable:
		return
	be_attacked_bullet(1800, Global.AttackMode.Penetration, false, true)

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
	for r in range(mini(5, cells.size())):
		if _row_has_plants_in_stomp_cols(r):
			out.append(r)
	return out


func _row_has_plants_in_stomp_cols(row: int) -> bool:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	if row >= cells.size():
		return false
	var start_col := _stomp_col_start(cells[row].size())
	for c in range(start_col, cells[row].size()):
		if cells[row][c].get_curr_plant_num() > 0:
			return true
	return false

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
