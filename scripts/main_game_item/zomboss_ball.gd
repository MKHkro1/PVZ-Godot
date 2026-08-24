extends Node2D
class_name ZombossBall
## 僵王吐出的火球/冰球: 向左滚过草坪, 碾压压扁植物

var lane := 2
var is_fire := true
var damage := 1800
var boss_ref: ZombossBoss
var speed := 20.0
var _dead := false
var _layers: Array[Sprite2D] = []
var _row_base_y := 0.0
const BALL_Y_OFFSET := 52.0

const BALL_SCALE := 1.05
const SHADOW_SCALE := 0.95
const TEX_SHADOW := preload("res://assets/reanim/Zombie_boss_icefire_shadow.png")

const FIRE_LAYERS: Array[Dictionary] = [
	{"tex": "res://assets/reanim/Zombie_boss_fireball_black.png", "scale": 1.0, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_fireball.png", "scale": 1.0, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_chunks.png", "scale": 1.0, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_multiply.png", "scale": 1.0, "blend": CanvasItemMaterial.BLEND_MODE_MUL},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_additive.png", "scale": 0.96, "blend": CanvasItemMaterial.BLEND_MODE_ADD},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_superglow.png", "scale": 0.92, "blend": CanvasItemMaterial.BLEND_MODE_ADD},
]

const ICE_LAYERS: Array[Dictionary] = [
	{"tex": "res://assets/reanim/Zombie_boss_iceball.png", "scale": 1.0, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal1.png", "scale": 1.0, "offset": Vector2(3, -4)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal2.png", "scale": 1.0, "offset": Vector2(-5, 3)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal3.png", "scale": 1.0, "offset": Vector2(4, 5)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_overlay.png", "scale": 1.0, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_multiply.png", "scale": 1.0, "blend": CanvasItemMaterial.BLEND_MODE_MUL},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_highlight.png", "scale": 0.92, "blend": CanvasItemMaterial.BLEND_MODE_ADD},
]


func setup(boss: ZombossBoss, p_lane: int, p_is_fire: bool, p_damage: int) -> void:
	boss_ref = boss
	lane = clampi(p_lane, 0, 4)
	is_fire = p_is_fire
	damage = p_damage
	_row_base_y = _get_row_base_y(lane)


func _ready() -> void:
	z_index = lane * 50 + 45
	modulate = Color.WHITE
	_build_layers()
	_update_y_on_slope()
	## 寒冰菇: 全场消火球
	EventBus.subscribe("ice_all_zombie", _on_ice_all)
	## 火爆辣椒: 本行消冰球
	EventBus.subscribe("jalapeno_bomb_lane_zombie", _on_jalapeno_lane)


func _build_layers() -> void:
	var shadow := Sprite2D.new()
	shadow.name = "Shadow"
	shadow.texture = TEX_SHADOW
	shadow.centered = true
	shadow.position = Vector2(0, 36)
	shadow.scale = Vector2(SHADOW_SCALE, SHADOW_SCALE)
	shadow.modulate = Color(1, 1, 1, 0.32)
	add_child(shadow)
	_layers.append(shadow)

	var specs := FIRE_LAYERS if is_fire else ICE_LAYERS
	for i in specs.size():
		var spec: Dictionary = specs[i]
		var s := Sprite2D.new()
		s.name = "Layer%d" % i
		s.texture = load(spec["tex"]) as Texture2D
		s.centered = true
		var sc: float = spec.get("scale", 1.0) * BALL_SCALE
		s.scale = Vector2(sc, sc)
		s.position = spec.get("offset", Vector2.ZERO) * BALL_SCALE
		if spec.has("blend"):
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = spec["blend"]
			s.material = mat
		add_child(s)
		_layers.append(s)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	global_position.x -= speed * delta
	_update_y_on_slope()
	for s in _layers:
		if s.name != "Shadow":
			s.rotation -= delta * 2.4
	_flatten_cells_at_x(global_position.x)
	if global_position.x < -150.0:
		_destroy()


func _get_row_base_y(row: int) -> float:
	var zm = Global.main_game.zombie_manager
	if zm != null and row < zm.all_zombie_rows.size():
		return zm.all_zombie_rows[row].zombie_create_position.global_position.y
	return 282.0


func _update_y_on_slope() -> void:
	var slope_y := 0.0
	if is_instance_valid(Global.main_game.main_game_slope):
		slope_y = Global.main_game.main_game_slope.get_all_slope_y(global_position.x)
	global_position.y = _row_base_y + slope_y - BALL_Y_OFFSET


var _last_smashed_col := -999


func _flatten_cells_at_x(x: float) -> void:
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	if lane >= cells.size():
		return
	var col := int(floor((x - 45.0) / 80.0))
	if col == _last_smashed_col:
		return
	if col < 0 or col >= cells[lane].size():
		return
	_last_smashed_col = col
	var cell = cells[lane][col]
	if cell.get_curr_plant_num() > 0:
		cell.plant_be_flattened()


## 寒冰菇冰冻全场 → 火球熄灭 (EventBus 传 time_ice, time_decelerate)
func _on_ice_all(_time_ice = null, _time_decelerate = null) -> void:
	if is_fire:
		_destroy()


## 火爆辣椒本行火焰 → 冰球融化
func _on_jalapeno_lane(bomb_lane: int = -1) -> void:
	if is_fire:
		return
	if bomb_lane == lane:
		_destroy()


func _destroy() -> void:
	if _dead:
		return
	_dead = true
	EventBus.unsubscribe("ice_all_zombie", _on_ice_all)
	EventBus.unsubscribe("jalapeno_bomb_lane_zombie", _on_jalapeno_lane)
	queue_free()
