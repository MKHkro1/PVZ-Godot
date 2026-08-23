extends SceneTree
## 探针: 复现主菜单"开始游戏"直入冒险关卡的完整调用链

func _init() -> void:
	create_timer(40.0).timeout.connect(func(): printerr("[FAIL] WATCHDOG 超时"); quit(3))
	_run()

func _run() -> void:
	await process_frame
	await process_frame
	var Global := root.get_node("/root/Global")
	Global.adventure_next_index = 0
	print("[PROBE] 调用 start_adventure_next_level ...")
	Global.start_adventure_next_level()
	# 等待 change_scene 异步完成
	for i in range(30):
		await create_timer(0.5).timeout
		var cs := current_scene
		if cs != null and cs.name != "StartMenu":
			print("[PROBE] 进入场景: ", cs.name, "  game_para=", Global.game_para.save_game_name if Global.game_para else "<null>")
			quit(0)
			return
	var cs2 := current_scene
	printerr("[FAIL] 未进入关卡场景, current=", cs2.name if cs2 else "<null>")
	quit(1)
