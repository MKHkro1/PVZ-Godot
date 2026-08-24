extends SceneTree
## Boss 可见性调试

func _init() -> void:
	create_timer(60.0).timeout.connect(func(): quit(3))
	_run()

func _run() -> void:
	await process_frame
	var Global := root.get_node("/root/Global")
	Global.adventure_next_index = 49
	Global.start_adventure_next_level()
	for i in range(20):
		await create_timer(0.5).timeout
		if current_scene != null and current_scene.name != "StartMenu":
			break
	await create_timer(6.0).timeout
	var mgr = Global.main_game
	var boss: ZombossBoss = mgr.zomboss_boss
	if boss == null:
		printerr("[FAIL] 僵王未生成")
		quit(1)
		return
	print("[DBG] boss gpos=", boss.global_position)
	print("[DBG] visible=", boss.visible, " z=", boss.z_index)
	var ap := boss.get_node_or_null("Anim_Zombie_boss_idle") as AnimationPlayer
	if ap != null:
		print("[DBG] idle anim=", ap.current_animation, " playing=", ap.is_playing())
	for part_name in ["Boss_body2", "Boss_innerleg_foot", "Boss_head", "Boss_body1"]:
		var n = boss.get_node_or_null(part_name)
		if n is Sprite2D:
			var s: Sprite2D = n
			print("[DBG] ", part_name, " vis=", s.visible, " tex=", s.texture != null, " gpos=", s.global_position)
	var cam := current_scene.get_viewport().get_camera_2d()
	if cam != null:
		var vp := current_scene.get_viewport().get_visible_rect()
		print("[DBG] camera=", cam.global_position, " viewport=", vp)
	# 机体应在屏幕内 (约 500~900)
	var body := boss.get_node_or_null("Boss_body2") as Sprite2D
	if body != null and body.visible and body.texture != null:
		var gx := body.global_position.x
		if gx >= 400.0 and gx <= 950.0:
			print("[OK] Boss_body2 在屏幕范围内 gx=", gx)
		else:
			printerr("[FAIL] Boss_body2 超出屏幕 gx=", gx)
			quit(1)
			return
	else:
		printerr("[FAIL] Boss_body2 不可见或无贴图")
		quit(1)
		return
	quit(0)
