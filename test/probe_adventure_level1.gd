extends SceneTree

func _init() -> void:
	create_timer(30.0).timeout.connect(func(): printerr("WATCHDOG"); quit(3))
	call_deferred("_run")

func _run() -> void:
	await process_frame
	await process_frame
	var Global := root.get_node("/root/Global")
	var errors := 0

	# 污染模拟: 对缓存资源 init_para(旧 bug 路径)
	var cached: ResourceLevelData = load("res://resources/level_date_resource/mode_adventure/adventure_1_01.tres")
	cached.is_zomboss_fight = true
	cached.init_para()
	if cached.is_zomboss_fight:
		printerr("[FAIL] sanitize should clear zomboss on polluted 1-1 without level_id"); errors += 1

	# 带 level_id 的 sanitize
	var polluted: ResourceLevelData = cached.duplicate(true)
	polluted.is_zomboss_fight = true
	polluted.set_choose_level(Global.MainScenes.ChooseLevelAdventure, 0, "0001")
	polluted.init_para()
	if polluted.is_zomboss_fight:
		printerr("[FAIL] 1-1(level_id=0001) should not stay zomboss after init_para"); errors += 1

	# start_adventure idx0
	Global.adventure_next_index = 0
	Global.start_adventure_next_level()
	if Global.game_para == null:
		printerr("[FAIL] game_para null"); errors += 1
	elif Global.game_para.is_zomboss_fight:
		printerr("[FAIL] idx0 is_zomboss_fight=true"); errors += 1
	elif Global.game_para.level_id != "0001":
		printerr("[FAIL] level_id=", Global.game_para.level_id); errors += 1
	else:
		print("[OK] adventure 1-1: level_id=", Global.game_para.level_id,
			" zomboss=", Global.game_para.is_zomboss_fight,
			" path=", Global.game_para.get_level_res_path())

	# idx49 应为僵王
	var boss_para: ResourceLevelData = Global.load_level_para(Global._adventure_level_res_path(49))
	boss_para.set_choose_level(Global.MainScenes.ChooseLevelAdventure, 4, "0050")
	boss_para.init_para()
	if not boss_para.is_zomboss_fight:
		printerr("[FAIL] idx49 should be zomboss"); errors += 1
	else:
		print("[OK] adventure 5-10 zomboss flag kept")

	if errors == 0:
		print("[OK] probe_adventure_level1 passed")
	else:
		printerr("[FAIL] errors=", errors)
	quit(1 if errors else 0)
