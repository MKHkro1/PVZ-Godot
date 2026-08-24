extends Control
class_name ChooseLevel

## 用于生成关卡 ID 的计数
var next_level_number: int = 1

@onready var all_page: Control = $AllPage
@onready var label_page: Label = get_node_or_null("LabelPage")

## 游戏模式,用于管理关卡存档
@export var game_mode:Global.MainScenes = Global.MainScenes.Null
## 开放关卡数量，冒险默认为1，其余模式为3，若打开控制台开放所有关卡为-1
var open_level_num:int = -1
var all_pages_array : Array[GridContainer]
@export var curr_page := 0

## 选卡bgm
var bgm_choose_card: AudioStream = preload("res://assets/audio/BGM/choose_card.mp3")

func _ready() -> void:
	## 如果没有开放所有关卡
	if not Global.open_all_level:
		if game_mode == Global.MainScenes.ChooseLevelAdventure:
			open_level_num = 1
		## 自定义关卡全开放
		elif game_mode == Global.MainScenes.ChooseLevelCustom:
			open_level_num = -1
		else:
			open_level_num = 3
	else:
		open_level_num = -1
		
	for page_i in all_page.get_child_count():
		var page = all_page.get_child(page_i)
		all_pages_array.append(page)
		page.visible = false
		for node in page.get_children():
			## 如果是选关按钮
			if node is ChooseLevelButton:
				var level_id:String = generate_level_id()
				if node.curr_level_data_game_para == null:
					continue
				node.signal_choose_level_button.connect(_on_choose_level_button)
				## 从磁盘拷贝关卡参数, 避免 init_para 污染 .tres 缓存
				node.curr_level_data_game_para = _duplicate_level_para(node.curr_level_data_game_para)
				## 初始化游戏数据的选关数据
				node.curr_level_data_game_para.set_choose_level(game_mode, page_i, level_id)
				var curr_level_state_data:Dictionary= Global.curr_all_level_state_data.get(node.curr_level_data_game_para.save_game_name, {})
				node.update_curr_level_button_state(curr_level_state_data)
				update_lock_level(node, curr_level_state_data)

	print("当前模式关卡数量:", next_level_number - 1)

	_ready_update_page()

## 更新关卡是否锁住 无尽模式默认开放，不占用开放名额
func update_lock_level(choose_level_button:ChooseLevelButton, curr_level_state_data:Dictionary):
	## 如果开放名额为-1，即所有关卡都开发
	if open_level_num == -1:
		return
	## 无尽模式
	if choose_level_button.curr_level_data_game_para.game_round == -1:
		return
	## 如果当前关卡通关
	if curr_level_state_data.get("IsSuccess", false):
		return
	## 还有开发关卡名额
	if open_level_num > 0:
		open_level_num -= 1
		return
	else:
		choose_level_button.lock_choose_level_button()

func _ready_update_page():
	## 如果从游戏中退出
	if Global.game_para != null and Global.game_para.game_mode == game_mode:
		curr_page = Global.game_para.level_page

	if curr_page > all_pages_array.size():
		curr_page = 0
	if not all_pages_array.is_empty():
		all_pages_array[curr_page].visible = true
		if is_instance_valid(label_page):
			_update_page(curr_page)

	SoundManager.play_bgm(bgm_choose_card)

## 获取关卡id
func generate_level_id() -> String:
	# 用格式化字符串，让数字变成 4 位，前面补 0
	# GDScript 支持类似 C 风格字符串格式化
	var id_str = "%04d" % next_level_number  # 例如 0 -> "0000", 12 -> "0012"
	next_level_number += 1
	return id_str

func _duplicate_level_para(src: ResourceLevelData) -> ResourceLevelData:
	var res_path: String = src.get_level_res_path()
	if not res_path.is_empty():
		return Global.load_level_para(res_path)
	return src.duplicate(true)

func _on_choose_level_button(choose_level_button:ChooseLevelButton):
	var btn_para: ResourceLevelData = choose_level_button.curr_level_data_game_para
	var para: ResourceLevelData = _duplicate_level_para(btn_para)
	para.set_choose_level(btn_para.game_mode, btn_para.level_page, btn_para.level_id)
	Global.game_para = para
	choose_level_start_game(Global.game_para.game_sences)

## 进入游戏关卡
func choose_level_start_game(game_scense:Global.MainScenes):
	SceneTransition.change_scene(Global.MainScenesMap[game_scense])

## 返回开始菜单
func back_start_menu():
	SceneTransition.change_scene(Global.MainScenesMap[Global.MainScenes.StartMenu])


## Esc 快捷返回主菜单
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			back_start_menu()


func _on_last_pressed() -> void:
	_update_page(curr_page - 1)

func _on_next_pressed() -> void:
	_update_page(curr_page + 1)


func _update_page(new_page:int):
	new_page = posmod(new_page, all_pages_array.size())
	all_pages_array[curr_page].visible = false
	curr_page = new_page
	var page: GridContainer = all_pages_array[curr_page]
	page.visible = true
	## 部分模式场景没有页码 Label(如冒险), 守卫避免中断后续动画
	if is_instance_valid(label_page):
		label_page.text = "当前页数:" + str(curr_page + 1) + "/" + str(all_pages_array.size())
	## 翻页过渡: 淡入 + 轻微侧滑入场
	page.modulate.a = 0.0
	var target_x := page.position.x
	page.position.x = target_x + 46.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(page, "modulate:a", 1.0, 0.26)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(page, "position:x", target_x, 0.26)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
