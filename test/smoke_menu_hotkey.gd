## 冒烟测试: 游戏中 空格/Esc 快捷开关菜单
## 运行: Godot_console --headless --path <proj> -s res://test/smoke_menu_hotkey.gd
## 通过 quit(0); 失败/超时 quit(非0)
extends SceneTree

var _fail := false

func _init() -> void:
	## 看门狗
	var watchdog := create_timer(90.0)
	watchdog.timeout.connect(func():
		printerr("[SMOKE] 超时未完成")
		quit(3)
	)
	_run()

func _check(cond: bool, label: String) -> void:
	if cond:
		print("[PASS] ", label)
	else:
		_fail = true
		printerr("[FAIL] ", label)

func _press_key(keycode: Key) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	ev.physical_keycode = keycode
	ev.pressed = true
	Input.parse_input_event(ev)
	var ev_up := InputEventKey.new()
	ev_up.keycode = keycode
	ev_up.physical_keycode = keycode
	ev_up.pressed = false
	Input.parse_input_event(ev_up)

func _run() -> void:
	await process_frame
	await create_timer(0.5).timeout

	## --- 实例化战斗场景 ---
	var battle_scene: PackedScene = load("res://scenes/main/MainGame00Base.tscn")
	_check(battle_scene != null, "战斗场景可加载")
	if battle_scene == null:
		quit(1)
		return
	var battle := battle_scene.instantiate()
	root.add_child(battle)
	await create_timer(2.0).timeout

	## -s 模式编译期不能引用 autoload, 运行时取
	var G: Node = root.get_node_or_null("/root/Global")
	var manager: Node = G.main_game if G != null else null
	_check(G != null and manager != null, "MainGameManager 已就绪 (Global.main_game)")
	if G == null or manager == null:
		battle.queue_free()
		quit(1)
		return

	var dialog: Control = battle.find_child("MainGameMenuOptionDialog", true, false)
	_check(dialog != null, "找到菜单对话框节点")
	if dialog == null:
		battle.queue_free()
		quit(1)
		return
	var return_btn: BaseButton = dialog.get_node("Return")
	_check(return_btn != null, "找到 Return 关闭按钮")

	# === A. 门控: 选卡阶段(CHOOSE_CARD)按 Esc 不弹菜单 ===
	manager.main_game_progress = 1  # CHOOSE_CARD
	_press_key(KEY_ESCAPE)
	await create_timer(0.4).timeout
	_check(dialog.visible == false, "选卡阶段按 Esc 不弹菜单")

	# === B. 准备阶段(PREPARE): 直接调用切换 ===
	manager.main_game_progress = 2  # PREPARE
	dialog.toggle_menu_by_hotkey()
	await create_timer(0.4).timeout
	_check(dialog.visible == true, "PREPARE 阶段快捷键打开菜单")
	_check(paused == true, "打开菜单后游戏树暂停")
	_check(return_btn.has_focus(), "打开后焦点在 Return 按钮")

	dialog.toggle_menu_by_hotkey()
	await create_timer(0.4).timeout
	_check(dialog.visible == false, "再次切换关闭菜单")
	_check(paused == false, "关闭菜单后恢复运行")

	# === C. 真实按键路径: MAIN_GAME 阶段 Esc 打开 ===
	manager.main_game_progress = 3  # MAIN_GAME
	_press_key(KEY_ESCAPE)
	await create_timer(0.5).timeout
	_check(dialog.visible == true, "MAIN_GAME 阶段按 Esc 打开菜单")

	# === D. 菜单开着时按空格: 焦点按钮(Return)接收 ui_accept 关闭 ===
	_press_key(KEY_SPACE)
	await create_timer(0.6).timeout
	_check(dialog.visible == false, "菜单开启时按空格经焦点按钮关闭")

	# === E. 空格直接打开(MAIN_GAME) ===
	_press_key(KEY_SPACE)
	await create_timer(0.5).timeout
	_check(dialog.visible == true, "按空格直接打开菜单")

	# === F. Esc 再关闭 ===
	_press_key(KEY_ESCAPE)
	await create_timer(0.6).timeout
	_check(dialog.visible == false, "Esc 再收起菜单")
	_check(paused == false, "最终游戏树恢复运行")

	# === G. 游戏结束阶段(GAME_OVER)按 Esc 不弹菜单 ===
	manager.main_game_progress = 4  # GAME_OVER
	_press_key(KEY_ESCAPE)
	await create_timer(0.4).timeout
	_check(dialog.visible == false, "GAME_OVER 阶段按 Esc 不弹菜单")

	# 清理
	paused = false
	battle.queue_free()
	await create_timer(0.3).timeout

	print("========================================")
	if _fail:
		printerr("[SMOKE] 存在失败项 -> exit 1")
		quit(1)
	else:
		print("[SMOKE] 全部通过 -> exit 0")
		quit(0)
