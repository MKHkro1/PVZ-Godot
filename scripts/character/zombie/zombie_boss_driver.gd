extends Node2D
class_name ZombossBossDriver
## 驾驶室僵王博士本体(静态层, 参考 HE Driver 偏移)

const PARTS: Array[Dictionary] = [
	{"name": "Driver_body", "tex": "Zombie_bossdriver_body.png", "pos": Vector2(35.2, 44.8)},
	{"name": "Driver_face", "tex": "Zombie_bossdriver_face.png", "pos": Vector2(9.7, 44.1)},
	{"name": "Driver_jaw", "tex": "Zombie_bossdriver_jaw.png", "pos": Vector2(24.7, 55.4)},
	{"name": "Driver_innerarm_upper", "tex": "Zombie_bossdriver_upperarm.png", "pos": Vector2(39.9, 58.7)},
	{"name": "Driver_innerarm_lower2", "tex": "Zombie_bossdriver_lowerarm2.png", "pos": Vector2(52.0, 62.0)},
	{"name": "Driver_innerarm_hand", "tex": "Zombie_bossdriver_innerhand.png", "pos": Vector2(58.0, 68.0)},
	{"name": "Driver_outerarm_upper", "tex": "Zombie_bossdriver_upperarm.png", "pos": Vector2(47.5, 58.0)},
	{"name": "Driver_outerarm_lower2", "tex": "Zombie_bossdriver_lowerarm2.png", "pos": Vector2(60.0, 61.0)},
	{"name": "Driver_outerarm_hand", "tex": "Zombie_bossdriver_outerhand.png", "pos": Vector2(66.0, 67.0)},
]

## 相对 ZombieBoss 原点(对齐 HE Driver 节点)
const DRIVER_PIVOT := Vector2(-182.0, -148.0)


func _ready() -> void:
	position = DRIVER_PIVOT
	rotation = -0.0045
	for p in PARTS:
		var s := Sprite2D.new()
		s.name = p["name"]
		s.centered = false
		s.position = p["pos"]
		s.texture = load("res://assets/reanim/%s" % p["tex"]) as Texture2D
		add_child(s)
