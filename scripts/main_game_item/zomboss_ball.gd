extends Node2D
class_name ZombossBall
## 僵王吐出的火球/冰球: 向左滚过草坪, 逐格碾压植物(1800)
## 原版克制: 火球被寒冰菇全场冰冻消除; 冰球被火爆辣椒消除

var lane := 2
var is_fire := true
var damage := 1800
var boss_ref: ZombossBoss
var speed := 260.0
var _dead := false

@onready var sprite: Sprite2D = $Sprite

const TEX_FIRE := preload("res://assets/image/particles/Zombie_boss_fireball_particles.png")
const TEX_ICE := preload("res://assets/image/particles/Zombie_boss_iceball_particles.png")

func setup(boss: ZombossBoss, p_lane: int, p_is_fire: bool, p_damage: int) -> void:
	boss_ref = boss
	lane = clampi(p_lane, 0, 4)
	is_fire = p_is_fire
	damage = p_damage

func _ready() -> void:
	z_index = lane * 50 + 45
	_apply_look()
	EventBus.subscribe("ice_all_zombie", _on_ice_all)
	EventBus.subscribe("jalapeno_bomb_effect_item_lane", _on_jala)
	EventBus.subscribe("jalapeno_bomb_effect_lane_zombie", _on_jala)

func _apply_look() -> void:
	sprite.texture = TEX_FIRE if is_fire else TEX_ICE
	modulate = Color(1.35, 1.25, 1.15) if is_fire else Color(1.15, 1.3, 1.45)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	global_position.x -= speed * delta
	## 滚动视觉
	sprite.rotation -= delta * 6.0
	_hit_cells_at_x(global_position.x)
	if global_position.x < -150.0:
		_destroy()

## 碾压当前列的植物(每帧对接触列结算一次)
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

## 寒冰菇全场冰冻 → 火球熄灭(冰球不受影响)
func _on_ice_all(_payload = null) -> void:
	if is_fire:
		_destroy()

## 火爆辣椒火焰 → 冰球融化(火球不受影响)
func _on_jala(payload = null) -> void:
	if not is_fire:
		_destroy()

func _destroy() -> void:
	if _dead:
		return
	_dead = true
	queue_free()
