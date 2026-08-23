extends Plant000Base
class_name Plant018Squash

@onready var area_2d_squash_attack: Area2D = $Area2DSquashAttack
@onready var detect_component: DetectComponentSquash = $DetectComponent

## 可以攻击的敌人状态
@export_flags("1 正常", "2 悬浮", "4 地刺", "8 低矮") var can_attack_plant_status:int = 13
@export_flags("1 正常", "2 跳跃", "4 水下", "8 空中", "16 地下") var can_attack_zombie_status:int = 1

@export_group("动画状态")
@export var is_attack: bool = false
@export var is_right:bool = true
var target_x

func ready_norm_signal_connect():
	super()
	detect_component.signal_can_attack.connect(attack_start)

## 开始攻击
func attack_start():
	if not is_attack:
		SoundManager.play_character_SFX("SquashHmm")
		is_attack = true
		target_x = detect_component.enemy_can_be_attacked.shadow.global_position.x
		is_right = target_x > global_position.x
		hurt_box_component.disable_component(ComponentNormBase.E_IsEnableFactor.Character)

## 开始跳跃
func jump_up_start():
	z_index += 50
	## 如果地形为睡莲或者水
	if plant_cell.curr_condition & 8 or  plant_cell.curr_condition & 16:
		shadow.visible = false

	var tween:Tween = create_tween()
	if is_instance_valid(detect_component.enemy_can_be_attacked):
		tween.tween_property(self, "global_position:x", detect_component.enemy_can_be_attacked.shadow.global_position.x, 0.3).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property(self, "global_position:x", target_x, 0.3).set_ease(Tween.EASE_IN)

## 压扁所有范围内可攻击僵尸
func squash_all_area_zombie():
	var areas = area_2d_squash_attack.get_overlapping_areas()
	for area in areas:
		var zombie:Zombie000Base = area.owner
		## 如果为同一行僵尸
		if zombie.lane == row_col.x:
			if zombie.curr_be_attack_status & can_attack_zombie_status:
				zombie.be_squash()

## 跳入水中判断
func judge_jump_pool():
	## 如果地形为睡莲或者水
	if plant_cell.curr_condition & 8 or  plant_cell.curr_condition & 16:
		## 水花
		var splash:Splash = SceneRegistry.SPLASH.instantiate()
		plant_cell.add_child(splash)
		splash.global_position = Vector2(global_position.x,plant_cell.global_position.y + plant_cell.size.y)
		splash.z_as_relative = z_as_relative
		splash.z_index = z_index
		character_death()
	else:
		SoundManager.play_character_SFX(&"gargantuar_thump")
