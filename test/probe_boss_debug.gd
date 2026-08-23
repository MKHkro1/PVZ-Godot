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
	await create_timer(5.0).timeout
	var mgr = Global.main_game
	var boss = mgr.zomboss_boss
	print("[DBG] boss=", boss, " inside_tree=", boss.is_inside_tree(), " gpos=", boss.global_position)
	print("[DBG] visible=", boss.visible, " z=", boss.z_index, " modulate=", boss.modulate)
	var ap: AnimationPlayer = boss.get_node("AnimationPlayer")
	print("[DBG] anim当前=", ap.current_animation, " playing=", ap.is_playing(), " pos_in_anim=", ap.current_animation_position)
	print("[DBG] 有idle=", ap.has_animation("Zombie_boss_idle"), " 进度库列表=", ap.get_animation_list().slice(0, 3))
	for part_name in ["Boss_body1", "Boss_head", "Boss_RV", "Boss_outerarm_hand"]:
		var n = boss.get_node_or_null(part_name)
		if n is Sprite2D:
			var s: Sprite2D = n
			print("[DBG] ", part_name, " visible=", s.visible, " tex=", s.texture != null, " gpos=", s.global_position, " scale=", s.scale)
		else:
			print("[DBG] ", part_name, " 缺失")
	# 相机
	var cam := current_scene.get_viewport().get_camera_2d()
	if cam != null:
		print("[DBG] camera center=", cam.get_screen_center_position(), " zoom=", cam.zoom)
	quit(0)
