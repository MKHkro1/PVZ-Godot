extends SceneTree
## 探针: 原版出怪算行算法行为验证(权重扣减/恢复/行掩码/防扎堆)

func _init() -> void:
	create_timer(45.0).timeout.connect(func(): printerr("WATCHDOG"); quit(3))
	_run()

func _fill_weights(sys: Node, v: float) -> void:
	var w: Array[float] = []
	w.resize(6)
	w.fill(v)
	sys.row_weights.assign(w)

func _run() -> void:
	await process_frame
	print("[PROBE] start")
	var sys_script: Script = load("res://scripts/manager/zombie_manager/zm_zombie_choose_row_system.gd")
	var sys: Node = sys_script.new()
	_fill_weights(sys, 1000.0)
	root.add_child(sys)
	await create_timer(0.2).timeout
	print("[PROBE] 入树后 size=", sys.row_weights.size(), " w0=", sys.row_weights[0])
	var LAND_MASK := [1, 1, 1, 1, 0, 0]

	var sw_dbg: Array = sys.calculate_smooth_weights(0, LAND_MASK)
	print("[PROBE] smooth=", sw_dbg)
	var lane_lit: int = sys.select_spawn_row(0, [1, 1, 1, 1, 0, 0])
	print("[PROBE] 内联掩码 pick=", lane_lit)
	var bad := 0
	for i in range(50):
		var lane: int = sys.select_spawn_row(0, LAND_MASK)
		if lane < 0 or lane > 3:
			bad += 1
	if bad == 0:
		print("[PASS] 掩码下僵尸只出现在有效行 (50 次采样)")
	else:
		printerr("[FAIL] 越界行 %d 次" % bad)

	_fill_weights(sys, 1000.0)
	var picked: int = sys.select_spawn_row(0, LAND_MASK)
	print("[PROBE] B 选中行 %d 权重=%.0f" % [picked, sys.row_weights[picked]])
	if sys.row_weights[picked] < 880.0 and sys.row_weights[picked] > 700.0:
		print("[PASS] 选中行权重已按代价扣减")
	else:
		printerr("[FAIL] 权重扣减异常")

	# === C/D. 波次化防扎堆 + 分布均匀(贴近真实节奏: 波内连出, 波间恢复) ===
	var counts := [0, 0, 0, 0, 0, 0]
	var max_run := 0
	for wave_i in range(5):
		_fill_weights(sys, 1000.0)
		await create_timer(0.1).timeout
		var last_row := -1
		var curr_run := 0
		for i in range(30):
			if i % 10 == 0:
				await process_frame
			var r: int = sys.select_spawn_row(0, LAND_MASK)
			counts[r] += 1
			if r == last_row:
				curr_run += 1
			else:
				curr_run = 1
				last_row = r
			max_run = maxi(max_run, curr_run)
	print("[PROBE] C 各路计数: ", [counts[0], counts[1], counts[2], counts[3]], " 最长连续同路=", max_run)
	if max_run <= 3:
		print("[PASS] 无长时间扎堆同一路")
	else:
		printerr("[FAIL] 异常扎堆 max_run=%d" % max_run)
	var mini_v := mini(mini(counts[0], counts[1]), mini(counts[2], counts[3]))
	var maxi_v := maxi(maxi(counts[0], counts[1]), maxi(counts[2], counts[3]))
	if float(maxi_v) / float(maxi(mini_v, 1)) < 2.5:
		print("[PASS] 长期分布接近均等 (%d/%d)" % [mini_v, maxi_v])
	else:
		printerr("[FAIL] 分布失衡 %d/%d" % [mini_v, maxi_v])

	_fill_weights(sys, 1000.0)
	var ice_ok := true
	for i in range(30):
		var r2: int = sys.select_spawn_row(0, [0, 1, 0, 1, 0, 0])
		if r2 != 1 and r2 != 3:
			ice_ok = false
	if ice_ok:
		print("[PASS] 冰道掩码下只选有效行")
	else:
		printerr("[FAIL] 冰道掩码失效")

	# === G. 丢车禁刷: 该行暂停出怪, 全禁时兜底, 解除后恢复 ===
	_fill_weights(sys, 1000.0)
	var sup := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	sup[2] = 10.0
	sys.row_suppress_left.assign(sup)
	var g_ok := true
	for i in range(60):
		if sys.select_spawn_row(0, LAND_MASK) == 2:
			g_ok = false
	if g_ok:
		print("[PASS] 丢车行在禁刷期内不出怪 (60 次采样)")
	else:
		printerr("[FAIL] 禁刷行仍被选中")

	var sup_all := [5.0, 5.0, 5.0, 5.0, 5.0, 5.0]
	sys.row_suppress_left.assign(sup_all)
	var r_all: int = sys.select_spawn_row(0, LAND_MASK)
	if r_all >= 0 and r_all <= 3:
		print("[PASS] 全部候选行禁刷时兜底照常出怪 (lane=%d)" % r_all)
	else:
		printerr("[FAIL] 全禁兜底异常 lane=%d" % r_all)

	var cleared := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	sys.row_suppress_left.assign(cleared)
	var seen2 := false
	for i in range(200):
		if sys.select_spawn_row(0, LAND_MASK) == 2:
			seen2 = true
			break
	if seen2:
		print("[PASS] 禁刷解除后该行恢复出怪")
	else:
		printerr("[FAIL] 解除后仍未出怪")

	_fill_weights(sys, 0.0)
	await create_timer(1.1).timeout
	print("[PROBE] F 1 秒后 w0=%.0f" % sys.row_weights[0])
	if sys.row_weights[0] > 30.0 and sys.row_weights[0] < 120.0:
		print("[PASS] 权重随时间恢复")
	else:
		printerr("[FAIL] 恢复异常")

	print("[PROBE] done")
	quit(0)

