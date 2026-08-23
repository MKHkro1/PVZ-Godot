extends ComponentNormBase
## 跳跃组件
class_name JumpComponent

@onready var owner_zombie: Zombie000Base = owner
@onready var move_component: MoveComponent = %MoveComponent
@onready var detect_component: DetectComponent = %DetectComponent

## 影子定位僵尸本体位置
@onready var shadow: Sprite2D = %Shadow

## 跳跃距离，跳跃完成后移动本体节点的距离
@export var jump_x :float= 150
## 可以跳跃的敌人状态
@export_flags("1 正常", "2 悬浮", "4 地刺", "8 低矮") var can_attack_plant_status:int = 9
@export_flags("1 正常", "2 跳跃", "4 水下", "8 空中", "16 地下")var can_attack_zombie_status:int = 1
## 跳跃补偿(只对植物生效)，是否跳跃过程中向后滑步保障不越过植物过多
@export var is_jump_compensate_plant := true
var is_jump_compensate = false
## 跳跃补偿距离
@export var jump_compensate_distance: float = 40	# 跳过植物的距离
var jump_plant_position_x : float# 正在跳跃的植物的X值

## 跳跃被高坚果强行停止
var is_jump_stop := false
## 跳跃高坚果位置
var jump_stop_postion :Vector2
## 跳跃中
var is_jumping := false
@export_group("跳跃音效")
@export var jump_sfx:StringName

## 外部需要的组件（攻击行为组件）连接该信号
## 检测到可攻击敌人，开始跳跃信号
signal signal_jump_start()
signal signal_jump_end()
## 跳跃结束后摇结束
signal signal_jump_end_end()

## 我是僵尸模式检测脑子
signal signal_detect_brain()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if is_jump_compensate and is_jumping:
		if shadow.global_position.x < jump_plant_position_x - jump_compensate_distance:
			var diff = shadow.global_position.x - (jump_plant_position_x - jump_compensate_distance)
			owner_zombie.global_position.x -= diff


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for node in get_children():
		if node is Area2D:
			var area_2d = node as Area2D
			area_2d.monitoring = true
			# 启用后立即检查当前区域内的重叠对象
			for overlap_area in area_2d.get_overlapping_areas():
				_on_area_2d_area_entered(overlap_area)


## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	for node in get_children():
		if node is Area2D:
			var area_2d = node as Area2D
			area_2d.monitoring = false

## 开始跳跃
## [is_jump_compensate:bool]是否有跳跃补偿
## [global_pos_x:float]跳跃补偿对应植物位置
func jump_start(curr_is_jump_compensate:bool, global_pos_x:float=0):
	self.is_jump_compensate = curr_is_jump_compensate
	is_jumping = true
	signal_jump_start.emit()
	if self.is_jump_compensate:
		jump_plant_position_x = global_pos_x

## 结束跳跃，动画调用
func jump_end():
	is_jumping = false
	signal_jump_end.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	if owner_zombie.is_mini_zombie:
		jump_x /= 2
	owner.global_position.x -= jump_x
	signal_jump_end_end.emit()
	#print("跳跃结束修改完成位置")

## 跳跃被高坚果强行停止
func jump_be_stop(plant:Plant000Base):
	is_jump_stop = true
	jump_stop_postion = plant.global_position

## 动画调用，判断跳跃是否被强行停止
func judge_jump_be_stop():
	if is_jump_stop:
		await jump_end()
		owner.global_position.x = jump_stop_postion.x+20

## 射线检测区域
func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.owner
	if enemy is Plant000Base:
		var enemy_plant:Plant000Base = enemy
		## 如果当前植物可以被僵尸攻击到
		if enemy_plant.curr_be_attack_status & can_attack_plant_status:
			jump_start(is_jump_compensate_plant, enemy.global_position.x)

	#plant.be_zombie_eat(20)
	elif enemy is Zombie000Base:
		var enemy_zombie:Zombie000Base = enemy
		## 连接信号僵尸状态变化函数
		enemy_zombie.signal_status_update.connect(_on_enemy_zombie_status_change.bind(enemy_zombie))

		## 如果当前僵尸可以被僵尸攻击到
		if enemy_zombie.curr_be_attack_status & can_attack_zombie_status:
			## 跳过僵尸时没有补偿
			is_jump_compensate = false
			jump_start(false)

	## 保龄球子弹
	elif enemy is Bullet000Base:
		is_jump_compensate = false
		jump_start(false)

## 敌人离开当前射线检测区域
func _on_area_2d_area_exited(area: Area2D) -> void:
	var enemy = area.owner
	## 断开僵尸的状态变换信号
	if enemy is Zombie000Base:
		var enemy_zombie:Zombie000Base = enemy
		## 连接信号僵尸状态变化函数
		enemy_zombie.signal_status_update.disconnect(_on_enemy_zombie_status_change.bind(enemy_zombie))


## 僵尸敌人状态变化时函数，与状态变化信号连接
func _on_enemy_zombie_status_change(zombie:Zombie000Base):
	## 如果当前僵尸敌人可以被攻击
	if zombie.curr_be_attack_status & can_attack_plant_status:
		jump_start(false)

func _play_jump_SFX():
	SoundManager.play_character_SFX(jump_sfx)


func _on_area_2d_brain_area_entered(area: Area2D) -> void:
	## 我是僵尸模式的脑子
	if area.owner is BrainOnZombieMode:
		signal_detect_brain.emit()
