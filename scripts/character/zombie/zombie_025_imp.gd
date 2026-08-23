extends Zombie000Base
class_name Zombie025Imp

@onready var body_correct: Node2D = $Body/BodyCorrect
## 小鬼的头,用于投掷小鬼时定位
@onready var anim_head_1: Sprite2D = $Body/BodyCorrect/Head/Anim_head1

## 目标头相对body的目标位置
var target_pos_anim_head_to_body:Vector2
## 投掷小鬼时小鬼头的初始位置,相对BodyCorrect节点
var curr_pos_anim_head_1:Vector2 = Vector2(41.1, 16.1)
## body修正位置的正常位置,修改该位置使小鬼位置重叠
var pos_body_correct:Vector2 = Vector2(-55, -120)

@export_group("动画状态")
## 默认为移动状态,is_walk由多种状态控制
@export var is_thrown := false

func ready_norm():
	super()
	if is_thrown:
		update_body_correct_pos_throw()
		SoundManager.play_character_SFX(&"imp")
	## 罐子僵尸,小鬼僵尸血量变为原始的一半
	if is_pot_zombie:
		hp_component = hp_component as HpComponentZombie
		hp_component.update_mini_zombie_hp()
		hp_stage_change_component.update_mini_zombie_hp_stage_change()

## 投掷小鬼更新BodyCorrect位置
func update_body_correct_pos_throw():
	attack_component.update_is_attack_factors(false, AttackComponentBase.E_IsAttackFactors.Character)
	move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsCharacter)
	shadow.visible = false
	## 头相对body(零点)的位置
	var anim_head_1_to_body = curr_pos_anim_head_1 + pos_body_correct
	## 计算新的 BodyCorrect 的位置（相对于 Body 的 local 位置）
	var desired_bodycorrect_local = target_pos_anim_head_to_body - anim_head_1_to_body
	var slope_y_first :float = 0
	if is_instance_valid(Global.main_game.main_game_slope):
		## 获取对应位置的斜面y相对位置
		slope_y_first = Global.main_game.main_game_slope.get_all_slope_y(global_position.x)
	body_correct.position = desired_bodycorrect_local + pos_body_correct - Vector2(0, slope_y_first)

	var tween:Tween = create_tween()
	tween.tween_property(body_correct, ^"position", pos_body_correct, 1.5)
	await tween.finished

	attack_component.update_is_attack_factors(true, AttackComponentBase.E_IsAttackFactors.Character)
	move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsCharacter)
	shadow.visible = true

