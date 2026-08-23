extends Zombie000Base
class_name Zombie021Bungi

## 偷盗的植物的容器节点
@onready var bungi_container: Node2D = $Body/BodyCorrect/BungiContainer

@onready var body_correct: Node2D = $Body/BodyCorrect
## 绳子节点修改父节点,起飞时使用不同的body
@onready var bungee_cords: Node2D = $Body/BodyCorrect/Zombie_bungi_body/BungeeCords
@onready var zombie_bungi_body_2: Sprite2D = $Body/BodyCorrect/Zombie_bungi_body2
## 靶子,偷盗植物时隐藏
@onready var bungee_target: Sprite2D = $BungeeTarget

@export_group("动画状态")
@export var is_drop_end := false
@export var is_grab := false
## 被保护伞摊开
@export var is_umbrella_raise := false
## 蹦极僵尸所在PlantCell
var plant_cell:PlantCell

func ready_norm():
	super()
	## 如果没有plant_cell,报错
	if not is_instance_valid(plant_cell):
		printerr("当前蹦极僵尸没有plant_cell")
	## 蹦极僵尸初始化时先禁用受击组件
	hurt_box_component.disable_component(ComponentNormBase.E_IsEnableFactor.Character)

	bungee_target.position.y -= 600
	var tween_bungee_target = create_tween()
	tween_bungee_target.tween_property(bungee_target, "position:y", bungee_target.position.y+600, 0.5)

	body_correct.position.y -= 600
	await get_tree().create_timer(2, false).timeout
	var tween = create_tween()
	tween.set_parallel()
	# 在动画进行到 2.5 秒时调用函数
	tween.tween_callback(func():is_drop_end = true).set_delay(1.8)
	tween.tween_callback(hurt_box_component.enable_component.bind(ComponentNormBase.E_IsEnableFactor.Character)).set_delay(1.3)
	tween.tween_property(body_correct, "position:y", body_correct.position.y+600, 2).set_trans(Tween.TRANS_BACK)
	#.set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	is_grab = true
	body.z_index -= 50

func ready_show():
	super()
	bungee_target.visible = false
	shadow.visible = false

## 偷盗植物,开始起飞
func raise_start():
	## 如果没有被摊开,偷盗植物
	if not is_umbrella_raise:
		bungi_plant_cell(plant_cell)
	bungee_target.visible = false
	## 禁用受击组件
	hurt_box_component.disable_component(ComponentNormBase.E_IsEnableFactor.Character)
	var tween = create_tween()
	tween.tween_property(body_correct, "position:y", body_correct.position.y-600, 1.0)
	tween.set_parallel()
	tween.tween_property(shadow, ^"scale", Vector2.ZERO, 0.5)

	await tween.finished
	character_death_disappear()

## 偷盗植物
func bungi_plant_cell(p_c:PlantCell):
	if is_instance_valid(p_c):
		var plant_body_copy :Node2D= p_c.be_bungi()
		if plant_body_copy != null:
			#GlobalUtils.child_node_change_parent(plant_body_copy, bungi_container)
			plant_body_copy.reparent(bungi_container)

## 修改绳子父节点
func update_bungee_cords_parent():
	#GlobalUtils.child_node_change_parent(bungee_cords, zombie_bungi_body_2)
	bungee_cords.reparent(zombie_bungi_body_2)


## 角色死亡
func character_death():
	super()
	queue_free()

## 被保护伞摊开
func be_umbrella_leaf():
	is_umbrella_raise = true
