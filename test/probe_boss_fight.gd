extends SceneTree
## Boss 战冒烟测试: 进入5-10 → 验证僵王生成/攻击调度/受击/死亡→奖杯

func _init() -> void:
	create_timer(90.0).timeout.connect(func(): printerr("[FAIL] WATCHDOG"); quit(3))
	_run()

var errors := 0

func _run() -> void:
	await process_frame
	var Global := root.get_node("/root/Global")
	Global.adventure_next_index = 49
	print("[BOSS] 进入 5-10 ...")
	Global.start_adventure_next_level()
	for i in range(20):
		await create_timer(0.5).timeout
		if current_scene != null and current_scene.name != "StartMenu":
			break
	var mgr = Global.main_game
	if mgr == null:
		printerr("[FAIL] 未进入战斗场景"); quit(1); return
	print("[BOSS] 场景: ", current_scene.name)
	var boss = mgr.zomboss_boss
	if boss == null:
		printerr("[FAIL] 僵王未生成"); errors += 1; quit(1); return
	print("[BOSS] 僵王已生成 pos=", boss.global_position, " hp=", boss.curr_hp)
	# 加速时间观察调度
	Engine.time_scale = 8.0
	# 等待若干轮动作(休息5s+动作) → 观察出怪
	var zombies_before: int = mgr.zombie_manager.curr_zombie_num
	await create_timer(14.0).timeout   # 真实1.75s*8=14游戏秒+
	var zombies_after: int = mgr.zombie_manager.curr_zombie_num
	print("[BOSS] 出怪数 ", zombies_before, "→", zombies_after)
	if zombies_after <= zombies_before:
		printerr("[FAIL] 投放攻击未生效"); errors += 1
	# 受击到阶段2
	boss.be_attacked_bullet(21000)
	if boss.stage != 2:
		printerr("[FAIL] 80%/50%阶段未切换 stage=", boss.stage); errors += 1
	else:
		print("[BOSS] 阶段切换 OK stage=", boss.stage)
	# 击杀 → 死亡动画 → create_trophy
	var trophy_fired := [false]
	root.get_node("/root/EventBus").subscribe("create_trophy", func(p): trophy_fired[0] = true, 99, true)
	boss.be_attacked_bullet(99999)
	if not boss.is_dead:
		printerr("[FAIL] 击杀后 is_dead=false"); errors += 1
	Engine.time_scale = 12.0
	await create_timer(10.0).timeout   # 死亡8.83s/1.5倍速≈5.9s游戏内
	if not trophy_fired[0]:
		printerr("[FAIL] create_trophy 未触发"); errors += 1
	else:
		print("[BOSS] 死亡→奖杯链路 OK")
	Engine.time_scale = 1.0
	quit(errors)
