extends SceneTree

func _init() -> void:
	var scene: PackedScene = preload("res://scenes/character/zombie/Zombie_boss.tscn")
	if scene == null:
		printerr("[FAIL] Zombie_boss.tscn preload failed")
		quit(1)
		return
	print("[OK] Zombie_boss.tscn preload success (", scene.resource_path, ")")
	quit(0)
