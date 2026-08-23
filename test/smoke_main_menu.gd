extends SceneTree
## 主界面优化冒烟测试:入场动画落位 / 按钮悬停缩放 / 场景切换过渡

var fail_count := 0

func _initialize() -> void:
	create_timer(120.0).timeout.connect(func():
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

	# ---------- 1. 主界面入场 ----------
	var menu_scene: PackedScene = load("res://scenes/main/01StartMenu.tscn")
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	await process_frame
	## 等入场动画全部结束(最长 0.55+0.4s)
	await create_timer(2.0).timeout
	var groups := ["BG_Right/Menu", "BG_Right/Flower", "BG_Right/Item", "BG_Right/Option", "BG_Right/CustomButton"]
	for gp in groups:
		var c: Control = menu.get_node(NodePath(gp))
		_check(is_equal_approx(c.modulate.a, 1.0), "入场后不透明 %s (a=%.2f)" % [gp, c.modulate.a])
	# 位置稳定(两次采样一致说明 tween 已收尾)
	var m: Control = menu.get_node(NodePath("BG_Right/Menu"))
	var p1: Vector2 = m.position
	await create_timer(0.5).timeout
	_check(m.position.is_equal_approx(p1), "入场后位置稳定不再漂移")

	# ---------- 2. 按钮悬停缩放 ----------
	var btn: BaseButton = menu.get_node(NodePath("BG_Right/Menu/Button1"))
	btn.mouse_entered.emit()
	await create_timer(0.35).timeout
	print("      hover scale=", btn.scale)
	_check(absf(btn.scale.x - 1.06) < 0.01, "悬停放大到 1.06")
	btn.mouse_exited.emit()
	await create_timer(0.35).timeout
	_check(absf(btn.scale.x - 1.0) < 0.01, "移出恢复 1.0")

	# ---------- 3. 场景切换过渡 ----------
	var st = root.get_node("SceneTransition")
	st.change_scene("res://scenes/main/02AdventureChooesLevel.tscn")
	## 过渡提速后固定延时可能错过黑屏窗口, 改为逐帧轮询采样变暗峰值
	var darkened := false
	for i in range(60):
		await process_frame
		if st._rect.color.a > 0.5:
			darkened = true
			break
	_check(darkened, "切换中屏幕变暗")
	await create_timer(1.5).timeout
	_check(not st._is_transitioning, "过渡结束状态复位")
	_check(is_equal_approx(st._rect.color.a, 0.0), "遮罩淡出恢复透明")
	var cs = current_scene
	_check(cs != null and cs.scene_file_path == "res://scenes/main/02AdventureChooesLevel.tscn", "场景已切到冒险选关")

	print("RESULT=", "PASS" if fail_count == 0 else "FAIL(%d)" % fail_count)
	quit(0 if fail_count == 0 else 1)
