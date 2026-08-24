extends PanelContainer
class_name CardSlotConveyorBelt
"""
先根据植物和僵尸的权重,随机选取生成植物还是生成僵尸
在使用随机池生成对应的卡片
"""

@onready var conveyor_belt_gear: ConveyorBeltGear = $ConveyorBeltGear
@onready var new_card_area: Panel = $NewCardArea
@onready var create_new_card_timer: Timer = $CreateNewCardTimer

var curr_cards :Array[Card] = []

@export_group("传送带参数")
## 最大卡片数量，固定10个
@export var num_card_max :int = 10
## 每张卡片最终目标位置x,从0开始隔50像素个，ready函数中自动生成
var all_card_pos_x_target :Array[float] = []
## 卡片移动速度
@export var conveyor_velocity :float = 30
## 卡片生成时间
@export var create_new_card_cd :float = 5

#region 随机生成卡片相关
@onready var card_random_pool: CardRandomPool = $CardRandomPool
## 按顺序出现的卡片植物
var card_order_plant:Dictionary[int, Global.PlantType] = {}
## 按顺序出现的卡片僵尸(若重复,则使用植物的卡片)
var card_order_zombie:Dictionary[int, Global.ZombieType] = {}
## 当前生成的卡片总数量
var all_num_card :int = 0
## 下次强制生成的植物卡(花盆不足时由僵王请求)
var _force_next_plant: Global.PlantType = Global.PlantType.Null
## 僵王关: 场上花盆低于此值时提高花盆出卡概率
const ZOMBOSS_FLOWER_POT_FIELD_MIN := 16
## 僵王关: 传送带缺卡时的权重倍率
const ZOMBOSS_MISSING_CARD_BOOST := 4.0
## 僵王关: 花盆不足时的基础倍率(随缺口线性增加)
const ZOMBOSS_FLOWER_POT_BOOST_BASE := 2.0
const ZOMBOSS_FLOWER_POT_BOOST_PER_DEFICIT := 0.25
#endregion

## 是否正在运行中
var is_working:= false
## 创建新卡片倍率
var create_new_card_speed:float
## 卡片种植完成后信号，计时器判断是否重启
signal signal_card_end


#region 初始化

func _ready() -> void:
	_init_card_position_x()

## 初始化传送带卡片最终位置
func _init_card_position_x():
	for i in range(num_card_max):
		all_card_pos_x_target.append(0 + i * 50)
	print("传送带每张卡片的位置：",all_card_pos_x_target)

## 管理器初始化调用
func init_card_slot_conveyor_belt(game_para:ResourceLevelData):
	var card_random_pool_init_para = {
		CardRandomPool.E_CardRandomPoolInitParaAttr.AllCardPlantProbability: game_para.all_card_plant_type_probability,
		CardRandomPool.E_CardRandomPoolInitParaAttr.AllCardZombieProbability: game_para.all_card_zombie_type_probability,
	}
	print("传送带卡槽初始化随机卡片生成器")
	card_random_pool.init_card_random_pool(card_random_pool_init_para)

	self.card_order_plant = game_para.card_order_plant
	self.card_order_zombie = game_para.card_order_zombie
	self.create_new_card_speed = game_para.create_new_card_speed
	## 修改倍率
	create_new_card_cd = create_new_card_cd / create_new_card_speed
	create_new_card_timer.wait_time = create_new_card_cd

	await get_tree().process_frame
	## 初始化后生成一个卡片
	_create_new_card()

#endregion

func _process(delta: float) -> void:
	if is_working:
		## 更新卡片位置
		for i in curr_cards.size():
			if curr_cards[i].position.x > all_card_pos_x_target[i]:
				curr_cards[i].position.x-= delta * conveyor_velocity
			elif curr_cards[i].position.x == all_card_pos_x_target[i]:
				continue
			else:
				curr_cards[i].position.x = all_card_pos_x_target[i]

#region 卡片生成相关
## 卡片种植完成后
func card_use_end(card:Card):
	curr_cards.erase(card)
	card.queue_free()
	signal_card_end.emit()

func _on_create_new_card_timer_timeout() -> void:
	_create_new_card() # Replace with function body.

## 统计传送带上指定植物卡数量
func count_plant_cards(plant_type: Global.PlantType) -> int:
	var n := 0
	for card in curr_cards:
		if is_instance_valid(card) and card.card_plant_type == plant_type:
			n += 1
	if _force_next_plant == plant_type:
		n += 1
	return n

