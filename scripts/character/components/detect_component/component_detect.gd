extends ComponentNormBase
## 攻击射线检测组件,根据owner自动选择敌人层
class_name DetectComponent

## 每帧判断是否检测当前敌人
## 敌人进入\离开\状态变化时检测
## 敌人进入时连接状态变化函数，离开时不断开
## **植物和僵尸通用**
## 是否使用行属性进行攻击判断
@export var is_lane:=true
## 是否攻击梯子下的植物,僵尸初始化时根据is_ignore_ladder更新该值
var is_attack_ladder_plant:=true
## 可以攻击的敌人状态
@export_flags("1 正常", "2 悬浮", "4 地刺", "8 低矮") var can_attack_plant_status:int = 9
@export_flags("1 正常", "2 跳跃", "4 水下", "8 空中", "16 地下") var can_attack_zombie_status:int = 1

## 植物敌人碰撞层:4(僵尸)
@export_flags_2d_physics var plant_enemy_collision_lay :int = 4
## 僵尸敌人碰撞层:2(植物) + 32(魅惑僵尸)
@export_flags_2d_physics var zomie_enemy_collision_lay :int = 2 + 32
## 敌人层
var enemy_collision_lay:int = -1:
	set(value):
		enemy_collision_lay = value
		## 更新所有检测区域的敌人mask层
		for node in get_children():
			if node is Area2D:
				var area_2d = node as Area2D
				area_2d.collision_mask = enemy_collision_lay

## 检测到的敌人
## (不能攻击是因为敌人状态不在攻击状态中，连接状态变化信号)
## 检测到的可以被攻击的一个敌人,给特殊植物\僵尸\抛物线子弹使用
var enemy_can_be_attacked :Character000Base = null
## 是否需要判断检测敌人
var need_judge := false

## 检测区域列表
var all_ray_area:Array[Area2D]
## 检测区域的方向,部分植物发射子弹使用
var ray_area_direction:Array[Vector2]

## 外部需要的组件（攻击行为组件）连接该信号
## 检测到可攻击敌人，可以攻击信号
signal signal_can_attack
## 无可攻击敌人，取消攻击信号
signal signal_not_can_attack

func _ready() -> void:
	if owner is Zombie000Base:
		enemy_collision_lay = zomie_enemy_collision_lay
	elif owner is Plant000Base:
		enemy_collision_lay = plant_enemy_collision_lay
	elif owner is MainGameManager:
		enemy_collision_lay = plant_enemy_collision_lay
	else:
		printerr("组件owner不是植物或者僵尸基类角色")

	## 连接所有子节点（area2d）的信号[三线、杨桃等有多个射线area2d]
	for i:int in range(get_child_count()):
		var area_2d:Area2D = get_child(i)
		area_2d.area_entered.connect(_on_area_2d_area_entered)
		area_2d.area_exited.connect(_on_area_2d_area_exited)
		area_2d.collision_mask = enemy_collision_lay
		all_ray_area.append(area_2d)
		ray_area_direction.append(Vector2(cos(area_2d.rotation), sin(area_2d.rotation)))

	## 如果是角色类型(世界有一个全局检测组件,用于追踪型子弹检查敌人)
	if owner is Character000Base and owner.lane == -1 and owner.character_init_type == Character000Base.E_CharacterInitType.IsNorm:
		printerr(owner.name + "lane == -1且为正常出战初始化类型")

func _process(_delta):
	if need_judge and is_enabling:
		need_judge = false
		judge_is_have_enemy()

## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	if is_enabling:
		need_judge = true

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	enemy_can_be_attacked = null
	signal_not_can_attack.emit()
	need_judge = false

## 敌人进入当前区域，若为同一行，当前帧进行判断是否可以攻击
func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.owner
	if is_lane and owner.lane != enemy.lane:
		return
	if enemy is Plant000Base:
		if not enemy.signal_ladder_update.is_connected(_on_enemy_plant_ladder_update.bind(enemy)):
			enemy.signal_ladder_update.connect(_on_enemy_plant_ladder_update.bind(enemy))
	elif enemy is Zombie000Base:
		if not enemy.signal_status_update.is_connected(_on_enemy_zombie_status_update.bind(enemy)):
			enemy.signal_status_update.connect(_on_enemy_zombie_status_update.bind(enemy))
		if not enemy.signal_lane_update.is_connected(_on_enemy_zombie_lane_update.bind(enemy)):
			enemy.signal_lane_update.connect(_on_enemy_zombie_lane_update.bind(enemy))
	need_judge = true

## 敌人离开当前射线检测区域
@warning_ignore("unused_parameter")
func _on_area_2d_area_exited(area: Area2D) -> void:
	need_judge = true

