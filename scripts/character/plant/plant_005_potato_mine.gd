extends Plant000Base
class_name Plant005PotatoMine

@onready var detect_component: DetectComponent = $DetectComponent
@onready var bomb_component: BombComponentBase = $BombComponent
@onready var prepare_timer: Timer = $PrepareTimer

## 准备时间
@export var prepare_time := 10.0

@export_group("动画状态")
@export var is_prepare_end := false


## 初始化正常出战角色
func ready_norm():
	super()
	## 土豆雷默认禁用攻击射线检测组件
	detect_component.disable_component(ComponentNormBase.E_IsEnableFactor.Prepare)
	## 默认禁用眨眼组件
	blink_component.disable_component(ComponentNormBase.E_IsEnableFactor.Prepare)

	prepare_timer.wait_time = prepare_time
	prepare_timer.start()

	if is_zombie_mode:
		prepare_timer.stop()
		_on_prepare_timer_timeout()

func ready_norm_signal_connect():
	super()
	## 准备完成后才会检测到敌人(触发爆炸\直接死亡)
	detect_component.signal_can_attack.connect(bomb_component.bomb_once)
	detect_component.signal_can_attack.connect(character_death)

	## 角色速度改变
	signal_update_speed.connect(update_prepare_speed)

## 亡语
func death_language():
	bomb_component.judge_death_bomb()

## 土豆类出土动画结束调用
func _rise_end():
	detect_component.enable_component(ComponentNormBase.E_IsEnableFactor.Prepare)
	blink_component.enable_component(ComponentNormBase.E_IsEnableFactor.Prepare)
	bomb_component.is_auto_bomb_in_death = true

## 准备时间结束
func _on_prepare_timer_timeout() -> void:
	is_prepare_end = true

## 重新设置准备时间
func set_prepare_time(new_prepare_time:float):
	prepare_time = new_prepare_time
	prepare_timer.wait_time = prepare_time
	prepare_timer.start()

## 改变准备的速度
func update_prepare_speed(speed_factor:float):
	if not prepare_timer.is_stopped():
		if speed_factor == 0:
			prepare_timer.paused = true
		else:
			prepare_timer.paused = false
			prepare_timer.start(prepare_timer.time_left / speed_factor)
