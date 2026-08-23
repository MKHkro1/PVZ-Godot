extends LawnMover
class_name PoolCleaner

@onready var body: Node2D = $Body
var ori_move_speed:float

#region 游泳相关

## 碰到僵尸
var is_zombie: bool = false

@export_group("游泳相关")
@export var is_water := false
###游泳消失的精灵图
#@export var swimming_fade : Array[Sprite2D]
###游泳出现的精灵图
#@export var swimming_appear : Array[Sprite2D]
#endregion


func _ready() -> void:
	super._ready()
	ori_move_speed = move_speed


func _on_area_entered(area: Area2D) -> void:
	var owner_node = area.owner
	if owner_node is Zombie000Base:
		if lane == owner_node.lane:
			_on_lane_zombie_enter(owner_node)

	elif owner_node.name =="Pool":
		print("小推车碰撞到泳池")
		start_swim()

## 启动小推车
func _start_mower():
	is_moving = true
	SoundManager.play_other_SFX("pool_cleaner")
	animation_player.play("PoolCleaner_land")
	_mower_run_all_zombie_on_start()

func _on_area_exited(area: Area2D) -> void:
	var owner_node = area.owner
	if not is_instance_valid(owner_node):
		return
	if owner_node is Zombie000Base:
		pass

	elif owner_node.name =="Pool":
		print("小推车碰离开泳池")
		end_swim()

func suck_end():
	move_speed = ori_move_speed
	is_zombie = false

## 小推车碾压一个僵尸
func _mower_run_one_zombie(zombie :Zombie000Base):
	zombie.character_death_disappear()
	move_speed = ori_move_speed / 4
	is_zombie = true

#region 水池游泳

func start_swim():
	# 水花
	var splash = SceneRegistry.SPLASH.instantiate()
	get_parent().add_child(splash)
	splash.global_position = global_position
	is_water = true

func end_swim():
	# 水花
	var splash = SceneRegistry.SPLASH.instantiate()
	get_parent().add_child.call_deferred(splash)
	splash.global_position = global_position
	is_water = false
#endregion
