extends Node2D
class_name ZombossBall
## 僵王吐出的火球/冰球: 多层贴图合体, 向左滚过草坪, 逐格碾压植物(1800)

var lane := 2
var is_fire := true
var damage := 1800
var boss_ref: ZombossBoss
var speed := 42.0
var _dead := false
var _layers: Array[Sprite2D] = []

const TEX_SHADOW := preload("res://assets/reanim/Zombie_boss_icefire_shadow.png")

const FIRE_LAYERS: Array[Dictionary] = [
	{"tex": "res://assets/reanim/Zombie_boss_fireball.png", "scale": 0.11, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_chunks.png", "scale": 0.11, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_multiply.png", "scale": 0.11, "blend": CanvasItemMaterial.BLEND_MODE_MUL},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_additive.png", "scale": 0.105, "blend": CanvasItemMaterial.BLEND_MODE_ADD},
	{"tex": "res://assets/reanim/Zombie_boss_fireball_superglow.png", "scale": 0.10, "blend": CanvasItemMaterial.BLEND_MODE_ADD},
]

const ICE_LAYERS: Array[Dictionary] = [
	{"tex": "res://assets/reanim/Zombie_boss_iceball.png", "scale": 0.11, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal1.png", "scale": 0.11, "offset": Vector2(2, -3)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal1.png", "scale": 0.09, "offset": Vector2(-2, 1)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal2.png", "scale": 0.11, "offset": Vector2(-4, 2)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_crystal3.png", "scale": 0.11, "offset": Vector2(3, 4)},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_overlay.png", "scale": 0.11, "offset": Vector2.ZERO},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_multiply.png", "scale": 0.11, "blend": CanvasItemMaterial.BLEND_MODE_MUL},
	{"tex": "res://assets/reanim/Zombie_boss_iceball_highlight.png", "scale": 0.10, "blend": CanvasItemMaterial.BLEND_MODE_ADD},
]


func setup(boss: ZombossBoss, p_lane: int, p_is_fire: bool, p_damage: int) -> void:
	boss_ref = boss
	lane = clampi(p_lane, 0, 4)
	is_fire = p_is_fire
	damage = p_damage


func _ready() -> void:
	z_index = lane * 50 + 45
	_build_layers()
	EventBus.subscribe("ice_all_zombie", _on_ice_all)
	EventBus.subscribe("jalapeno_bomb_effect_item_lane", _on_jala)
	EventBus.subscribe("jalapeno_bomb_effect_lane_zombie", _on_jala)


func _build_layers() -> void:
	var shadow := Sprite2D.new()
	shadow.name = "Shadow"
	shadow.texture = TEX_SHADOW
	shadow.centered = true
	shadow.position = Vector2(0, 12)
	shadow.scale = Vector2(0.10, 0.10)
	shadow.modulate = Color(1, 1, 1, 0.28)
	add_child(shadow)
	_layers.append(shadow)

	var specs := FIRE_LAYERS if is_fire else ICE_LAYERS
	for i in specs.size():
		var spec: Dictionary = specs[i]
		var s := Sprite2D.new()
		s.name = "Layer%d" % i
		s.texture = load(spec["tex"]) as Texture2D
		s.centered = true
		var sc: float = spec.get("scale", 0.11)
		s.scale = Vector2(sc, sc)
		s.position = spec.get("offset", Vector2.ZERO)
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
	for s in _layers:
		if s.name != "Shadow":
			s.rotation -= delta * 3.2
	_hit_cells_at_x(global_position.x)
	if global_position.x < -150.0:
		_destroy()


var _last_smashed_col := -999


func _hit_cells_at_x(x: float) -> void:
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
		for plant in cell.plant_in_cell.values():
			if is_instance_valid(plant):
				plant.be_attacked_bullet(damage, Global.AttackMode.Penetration, true, true)


func _on_ice_all(_payload = null) -> void:
	if is_fire:
		_destroy()


func _on_jala(_payload = null) -> void:
	if not is_fire:
		_destroy()


func _destroy() -> void:
	if _dead:
		return
	_dead = true
	queue_free()
