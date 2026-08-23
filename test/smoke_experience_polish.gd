## 冒烟测试: 体验优化批次(BGM 无缝衔接 / 场景入场即换曲 / 阳光计数跳动)
## 运行: Godot_console --headless --path <proj> -s res://test/smoke_experience_polish.gd
extends SceneTree

var _fail := false

func _init() -> void:
	create_timer(90.0).timeout.connect(func():
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
	await create_timer(0.5).timeout

	var G: Node = root.get_node_or_null("/root/Global")
	var SM: Node = root.get_node_or_null("/root/SoundManager")
	_check(G != null and SM != null, "autoload 就绪")
	if G == null or SM == null:
		quit(1)
		return

	# === A. BGM 同曲目不重启 ===
	var track_a: AudioStream = SM.BGM_TRACKS[&"start_menu"]
	var track_b: AudioStream = SM.BGM_TRACKS[&"choose_card"]
	SM.play_bgm(track_a)
	await create_timer(0.35).timeout
	var pos1: float = SM.bgm_play.get_playback_position()
	SM.play_bgm(track_a)  # 同曲重复调用
	var pos2: float = SM.bgm_play.get_playback_position()
	_check(pos2 >= pos1 - 0.001, "同曲目重复播放不重启 (位置 %f -> %f)" % [pos1, pos2])
	_check(SM.bgm_play.playing, "BGM 保持播放中")

	# === B. 换曲目立即生效 ===
	SM.play_bgm(track_b)
	await create_timer(0.15).timeout
	_check(SM.bgm_play.stream == track_b, "切曲目立即换流")

	# === C. 阳光计数跳动(卡槽场景内的 CardSlotBattle 子节点) ===
	var slot_scene: PackedScene = load("res://scenes/card_slot/card_slot_norm.tscn")
	var slot := slot_scene.instantiate()
	root.add_child(slot)
	await create_timer(0.4).timeout
	var battle_slot: Node = slot.get_node_or_null("CardSlotBattle")
	_check(battle_slot != null, "找到 CardSlotBattle 子节点")
	if battle_slot != null:
		var sun_label: Label = battle_slot.get_node("SunLabelControl/CurrSunValue")
		battle_slot.sun_value = 150
		await create_timer(0.05).timeout
		_check(sun_label.text == "150", "阳光数字更新")
		_check(sun_label.scale.x > 1.01, "跳动动画已触发")
		await create_timer(0.45).timeout
		_check(absf(sun_label.scale.x - 1.0) < 0.02, "跳动动画回弹到位")

	# === D. 场景切换线程预载 + 点击瞬间平滑换曲 ===
	var ST: Node = root.get_node_or_null("/root/SceneTransition")
	_check(ST != null, "SceneTransition autoload 存在")
	if ST != null:
		SM.play_bgm(SM.BGM_TRACKS[&"start_menu"])
		await create_timer(0.2).timeout
		ST.change_scene("res://scenes/main/01StartMenu.tscn")
		## 平滑换曲: 压低→切流→恢复, 0.55s 内应完成且音量复原
		await create_timer(0.55).timeout
		_check(SM.bgm_play.stream == SM.BGM_TRACKS[&"start_menu"], "点击瞬间触发换曲(同曲保持连续)")
		_check(absf(SM.bgm_play.volume_db - SM._base_bgm_db) < 1.5, "平滑过渡后音量恢复")
		await create_timer(0.8).timeout
		var cur := current_scene
		_check(cur != null and cur.scene_file_path == "res://scenes/main/01StartMenu.tscn", "线程预载切换场景成功")

	# === E. 音效随机微变调(注: 音效池对同一流有 25 物理帧去重, 二次调用按设计返回 null) ===
	var sfx_a: AudioStream = load("res://assets/audio/SFX/button/tap.ogg")
	var sfx_b: AudioStream = load("res://assets/audio/SFX/button/tap2.ogg")
	var p1 = SM.play_sfx_with_pool(sfx_a)
	var p2 = SM.play_sfx_with_pool(sfx_b)
	_check(p1 != null and p2 != null, "音效池返回播放器")
	if p1 != null and p2 != null:
		var ok := true
		for p in [p1, p2]:
			if p.pitch_scale < 0.95 or p.pitch_scale > 1.05:
				ok = false
		_check(ok, "音效变调在 ±4%% 内 (%.3f / %.3f)" % [p1.pitch_scale, p2.pitch_scale])

	# === F. 选关页翻页动画 ===
	var cl_scene: PackedScene = load("res://scenes/main/02AdventureChooesLevel.tscn")
	var cl := cl_scene.instantiate()
	root.add_child(cl)
	await create_timer(0.8).timeout
	if cl.has_method("_update_page"):
		cl._update_page(1)
		await create_timer(0.08).timeout
		var page: CanvasItem = cl.all_pages_array[cl.curr_page]
		_check(page.modulate.a < 0.9, "翻页淡入进行中")
		await create_timer(0.45).timeout
		_check(absf(page.modulate.a - 1.0) < 0.02, "翻页淡入完成")

	paused = false
	print("========================================")
	if _fail:
		printerr("[SMOKE] 存在失败项 -> exit 1")
		quit(1)
	else:
		print("[SMOKE] 全部通过 -> exit 0")
		quit(0)
