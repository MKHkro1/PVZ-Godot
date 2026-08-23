extends SceneTree
## 探针: 测量白天背景纹理与植物格子几何, 用于 1-1/1-2 草坪裁剪

func _init() -> void:
	create_timer(20.0).timeout.connect(func(): quit(0))
	_run()

func _run() -> void:
	await process_frame
	var tex: Texture2D = load("res://assets/image/background/background1.jpg")
	print("[BG] background1.jpg 尺寸: ", tex.get_width(), " x ", tex.get_height())
	# 载入战斗场景(不进主流程, 仅取格子布局)
	var scene: PackedScene = load("res://scenes/main/MainGame01Front.tscn")
	var inst := scene.instantiate()
	root.add_child(inst)
	await process_frame
	await process_frame
	var pcm := inst.get_node_or_null("Manager/PlantCellManager")
	if pcm == null:
		# 尝试唯一名/其他路径
		pcm = inst.find_child("PlantCellManager", true, false)
	print("[BG] PlantCellManager=", pcm)
	if pcm != null:
		var cells: Array = pcm.all_plant_cells
		print("[BG] 行数=", cells.size())
		for r in range(mini(cells.size(), 5)):
			if cells[r].size() > 0:
				var c = cells[r][cells[r].size() - 1] if r < cells.size() else null
				var first = cells[r][0]
				print("[BG] 行", r, " 首格全局y=", int(first.global_position.y), " x=", int(first.global_position.x))
	# 背景节点位置与缩放
	var bgroot := inst.find_child("Background", true, false)
	if bgroot is Sprite2D:
		var s: Sprite2D = bgroot
		print("[BG] Background sprite pos=", s.global_position, " scale=", s.scale, " centered=", s.centered, " tex=", s.texture.resource_path.get_file())
	inst.queue_free()
	quit(0)
