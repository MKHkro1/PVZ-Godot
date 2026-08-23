extends ComponentNormBase
class_name MoveComponent
## 根据ground节点移动\速度移动的组件
## 移动组件只和owner的is_walk属性、_ground节点和AnimationTree节点有关
## 移动组件要求owner必须有is_walk属性

@onready var owner_zombie: Zombie000Base = owner
@onready var _ground: Sprite2D = get_node_or_null("../Body/BodyCorrect/_ground")
@onready var body: BodyCharacter = %Body

## 移动方式
enum E_MoveMode {
	Ground,	## 根据ground节点移动
	Speed,	## 根据速度移动
}

## 斜面移动的y值,斜面时每帧更新
var y_value_correct_slope:float = 0
## 屋顶斜坡 移动方向y值修正,移动时,对应y方向的修正,
var move_dir_y_correct_slope:Vector2 = Vector2.ZERO

## 爬梯下降的速度
const SpeedLadderDown:float=100
## 每次爬梯子移动的最大x值
const MaxXOnLadderUp :float = 25
## 爬梯移动的y值,爬梯时每帧更新
var y_value_correct_ladder:float = 0
## 爬梯移动上升的y累计值,爬梯时每帧更新,爬梯完成后下来
var sum_y_value_correct_ladder_up:float = 0
## 爬梯移动下降的y累计值,爬梯时每帧更新
var sum_y_value_correct_ladder_down:float = 0
## 梯子移动y值修正方向,根据状态决定上下移动
var move_dir_y_correct_ladder:Vector2 = Vector2(1, 2.5)
## 爬梯子时移动的x值
var x_on_ladder:float = 0
## 爬梯子状态
var ladder_state :E_LadderState = E_LadderState.None
enum E_LadderState{
	None,
	Up,
	Down,
}

@export var move_mode:E_MoveMode = E_MoveMode.Ground
## 根据速度移动
@export var ori_speed :float = 20
var curr_speed :float = 20
var curr_speed_product :float
var curr_speed_move :float = 1

## 根据ground移动
## 上一帧的ground节点位置
var _previous_ground_global_x:float
## 移动状态
enum WalkingStatus {start, walking, end}
var walking_status := WalkingStatus.end

## 是否移动
var is_move := true

## 移动因素
var move_factors:Dictionary[E_MoveFactor, bool] = {}

## 影响移动的因素、跳跃、舞王入场被卡、伴舞攻击
enum E_MoveFactor{
	IsDisable,			## 组件禁用
	IsCharacter,		## 特殊角色本身(使用该因素不能有冲突)
	IsAttack,			## 攻击
	IsBombDeath,		## 被炸死
	IsJump,				## 跳跃
	IsJacksonEnterPlant,	## 舞王入场被植物卡住
	IsDancerAttack,			## 伴舞攻击
	IsSwimingChange,		## 进入或离开泳池间隙
	IsAnimGap,				## 动画过度间隙
	IsBlover,				## 被三叶草吹走
	IsDeath,				## 停止移动的死亡时
}

signal signal_move_body_y(move_y_value:float)

func _ready() -> void:
	super()
	curr_speed = ori_speed

## 根据角色速度修改移动速度
func owner_update_speed(speed_product:float):
	curr_speed = ori_speed * speed_product * curr_speed_move
	curr_speed_product = speed_product

## 角色速度不变的情况下,只修改移动速度,(跳跳僵尸使用)
func update_only_move_speed(new_speed_move:float=1):
	self.curr_speed_move = new_speed_move
	curr_speed = ori_speed * curr_speed_product * self.curr_speed_move

## 更新影响移动的因素 true表示不移动
func update_move_factor(value:bool, move_factor:E_MoveFactor):
	move_factors[move_factor] = value
	## 全为false时移动
	is_move = move_factors.values().all(func(v): return v == false)
	if is_move:
		_walking_start()