## 请求下次强制生成指定植物卡(若已有同类型请求则忽略)
func request_force_plant_card(plant_type: Global.PlantType) -> void:
	if plant_type == Global.PlantType.Null:
		return
	if _force_next_plant != Global.PlantType.Null:
		return
	_force_next_plant = plant_type
	## 若卡槽未满且未在等空间, 尽快补一张
	if is_working and curr_cards.size() < num_card_max and create_new_card_timer.is_stopped() == false:
		## 缩短等待: 下一帧若计时器快结束则直接创建
		if create_new_card_timer.time_left > 1.0:
			create_new_card_timer.start(0.4)

## 生成一张新卡片
func _create_new_card():
	if curr_cards.size() >= num_card_max:
		create_new_card_timer.stop()
		await signal_card_end
		create_new_card_timer.start()
	var new_card_prefabs:Card
	if _force_next_plant != Global.PlantType.Null and AllCards.all_plant_card_prefabs.has(_force_next_plant):
		new_card_prefabs = AllCards.all_plant_card_prefabs[_force_next_plant]
		_force_next_plant = Global.PlantType.Null
	elif card_order_plant.has(all_num_card):
		new_card_prefabs = AllCards.all_plant_card_prefabs[card_order_plant[all_num_card]]
	elif card_order_zombie.has(all_num_card):
		new_card_prefabs = AllCards.all_zombie_card_prefabs[card_order_zombie[all_num_card]]
	else:
		var boosts := _get_zomboss_plant_boosts()
		if boosts.is_empty():
			new_card_prefabs = card_random_pool.get_random_card()
		else:
			new_card_prefabs = card_random_pool.get_random_card_with_plant_boosts(boosts)
	var new_card = new_card_prefabs.duplicate()
	new_card_area.add_child(new_card)
	new_card.card_init_conveyor_belt()
	new_card.position = Vector2(new_card_area.size.x, 0)
	#print(new_card_area.size)
	curr_cards.append(new_card)
	new_card.signal_card_use_end.connect(card_use_end.bind(new_card))
	var card_bg:TextureRect = new_card.get_node("CardBg")
	card_bg.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED

	all_num_card += 1

func _get_zomboss_plant_boosts() -> Dictionary:
	var boosts: Dictionary = {}
	if not is_instance_valid(Global.main_game) or Global.main_game.game_para == null:
		return boosts
	if not Global.main_game.game_para.is_zomboss_fight:
		return boosts
	var pot_on_field := _count_flower_pots_on_field()
	if pot_on_field < ZOMBOSS_FLOWER_POT_FIELD_MIN:
		var deficit := ZOMBOSS_FLOWER_POT_FIELD_MIN - pot_on_field
		boosts[Global.PlantType.P034FlowerPot] = ZOMBOSS_FLOWER_POT_BOOST_BASE + deficit * ZOMBOSS_FLOWER_POT_BOOST_PER_DEFICIT
	if count_plant_cards(Global.PlantType.P021Jalapeno) == 0:
		boosts[Global.PlantType.P021Jalapeno] = ZOMBOSS_MISSING_CARD_BOOST
	if count_plant_cards(Global.PlantType.P015IceShroom) == 0:
		boosts[Global.PlantType.P015IceShroom] = ZOMBOSS_MISSING_CARD_BOOST
	return boosts

func _count_flower_pots_on_field() -> int:
	var n := 0
	if not is_instance_valid(Global.main_game) or Global.main_game.plant_cell_manager == null:
		return n
	var cells = Global.main_game.plant_cell_manager.all_plant_cells
	for lane in cells:
		for cell in lane:
			if is_instance_valid(cell.plant_in_cell[Global.PlacePlantInCell.Down]):
				n += 1
	return n

#endregion

#region 传送带开始与结束
## 开始传送带
func start_conveyor_belt():
	is_working = true
	conveyor_belt_gear.start_gear()
	create_new_card_timer.start()

## 停止传送带
func stop_conveyor_belt():
	is_working = false
	conveyor_belt_gear.stop_gear()
	create_new_card_timer.stop()

## 移动卡槽（出现或隐藏）
func move_card_slot_conveyor_belt(is_appeal:bool):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(self, "position:y", 0, 0.2)

	else:
		tween.tween_property(self, "position:y", -100, 0.2)
	await tween.finished

#endregion
