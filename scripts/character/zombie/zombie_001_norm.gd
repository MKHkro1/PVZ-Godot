extends Zombie000Base
class_name Zombie001Norm

@onready var anim_innerarm: Node2D = $Body/BodyCorrect/Anim_innerarm
@onready var zombie_outerarm_upper: Node2D = $Body/BodyCorrect/Zombie_outerarm_upper

@export_group("动画状态")
## 动画状态（僵尸有某类动画有多种）
@export var idle_status := 1
@export var walk_status := 1
@export var death_status := 1

@export_subgroup("最大动画状态")
@export var idle_status_max := 2
@export var walk_status_max := 2
@export var death_status_max := 2

@export_group("普僵初始化精灵节点")
@export var init_sprite_random:Array[Node2D]

## 海草精灵节点
@onready var sprite_seaweed:Array[Sprite2D] = [
	$Body/BodyCorrect/Anim_head/Anim_head1/ZombieSeaweed3,
	$Body/BodyCorrect/Zombie_duckytube/Zombie_duckytube/ZombieSeaweed,
	$Body/BodyCorrect/Zombie_duckytube/Zombie_duckytube/ZombieSeaweed2,
	$Body/BodyCorrect/Zombie_outerarm_upper/Zombie_outerarm_upper/ZombieSeaweed4,
	$Body/BodyCorrect/Anim_head/Anim_head1/ZombieSeaweed2,
]
## 铁桶海草精灵
@onready var sprite_seaweed_bucket: Sprite2D = $Body/BodyCorrect/Anim_bucket/Anim_bucket/ZombieSeaweed4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_random_anim_status()
	_random_sprit_appear()
	if is_seaweed:
		sprite_seaweed.shuffle()
		var pick3 = sprite_seaweed.slice(0, 3)
		for s in pick3:
			s.visible = true
		sprite_seaweed_bucket.visible = true

## 随机选择动画状态种类
func _random_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _random_sprit_appear():
	for sprite in init_sprite_random:
		sprite.visible = [true, false].pick_random()


## 死亡动画开始时,将里面的胳膊显示(旗帜\铁门)
func anim_death_start():
	anim_innerarm.visible = true
