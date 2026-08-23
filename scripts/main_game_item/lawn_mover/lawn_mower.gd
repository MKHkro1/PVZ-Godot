extends Node2D
class_name LawnMover
## 小推车

var lane: int = -1  ## 推车行，从0开始, 创建小推车的脚本赋值
@export var move_speed: float = 300.0  ## 推车移动速度（像素/秒）
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D

var is_moving: bool = false
## 超出屏幕500像素删除
var screen_rect: Rect2  # 延后初始化

func _ready() -> void:
	# 必须在 ready 后才能安全获取视口尺寸
	screen_rect = get_viewport_rect().grow(500)


func _process(delta: float) -> void:
	if is_moving:
		position.x += move_speed * delta

		if not screen_rect.has_point(global_position):
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	var area_owner = area.owner
	if area_owner is Zombie000Base:
		var zombie :Zombie000Base = area_owner
		if lane == zombie.lane:
			_on_lane_zombie_enter(zombie)

## 当同行僵尸进入
func _on_lane_zombie_enter(zombie :Zombie000Base):
	if not is_moving:
		start_trigger_filter(zombie)
	else:
		_mower_run_one_zombie(zombie)

## 启动触发过滤
func start_trigger_filter(zombie :Zombie000Base):
	if zombie is Zombie018Digger:
		## 掘土状态矿工不触发小推车，连接启动小推车函数
		if not zombie.is_can_trigger_mower:
			zombie.signal_can_trigger_mower.connect(_start_mower)
			return
	_start_mower()

## 启动小推车
func _start_mower():
	is_moving = true
	animation_player.play("LawnMower_normal")
	SoundManager.play_other_SFX("lawnmower")
	## 通知出怪算行系统: 该行丢车, 一段时间内暂停出怪(原版行为)
	EventBus.push_event("lawn_mover_used", lane)
	_mower_run_all_zombie_on_start()

## 启动时碾压当前所有的僵尸
func _mower_run_all_zombie_on_start():
	for area: Area2D in area_2d.get_overlapping_areas():
		var area_owner = area.owner
		if area_owner is Zombie000Base:
			var zombie :Zombie000Base = area_owner
			if lane == zombie.lane:
				_mower_run_one_zombie(zombie)

## 小推车碾压一个僵尸
func _mower_run_one_zombie(zombie :Zombie000Base):
	zombie.be_mowered_run(self)