## 植物敌人梯子状态变化
@warning_ignore("unused_parameter")
func _on_enemy_plant_ladder_update(plant:Plant000Base):
	need_judge = true

## 僵尸敌人状态变化时函数，与状态变化信号连接
@warning_ignore("unused_parameter")
func _on_enemy_zombie_status_update(zombie:Zombie000Base):
	need_judge = true

## 僵尸敌人行变化时函数，与行变化信号连接
@warning_ignore("unused_parameter")
func _on_enemy_zombie_lane_update(zombie:Zombie000Base):
	need_judge = true

## 如果检测到可以被攻击的敌人，发射信号,保存当前敌人，return,若到最后没有检测到敌人，发射信号，重置当前敌人，return
func judge_is_have_enemy():
	#print("判定敌人")
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			if not enemy_area.owner is Character000Base:
				continue
			var enemy:Character000Base = enemy_area.owner
			if _judge_enemy_is_can_be_attack(enemy):
				enemy_can_be_attacked = enemy
				if enemy_can_be_attacked is Plant000Base and is_instance_valid(enemy_can_be_attacked):
					enemy_can_be_attacked = get_first_be_hit_plant_in_cell(enemy_can_be_attacked)
					if enemy_can_be_attacked == null:
						continue
					enemy_can_be_attacked.signal_character_death.connect(func():need_judge = true)
				signal_can_attack.emit()
				return true

	## 如果循环结束还未return,未找到敌人
	enemy_can_be_attacked = null
	signal_not_can_attack.emit()
	return false

## 获取应该被攻击的植物,在当前植物格子中
func get_first_be_hit_plant_in_cell(plant:Plant000Base)->Plant000Base:
	## shell
	#prints("植物是否合法", is_instance_valid(plant), plant.name)
	if is_instance_valid(plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]):
		return plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]
	elif is_instance_valid(plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]) and plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm].hurt_box_component.is_enabling:
		return plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Norm]
	elif is_instance_valid(plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Imitater]) and plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Imitater].hurt_box_component.is_enabling:
		return plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Imitater]
	elif is_instance_valid(plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Down]):
		return plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Down]
	else:
		#printerr("当前植物格子没有检测到可以攻击的植物", is_instance_valid(plant.plant_cell.plant_in_cell[Global.PlacePlantInCell.Float]))
		return null

## 判断敌人是否可以被攻击
func _judge_enemy_is_can_be_attack(enemy:Character000Base)->bool:
	if not is_instance_valid(enemy):
		return false
	## 先判断行属性
	if is_lane and owner.lane != enemy.lane:
		return false
	## 如果敌人为植物
	if enemy is Plant000Base:
		## 如果当前植物可以被攻击到
		if enemy.curr_be_attack_status & can_attack_plant_status:
			## 梯子
			if is_attack_ladder_plant:
				return true
			else:
				## 判断格子是否有梯子
				return not is_instance_valid(enemy.plant_cell.ladder)
		else:
			return false

	## 检测到僵尸
	elif enemy is Zombie000Base:
		if enemy.curr_be_attack_status & can_attack_zombie_status:
			return true
		else:
			return false

	## 其余东西
	else:
		print("检测到非角色类敌人")
		return false

## 更新可攻击敌人为第一个敌人(最前面的敌人),投手类使用
func update_first_enemy()->Character000Base:
	enemy_can_be_attacked = null
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			var enemy:Character000Base = enemy_area.owner
			## 如果敌人可以被攻击
			if _judge_enemy_is_can_be_attack(enemy):
				if is_instance_valid(enemy_can_be_attacked):
					if enemy_can_be_attacked.global_position.x > enemy.global_position.x:
						enemy_can_be_attacked = enemy
				else:
					enemy_can_be_attacked = enemy
	#print(enemy_can_be_attacked.global_position.x, enemy_can_be_attacked.name)
	return enemy_can_be_attacked


## 获取所有可以被攻击的敌人
func get_all_enemy_can_be_attacked()->Array[Character000Base]:
	var all_enemy_can_be_attacked:Array[Character000Base]
	for ray_area in all_ray_area:
		var all_enemy_area = ray_area.get_overlapping_areas()
		for enemy_area in all_enemy_area:
			var enemy:Character000Base = enemy_area.owner
			## 如果敌人可以被攻击
			if _judge_enemy_is_can_be_attack(enemy) and not all_enemy_can_be_attacked.has(enemy):
				all_enemy_can_be_attacked.append(enemy)
	return all_enemy_can_be_attacked

## 被魅惑
func owner_be_hypno():
	enemy_collision_lay = plant_enemy_collision_lay
	disable_component(ComponentNormBase.E_IsEnableFactor.Hypno)
	enable_component(ComponentNormBase.E_IsEnableFactor.Hypno)
