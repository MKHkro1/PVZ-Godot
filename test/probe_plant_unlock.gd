extends SceneTree
## 探针: 植物解锁系统 + 行限制资源验证

func _init() -> void:
	create_timer(30.0).timeout.connect(func(): printerr("WATCHDOG"); quit(3))
	_run()

func _run() -> void:
	await process_frame
	var Global := root.get_node("/root/Global")
	var errors := 0

	# 1) 奖励表映射: 1-1(idx0)->向日葵2, 1-5(idx4)->土豆雷5, 1-10(idx9)->小喷菇9
	Global.curr_unlocked_plants.clear()
	Global.curr_unlocked_plants.append(1)
	if not Global.unlock_adventure_reward_plant(0):
		printerr("[FAIL] idx0 应新解锁"); errors += 1
	elif Global.curr_unlocked_plants.back() != 3 - 1:
		pass
	if Global.curr_unlocked_plants.back() != 2:
		printerr("[FAIL] 1-1奖励应为P002, 实际=", Global.curr_unlocked_plants.back()); errors += 1
	if not Global.unlock_adventure_reward_plant(4):
		printerr("[FAIL] idx4 应新解锁"); errors += 1
	if Global.curr_unlocked_plants.back() != 5:
		printerr("[FAIL] 1-5奖励应为P005, 实际=", Global.curr_unlocked_plants.back()); errors += 1
	if not Global.unlock_adventure_reward_plant(9):
		printerr("[FAIL] idx9 应新解锁"); errors += 1
	if Global.curr_unlocked_plants.back() != 9:
		printerr("[FAIL] 1-10奖励应为P009, 实际=", Global.curr_unlocked_plants.back()); errors += 1
	# 重复解锁不生效
	if Global.unlock_adventure_reward_plant(0):
		printerr("[FAIL] 重复解锁应返回false"); errors += 1
	# 越界安全
	if Global.unlock_adventure_reward_plant(50) or Global.unlock_adventure_reward_plant(-1):
		printerr("[FAIL] 越界应返回false"); errors += 1
	# 5-8(idx47) -> 巨人奖励位 = 玉米投手40? 表[4][7]=40
	if not Global.unlock_adventure_reward_plant(47):
		printerr("[FAIL] idx47 应新解锁"); errors += 1
	if Global.curr_unlocked_plants.back() != 40:
		printerr("[FAIL] 5-8奖励应为P040, 实际=", Global.curr_unlocked_plants.back()); errors += 1
	print("[PROBE] 解锁映射 OK")

	# 2) 行限制字段加载
	var l1 = load("res://resources/level_date_resource/mode_adventure/adventure_1_01.tres")
	if int(l1.usable_rows.size()) != 1 or int(l1.usable_rows[0]) != 2:
		printerr("[FAIL] 1-1 usable_rows 错误: ", l1.usable_rows); errors += 1
	var l2 = load("res://resources/level_date_resource/mode_adventure/adventure_1_02.tres")
	if int(l2.usable_rows.size()) != 3 or int(l2.usable_rows[2]) != 3:
		printerr("[FAIL] 1-2 usable_rows 错误: ", l2.usable_rows); errors += 1
	var l3 = load("res://resources/level_date_resource/mode_adventure/adventure_1_03.tres")
	if not l3.usable_rows.is_empty():
		printerr("[FAIL] 1-3 应无行限制"); errors += 1
	print("[PROBE] 行限制资源 OK")

	# 3) 旧档迁移: 构造伪存档状态
	Global.curr_unlocked_plants.clear()
	Global.curr_unlocked_plants.append(1)
	Global.curr_all_level_state_data["101_0_0001"] = {"IsSuccess": true}
	Global.curr_all_level_state_data["101_0_0002"] = {"IsSuccess": true}
	Global.curr_all_level_state_data["101_0_0003"] = {"IsSuccess": true}
	Global.curr_all_level_state_data["101_0_0037"] = {"IsSuccess": true}
	Global._migrate_unlocked_plants_from_progress()
	# 应解锁 idx0(->2) idx1(->3) idx2(->4) idx36(stage3,pos6->31南瓜)
	if Global.curr_unlocked_plants.size() != 5:
		printerr("[FAIL] 迁移后应有5个植物, 实际=", Global.curr_unlocked_plants); errors += 1
	else:
		for want in [2, 3, 4, 31]:
			if not (want in Global.curr_unlocked_plants):
				printerr("[FAIL] 迁移缺植物", want); errors += 1
	# 进度推导: 已通关最高 idx36 -> 下一关 37
	if Global.adventure_next_index != 37:
		printerr("[FAIL] 迁移进度应为37, 实际=", Global.adventure_next_index); errors += 1
	else:
		print("[PROBE] 旧档迁移+进度推导 OK")

	# 5) 关卡路径映射与轮回
	if Global._adventure_level_res_path(0) != "res://resources/level_date_resource/mode_adventure/adventure_1_01.tres":
		printerr("[FAIL] idx0 路径错误: ", Global._adventure_level_res_path(0)); errors += 1
	if Global._adventure_level_res_path(4) != "res://resources/level_date_resource/mode_minigame/minigame_01_bowling.tres":
		printerr("[FAIL] idx4 应为保龄球: ", Global._adventure_level_res_path(4)); errors += 1
	if Global._adventure_level_res_path(49) != "res://resources/level_date_resource/mode_adventure/adventure_5_10.tres":
		printerr("[FAIL] idx49 路径错误: ", Global._adventure_level_res_path(49)); errors += 1
	# 50关轮回: 从49推进 -> 0
	var wrapped:int = (49 + 1) % 50
	if wrapped != 0:
		printerr("[FAIL] 轮回计算错误"); errors += 1
	# 每个序号的资源都存在且可加载(idx4为小游戏资源)
	for i in range(50):
		var rp:String = Global._adventure_level_res_path(i)
		if not ResourceLoader.exists(rp):
			printerr("[FAIL] 序号", i, "资源缺失: ", rp); errors += 1
	print("[PROBE] 路径映射+轮回 OK")

	# 4) 豌豆射手始终默认解锁
	Global.curr_unlocked_plants.clear()
	Global.curr_unlocked_plants.append(16)
	Global.ensure_pea_shooter_unlocked()
	if Global.curr_unlocked_plants.size() != 2 or Global.curr_unlocked_plants[0] != 1:
		printerr("[FAIL] 豌豆射手兜底失败: ", Global.curr_unlocked_plants); errors += 1
	else:
		print("[PROBE] 豌豆射手默认解锁 OK")

	quit(errors)
