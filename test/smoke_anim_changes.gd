extends SceneTree
## 临时脚本:动画改动运行时冒烟测试(阳光收集/种植弹跳/卡片冷却闪光)
## 注意:-s 模式下本脚本先于 autoload 编译,不能在编译期引用项目全局类,
## 所有项目脚本一律运行时 load() 获取。

var fail_count := 0

func _initialize() -> void:
	## 看门狗:任何协程中断都不会让进程挂死
	create_timer(90.0).timeout.connect(func():
		printerr("WATCHDOG TIMEOUT")
		quit(3)
	)
	_run()

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS  ", msg)
	else:
		fail_count += 1
		printerr("FAIL  ", msg)

func _run() -> void:
	await process_frame

	# ---------- 1. 阳光收集 ----------
	var sun_scene: PackedScene = load("res://scenes/item/game_scenes_item/sun.tscn")
	var sun = sun_scene.instantiate()
	root.add_child(sun)
	await process_frame
	await process_frame
	_check(sun.collected == false, "sun 初始未收集")
	sun._on_button_pressed()
	_check(sun.collected == true, "sun 点击后标记已收集")
	await create_timer(1.0).timeout
	_check(is_instance_valid(sun) == false, "sun 收集动画结束后被释放")

	# ---------- 2. 植物种植弹跳(正常出战初始化) ----------
	var plant_base_script = load("res://scripts/character/plant/plant_000_base.gd")
	var char_base_script = load("res://scripts/character/character_000_base.gd")
	var plant_cell_script = load("res://scripts/main_game_item/plant_cell.gd")
	var plant_scene: PackedScene = load("res://scenes/character/plant/plant_001_pea_shooter_single.tscn")
	var plant = plant_scene.instantiate()
	var para := {}
	para[plant_base_script.E_PInitAttr.CharacterInitType] = char_base_script.E_CharacterInitType.IsNorm
	para[plant_base_script.E_PInitAttr.PlantCell] = plant_cell_script.new()
	plant.init_plant(para)
	root.add_child(plant)
	await process_frame
	await process_frame
	if not is_instance_valid(plant):
		fail_count += 1
		printerr("FAIL  植物实例化失败")
	else:
		var scale_during_pop: Vector2 = plant.body.scale
		# 等弹跳结束(0.1+0.16s + 余量)
		await create_timer(0.8).timeout
		var scale_after_pop: Vector2 = plant.body.scale
		print("      弹跳中 scale=", scale_during_pop, " 结束后 scale=", scale_after_pop)
		_check(scale_after_pop.is_equal_approx(Vector2.ONE), "植物 body 缩放回到 (1,1)")
		plant.queue_free()
		await process_frame

	# ---------- 3. 卡片冷却完成闪亮(手工搭最小节点树,绕开无头环境数据依赖) ----------
	var card_script = load("res://scripts/ui/card/card.gd")
	var card = card_script.new()
	var bg := TextureRect.new(); bg.name = "CardBg"; bg.size = Vector2(100, 140)
	var cost := Label.new(); cost.name = "Cost"
	bg.add_child(cost)
	card.add_child(bg)
	var short_cut := Label.new(); short_cut.name = "ShortCut"; card.add_child(short_cut)
	var btn := Button.new(); btn.name = "Button"; card.add_child(btn)
	var mask := ProgressBar.new(); mask.name = "ProgressBar"; card.add_child(mask)
	root.add_child(card)
	await process_frame
	card.card_cool()
	_check(card.is_can_click == false, "卡片冷却中不可点击")
	card.judge_sun_enough(9999)
	_check(card.is_can_click == false, "阳光充足但冷却未结束仍不可点击")
	## 把冷却计时拨到即将结束,让卡片自身 _process 走真实的冷却完成路径
	card._cool_timer = 0.001
	await process_frame
	await process_frame
	_check(card.is_can_click == true, "冷却计时结束恢复可点击")
	var flash_color: Color = card.card_bg.modulate
	print("      闪光起始 modulate=", flash_color)
	_check(flash_color.r > 1.0, "冷却完成触发闪亮(modulate 提亮)")
	# 同状态下重复判定不应重复触发;等闪光结束后应停在白色
	card.judge_sun_enough(9999)
	await create_timer(1.0).timeout
	var rest_color: Color = card.card_bg.modulate
	_check(rest_color.is_equal_approx(Color.WHITE), "闪光结束恢复白色")

	print("RESULT=", "PASS" if fail_count == 0 else "FAIL(%d)" % fail_count)
	quit(0 if fail_count == 0 else 1)
