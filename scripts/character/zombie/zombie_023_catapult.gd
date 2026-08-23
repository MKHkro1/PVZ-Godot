extends Zombie000Base
class_name Zombie023Catapult

## 状态三阶段时损毁烟雾
@onready var smoke: GPUParticles2D = %Smoke
@onready var death_bomb: ZamboniDeathBomb = $Body/DeathBomb

## 位置x小于该值时可以攻击
@export var global_pos_x_can_attack:float = 730

@export_group("子弹相关")
## 最大子弹数量
@export_range(1, 100, 1) var MaxNumBullet :int = 20
## 当前发射的子弹数量
var curr_num_shoot_bullet = 0
## 子弹节点,根据发射子弹隐藏部分子弹
@export var node_bullet:Array[Node2D]
## 每颗body中的子弹代表的真实子弹数量
var num_real_bullet_node_bullet:int

@export_group("动画状态")
@export var is_caltrop:= false
## 是否到达攻击位置
var is_attack_pos := false

## 状态1时改变精灵节点
@export_group("攻击动画时pole节点变化")
@export var body_change_0:Dictionary[StringName, ResourceBodyChange] = {}
@export var body_change_1:Dictionary[StringName, ResourceBodyChange] = {}
var curr_body_pole_change_dic:Dictionary[StringName, ResourceBodyChange]

func ready_norm():
	super()
	## 默认禁用攻击组件,到达可以攻击的位置后,启用攻击组件
	attack_component.update_is_attack_factors(false, AttackComponentBase.E_IsAttackFactors.Character)
	curr_body_pole_change_dic = body_change_0
	if node_bullet.is_empty():
		num_real_bullet_node_bullet = 0
	else:
		num_real_bullet_node_bullet = int(ceil(float(MaxNumBullet) / float(node_bullet.size())))

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	## 血量变化
	hp_stage_change_component.signal_hp_stage_change.connect(hp_stage_zamboni_change)
	attack_component = attack_component as AttackComponentBulletPultBase
	attack_component.signal_shoot_bullet.connect(update_bullet_data)

func _process(_delta: float) -> void:
	## 每帧判断是否需要移动到攻击位置
	if not is_attack_pos:
		if global_position.x <= global_pos_x_can_attack:
			is_attack_pos = true
			## 到达可以攻击的位置后,启用攻击组件
			attack_component.update_is_attack_factors(true, AttackComponentBase.E_IsAttackFactors.Character)

#region 攻击精灵图片变化
func update_pole_sprite_no_bullet():
	change_body_pole(curr_body_pole_change_dic["no_bullet"])

func update_pole_sprite_have_bullet():
	## 没有子弹
	if curr_num_shoot_bullet >= MaxNumBullet:
		update_pole_sprite_no_bullet()
	else:
		change_body_pole(curr_body_pole_change_dic["have_bullet"])

func change_body_pole(curr_body_pole_change:ResourceBodyChange):
	var sprite_change:Sprite2D = get_node(curr_body_pole_change.sprite_change[0])
	sprite_change.texture = curr_body_pole_change.sprite_change_texture[0]
#endregion

#region 血量变化
## 血量状态变化时zamboni的特殊变化
## 共4个变化阶段
## 0:无变化
## 1:改变body pole\损毁烟雾
## 2:速度减半\车身抖动
## 3:爆炸死亡
func hp_stage_zamboni_change(curr_hp_stage:int):
	match curr_hp_stage:
		1:
			curr_body_pole_change_dic = body_change_1
			update_pole_sprite_have_bullet()
			smoke.emitting = true
		2:
			update_speed_factor(0.5, E_Influence_Speed_Factor.ZamboniHp)
			## 抖动
			var tween = create_tween()
			tween.tween_property(body, "position", body.position + Vector2(1, 1), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(body, "position", body.position, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.set_loops()
		3:
			zamboni_death_effect()

## 死亡爆炸特效
func zamboni_death_effect():
	death_bomb.activate_it()
	SoundManager.play_character_SFX(&"explosion")
	queue_free()
#endregion

## 更新子弹相关
func update_bullet_data():
	curr_num_shoot_bullet += 1
	if curr_num_shoot_bullet >= MaxNumBullet:
		for n in node_bullet:
			n.visible = false
			attack_component.update_is_attack_factors(false, AttackComponentBase.E_IsAttackFactors.Character)
	else:
		if num_real_bullet_node_bullet == 0:
			return
		if curr_num_shoot_bullet % num_real_bullet_node_bullet == 0:
			print("当前数量", curr_num_shoot_bullet, "当前为第几颗代表", int(float(curr_num_shoot_bullet)/num_real_bullet_node_bullet))
			node_bullet[int(float(curr_num_shoot_bullet)/num_real_bullet_node_bullet)].visible = false

## 被地刺扎
func be_caltrop():
	is_caltrop = true
	character_death_not_disappear()
	move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAnimGap)
