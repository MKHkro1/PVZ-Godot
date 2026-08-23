extends Node
class_name ZombieChooseRowSystem
## 出怪算行系统 —— 复刻原版 PvZ 的出怪算行算法(mZombieRowWeight):
## · 每行维护一个出怪权重, 初始 1000
## · 选行时仅在「该僵尸类型可出现的行」中按权重加权随机
## · 每选中一行, 该行权重 -500 → 大幅降低连续扎堆同一路的概率
## · 权重随时间恢复, 上限 1000 → 长期各路机会均等, 短期保留自然起伏

## 初始/上限权重(原版 mZombieRowWeight 初值)
const WEIGHT_INIT := 1000.0
## 每次选中后的扣减量
const WEIGHT_PICK_COST := 220.0
## 权重每秒恢复速率
const WEIGHT_REGEN_PER_SEC := 60.0
## 权重下限: 耗尽的行仍保留极低可选概率(原版行为), 不会彻底出局
const WEIGHT_MIN_FLOOR := 50.0
## 丢车(小推车被消耗)后该行暂停出怪的时长(原版行为)
const ROW_SUPPRESS_AFTER_MOWER := 10.0

## 各行当前权重
var row_weights: Array[float] = []
## 各行剩余禁刷时间(丢车触发, 秒)
var row_suppress_left: Array[float] = []
## 行类型掩码(Land/Pool/Both), 决定各类型僵尸可出现的行
var base_weigth_all_type :Dictionary[Global.ZombieRowType, Array]


func _process(delta: float) -> void:
	## 权重随时间恢复, 上限 WEIGHT_INIT
	for i in range(row_weights.size()):
		row_weights[i] = minf(row_weights[i] + WEIGHT_REGEN_PER_SEC * delta, WEIGHT_INIT)
	## 丢车禁刷倒计时
	for i in range(row_suppress_left.size()):
		if row_suppress_left[i] > 0.0:
			row_suppress_left[i] = maxf(row_suppress_left[i] - delta, 0.0)


## 初始化系统
func init_zombie_choose_row_system():
	var ori_weight_land:Array[float] = []
	var ori_weight_pool:Array[float] = []
	var ori_weight_both:Array[float] = []
	for zombie_row_node: ZombieRow in Global.main_game.zombie_manager.all_zombie_rows:
		match zombie_row_node.zombie_row_type:
			Global.ZombieRowType.Land:
				ori_weight_land.append(1)
				ori_weight_pool.append(0)
			Global.ZombieRowType.Pool:
				ori_weight_land.append(0)
				ori_weight_pool.append(1)
			Global.ZombieRowType.Both:
				ori_weight_land.append(1)
				ori_weight_pool.append(1)
		ori_weight_both.append(1.0)

	base_weigth_all_type = {
		Global.ZombieRowType.Land:ori_weight_land,
		Global.ZombieRowType.Pool:ori_weight_pool,
		Global.ZombieRowType.Both:ori_weight_both
	}

	row_weights.clear()
	row_weights.resize(Global.main_game.zombie_manager.all_zombie_rows.size())
	row_weights.fill(WEIGHT_INIT)

	row_suppress_left.clear()
	row_suppress_left.resize(Global.main_game.zombie_manager.all_zombie_rows.size())
	row_suppress_left.fill(0.0)


## 丢车: 该行一段时间内不再出怪(原版行为)
func on_mower_lost(lane: int):
	if lane >= 0 and lane < row_suppress_left.size():
		row_suppress_left[lane] = ROW_SUPPRESS_AFTER_MOWER


## 更新权重: 每次实际出怪后扣减该行权重(原版行为)
func on_zombie_spawned(row_index: int):
	assert(row_index >= 0 and row_index < row_weights.size(), "行号越界")
	row_weights[row_index] -= WEIGHT_PICK_COST


## 计算各行参与抽签的最终权重
## (special_base_weight 为行有效性掩码, 如雪橇车的冰道限制)
## apply_suppress=false 时忽略丢车禁刷(全行禁刷时的兜底)
func calculate_smooth_weights(zombie_row_type: Global.ZombieRowType, special_base_weight: Array = [], apply_suppress: bool = true) -> Array:
	var weights: Array[float] = []
	var mask: Array = special_base_weight
	if mask.is_empty() and base_weigth_all_type.has(zombie_row_type):
		mask = base_weigth_all_type[zombie_row_type]

	## 冒险模式行限制(原版1-1单行/1-2三行): 限定行之外不参与抽签
	var usable_rows: Array[int] = []
	if Global.main_game != null and Global.main_game.game_para != null:
		usable_rows = Global.main_game.game_para.usable_rows

	for i in range(row_weights.size()):
		var eligible := i < mask.size() and float(mask[i]) > 0.0
		if eligible and not usable_rows.is_empty() and not (i in usable_rows):
			eligible = false  ## 行限制外的行不参与抽签
		if eligible and apply_suppress and i < row_suppress_left.size() and row_suppress_left[i] > 0.0:
			eligible = false  ## 丢车禁刷中的行不参与抽签
		weights.append(maxf(row_weights[i], WEIGHT_MIN_FLOOR) if eligible else 0.0)

	return weights


## 选择下一个出怪行: 有效行内按权重加权随机, 选中后立即扣减该行权重
## 权重全部耗尽时(大波快速连出), 在有效行内退化为均匀随机, 始终不越掩码
func select_spawn_row(zombie_row_type: Global.ZombieRowType, special_base_weight: Array = []) -> int:
	var smooth_weights := calculate_smooth_weights(zombie_row_type, special_base_weight)

	var candidates: Array[int] = []
	var total := 0.0
	for i in range(smooth_weights.size()):
		if smooth_weights[i] > 0.0:
			candidates.append(i)
			total += smooth_weights[i]

	## 兜底: 全部候选行都在丢车禁刷中 → 忽略禁刷照常出怪
	if candidates.is_empty() and _has_any_suppress():
		smooth_weights = calculate_smooth_weights(zombie_row_type, special_base_weight, false)
		for i in range(smooth_weights.size()):
			if smooth_weights[i] > 0.0:
				candidates.append(i)
				total += smooth_weights[i]

	## 该类型无任何有效行(正常流程外部已保证至少一行有效)
	if candidates.is_empty():
		push_warning("出怪算行: 当前僵尸类型没有可出现的行")
		return 0

	var chosen: int
	if total <= 0.0:
		## 权重耗尽: 有效行内均匀随机
		chosen = candidates.pick_random()
	else:
		var rand_num := randf_range(0.0, total)
		var cumulative := 0.0
		chosen = candidates[candidates.size() - 1]
		for idx in range(candidates.size()):
			cumulative += smooth_weights[candidates[idx]]
			if cumulative >= rand_num:
				chosen = candidates[idx]
				break

	on_zombie_spawned(chosen)
	return chosen


## 是否有任意行处于丢车禁刷中
func _has_any_suppress() -> bool:
	for t in row_suppress_left:
		if t > 0.0:
			return true
	return false


