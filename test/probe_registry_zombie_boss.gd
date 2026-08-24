extends SceneTree

func _init() -> void:
	call_deferred("_test")

func _test() -> void:
	await process_frame
	var boss_scene: PackedScene = SceneRegistry.ZOMBIE_BOSS
	if boss_scene == null:
		printerr("[FAIL] SceneRegistry.ZOMBIE_BOSS is null")
		quit(1)
		return
	var inst = boss_scene.instantiate()
	if inst == null:
		printerr("[FAIL] instantiate failed")
		quit(1)
		return
	if not inst is ZombossBoss:
		printerr("[FAIL] not ZombossBoss: ", inst.get_class())
		quit(1)
		return
	print("[OK] SceneRegistry.ZOMBIE_BOSS -> ZombossBoss")
	quit(0)
