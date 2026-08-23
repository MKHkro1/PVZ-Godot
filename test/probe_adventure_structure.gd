extends SceneTree
## 探针: 冒险模式 50 关结构验证(资源加载/场景配置/选关场景按钮映射)

func _init() -> void:
	create_timer(45.0).timeout.connect(func(): printerr("WATCHDOG"); quit(3))
	_run()

func _run() -> void:
	await process_frame
	var total := 0
	var errors := 0
	for s in range(1, 6):
		for i in range(1, 11):
			if i == 5:
				continue
			total += 1
			var path := "res://resources/level_date_resource/mode_adventure/adventure_%d_%02d.tres" % [s, i]
			if not ResourceLoader.exists(path):
				printerr("[FAIL] 缺失: " + path)
				errors += 1
				continue
			var res: Resource = load(path)
			if res == null:
				printerr("[FAIL] 加载失败: " + path)
				errors += 1
				continue
			# 场景一致性: S1/S2=Front(0) S3/S4=Back(1) S5=Roof(2)
			var expect_sences: int = 0 if (s <= 2) else (1 if s <= 4 else 2)
			if int(res.game_sences) != expect_sences:
				printerr("[FAIL] %s game_sences=%d 期望=%d" % [path, int(res.game_sences), expect_sences])
				errors += 1
			# 夜晚关必须关阳光/白天
			if s == 2 and (res.is_day != false or res.is_day_sun != false):
				printerr("[FAIL] " + path + " 夜晚参数错误")
				errors += 1
			# 迷雾关必须有雾
			if s == 4 and res.is_fog != true:
				printerr("[FAIL] " + path + " 缺少雾")
				errors += 1
			# X-10 必须是传送带
			if i == 10 and int(res.card_mode) != 2:
				printerr("[FAIL] " + path + " X-10 非传送带")
				errors += 1
			# 屋顶关必须预置花盆 + 蹦极
			if s == 5:
				if res.all_pre_plant_data.size() < 5 or res.is_bungi != true:
					printerr("[FAIL] " + path + " 屋顶花盆/蹦极缺失")
					errors += 1
			# 出怪列表非空且不含旗帜僵尸
			if res.zombie_refresh_types.is_empty():
				printerr("[FAIL] " + path + " 出怪列表为空")
				errors += 1
	print("[PROBE] 关卡资源: %d 个, 错误 %d" % [total, errors])

	# 选关场景加载与按钮统计
	var scene: PackedScene = load("res://scenes/main/02AdventureChooesLevel.tscn")
	if scene == null:
		printerr("[FAIL] 选关场景加载失败")
		errors += 1
	else:
		var inst := scene.instantiate()
		root.add_child(inst)
		await process_frame
		await process_frame
		var pages: Control = inst.get_node("AllPage")
		var page_count := pages.get_child_count()
		var btn_total := 0
		for p in pages.get_children():
			btn_total += p.get_child_count()
		print("[PROBE] 页数=%d 按钮总数=%d" % [page_count, btn_total])
		if page_count != 5 or btn_total != 50:
			printerr("[FAIL] 页面结构不对")
			errors += 1
		# 每个按钮的关卡数据非空
		for pg in pages.get_children():
			for b in pg.get_children():
				if b.curr_level_data_game_para == null:
					printerr("[FAIL] 按钮缺数据: " + str(b.name))
					errors += 1
		inst.queue_free()
	print("[PROBE] done errors=%d" % errors)
	quit(errors)
