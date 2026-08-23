extends Zombie000Base
class_name Zombie013Zamboni

## 状态三阶段时损毁烟雾
@onready var smoke: GPUParticles2D = %Smoke
@onready var death_bomb: ZamboniDeathBomb = $Body/DeathBomb

## 冰道
@onready var ice_road: IceRoad = $IceRoad

@export_group("动画状态")
@export var is_caltrop:= false

## 僵尸上一帧和当前帧位置(更新冰道使用)
var zombie_last_x:float
var zombie_curr_x:float

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	hp_stage_change_component.signal_hp_stage_change.connect(hp_stage_zamboni_change)
	hp_component.signal_hp_component_death.connect(func():ice_road.start_disappear_timer())

## 初始化正常出战角色
func ready_norm():
	super()
	## 将冰道放置于游戏背景上
	var main_game :MainGameManager = get_tree().current_scene
	ice_road.reparent(main_game.background_manager.background)
	ice_road.ice_road_init(lane)
	zombie_last_x = global_position.x

## 初始化展示角色
func ready_show():
	super()
	move_component.disable_component(ComponentNormBase.E_IsEnableFactor.InitType)
	zombie_last_x = global_position.x

func _process(_delta: float) -> void:
	zombie_curr_x = global_position.x
	if zombie_curr_x != zombie_last_x and is_instance_valid(ice_road):
		ice_road.expand_size(zombie_last_x - zombie_curr_x)
		zombie_last_x = zombie_curr_x


## 血量状态变化时zamboni的特殊变化
## 共4个变化阶段
## 0:无变化
## 1:损毁烟雾\速度减半
## 2:停止移动\车身抖动
## 3:爆炸死亡
func hp_stage_zamboni_change(curr_hp_stage:int):
	match curr_hp_stage:
		1:
			smoke.emitting = true
			update_speed_factor(0.5, E_Influence_Speed_Factor.ZamboniHp)
		2:
			update_speed_factor(0, E_Influence_Speed_Factor.ZamboniHp)
			## 停止移动,抖动
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

## 被地刺扎
func be_caltrop():
	is_caltrop = true
	character_death_not_disappear()
	move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAnimGap)