## 获取除了伴舞攻击因素之外的移动结果
func get_exclude_dancer_move_res():
	# 除了 IsDancerAttack，其他 factor 只要有 true 就不能移动
	return not move_factors.keys().any(
		func(k): return k != E_MoveFactor.IsDancerAttack and move_factors[k] == true
	)

func update_move_mode(new_move_mode:E_MoveMode):
	move_mode = new_move_mode

func _process(delta: float) -> void:
	if ladder_state == E_LadderState.Down:
		move_y_correct_ladder_down(delta)
	if is_move:
		match move_mode:
			E_MoveMode.Ground:
				if walking_status == WalkingStatus.end:
					_previous_ground_global_x = _ground.global_position.x
				elif walking_status == WalkingStatus.start:
					walking_status = WalkingStatus.walking
					_previous_ground_global_x = _ground.global_position.x
				else:
					_walk()

			E_MoveMode.Speed:
				var move_x = delta * curr_speed * owner_zombie.direction_x_root
				owner_zombie.position.x -= move_x

				move_y_correct(move_x)

func _walk():
	# 计算ground的全局坐标变化量
	var ground_global_offset = _ground.global_position.x - _previous_ground_global_x
	# 反向调整zombie的position.x以抵消ground的移动
	owner_zombie.position.x -= ground_global_offset
	# 更新记录值
	_previous_ground_global_x = _ground.global_position.x
	move_y_correct(ground_global_offset)

## 移动y方向上的修正
func move_y_correct(move_x:float):
	## 斜面移动修正
	if move_dir_y_correct_slope != Vector2.ZERO:
		move_y_correct_slope(move_x)
	if ladder_state == E_LadderState.Up:
		move_y_correct_ladder_up(move_x)

## 移动y的方向修正_斜面
func move_y_correct_slope(move_x:float):
	y_value_correct_slope = -move_x / move_dir_y_correct_slope.x * move_dir_y_correct_slope.y
	signal_move_body_y.emit(y_value_correct_slope)

## 爬梯移动修正y,只修改body y值
func move_y_correct_ladder_up(move_x:float):
	## 梯子移动修正
	x_on_ladder += abs(move_x)
	y_value_correct_ladder = -abs(move_x) / move_dir_y_correct_ladder.x * move_dir_y_correct_ladder.y
	sum_y_value_correct_ladder_up -= y_value_correct_ladder
	body.position.y += y_value_correct_ladder
	if x_on_ladder >= MaxXOnLadderUp:
		ladder_state = E_LadderState.Down

## 下降状态 爬梯移动修正y,每帧更新,
func move_y_correct_ladder_down(delta: float):
	y_value_correct_ladder = SpeedLadderDown * delta
	sum_y_value_correct_ladder_down += y_value_correct_ladder
	if sum_y_value_correct_ladder_down > sum_y_value_correct_ladder_up:
		y_value_correct_ladder -= sum_y_value_correct_ladder_down - sum_y_value_correct_ladder_up
		ladder_state = E_LadderState.None
	body.position.y +=  y_value_correct_ladder

## 开始爬梯子
func start_ladder():
	if ladder_state != E_LadderState.None:
		#printerr("正在爬梯子,无法继续爬梯子")
		pass
	else:
		x_on_ladder = 0
		sum_y_value_correct_ladder_up = 0
		sum_y_value_correct_ladder_down = 0
		ladder_state = E_LadderState.Up

func _walking_start():
	walking_status = WalkingStatus.start
	#print(111,"walk is start")

func _walking_end():
	walking_status = WalkingStatus.end
	#print(111,"walk is end")

func update_previous_ground_global_x():
	_previous_ground_global_x = _ground.global_position.x

## 动画结束时
@warning_ignore("unused_parameter")
func _on_animation_finished(anim_name: StringName) -> void:
	_walking_end()

### 动画开始时
#func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	#_walking_start()


## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	if is_enabling:
		update_move_factor(false, E_MoveFactor.IsDisable)

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	update_move_factor(true, E_MoveFactor.IsDisable)
