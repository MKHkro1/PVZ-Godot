## 冒烟测试: 相机震动反馈(爆炸手感)
## 运行: Godot_console --headless --path <proj> -s res://test/smoke_camera_shake.gd
extends SceneTree

var _fail := false

func _init() -> void:
	create_timer(60.0).timeout.connect(func():
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

func _run() -> void:
	await process_frame
	await create_timer(0.4).timeout

	var cam_script: Script = load("res://scripts/camera/main_game_camera.gd")
	var cam := Camera2D.new()
	cam.set_script(cam_script)
	root.add_child(cam)
	await create_timer(0.05).timeout
	cam.shake(8.0, 0.35)
	await create_timer(0.08).timeout
	_check(cam.offset.length() > 0.5, "震动中相机偏移非零 (%.2f)" % cam.offset.length())
	await create_timer(0.55).timeout
	_check(cam.offset == Vector2.ZERO, "震动结束偏移归零")
	_check(cam.is_processing() == false, "震动结束停止处理")
	cam.queue_free()

	print("========================================")
	if _fail:
		printerr("[SMOKE] 存在失败项 -> exit 1")
		quit(1)
	else:
		print("[SMOKE] 全部通过 -> exit 0")
		quit(0)
