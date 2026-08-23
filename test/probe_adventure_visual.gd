extends SceneTree
## 视觉验证: 直入指定冒险关卡并停留数秒(配合截图)
## 命令行: --path . -s res://test/probe_adventure_visual.gd -- idx=1

func _init() -> void:
	create_timer(60.0).timeout.connect(func(): printerr("WATCHDOG"); quit(3))
	_run()

func _run() -> void:
	await process_frame
	var Global := root.get_node("/root/Global")
	var idx := 0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("idx="):
			idx = int(arg.trim_prefix("idx="))
	Global.adventure_next_index = idx
	print("[VIS] 进入序号 ", idx)
	Global.start_adventure_next_level()
	# 等待入场演出结束, 稳定后由外部截图
	for i in range(8):
		await create_timer(1.0).timeout
	# 自截图(窗口被遮挡也能截到渲染结果)
	var out_path := "user://visual_idx%d.png" % idx
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("out="):
			out_path = arg.trim_prefix("out=")
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(out_path)
	print("[VIS] 已保存截图: ", out_path)
	await create_timer(0.5).timeout
	quit(0)
