extends SceneTree
## 窗口化实测: 场景切换时"换曲调用"到"BGM 真正出声"的延迟
## 运行(必须带窗口, 走真实音频设备):
##   DSH_DEBUG_SCENE=1 Godot_console --path <proj> -s res://test/measure_scene_audio.gd

var _last_pos := -1.0
var _t0 := 0

func _initialize() -> void:
	create_timer(60.0).timeout.connect(func():
		printerr("WATCHDOG TIMEOUT")
		quit(3)
	)
	_run()

func _log(msg: String) -> void:
	print("[MEASURE +%5d ms] %s" % [Time.get_ticks_msec() - _t0, msg])

func _run() -> void:
	await process_frame
	await create_timer(0.8).timeout
	var SM: Node = root.get_node("/root/SoundManager")
	var ST: Node = root.get_node("/root/SceneTransition")

	# 先播主菜单曲, 模拟从主界面发起切换
	SM.play_bgm(SM.BGM_TRACKS[&"start_menu"])
	await create_timer(0.6).timeout

	_t0 = Time.get_ticks_msec()
	_log("发起 change_scene -> 02AdventureChooesLevel")
	ST.change_scene("res://scenes/main/02AdventureChooesLevel.tscn")

	var new_stream: AudioStream = SM.BGM_TRACKS[&"choose_card"]
	var heard_new := false
	for i in range(900):
		await process_frame
		var p: float = SM.bgm_play.get_playback_position()
		var s: AudioStream = SM.bgm_play.stream
		if s == new_stream:
			if p > 0.05:
				_log("新曲真正出声! pos=%.3f" % p)
				heard_new = true
				break
			elif p != _last_pos:
				_log("已切新流但 pos 尚未推进 (%.4f)" % p)
				_last_pos = p
		else:
			if p != _last_pos:
				_log("旧曲仍推进 pos=%.3f" % p)
				_last_pos = p
	if not heard_new:
		_log("!! 900 帧内新曲未出声")

	await create_timer(1.0).timeout
	_log("结束, 当前场景=" + (current_scene.scene_file_path if current_scene else "null"))
	quit(0)
