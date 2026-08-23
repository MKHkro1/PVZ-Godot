extends Node2D
class_name Slope
## 一个斜面(屋顶)
"""
斜面有两种:
	斜面检测区域:用于检测僵尸是否在斜面中
	斜面真实区域:每行都有一个斜面,被子弹检测,子弹影子,僵尸移动时body的偏移

	两类区域的斜面范围要一致,左右临界点相同
"""

## 斜面检测区域,用于检测僵尸是否在斜面中
@onready var area_2d_slope_detection: Area2D = $Area2DSlopeDetection
## 第一个斜面coll,用于计算夹角单位方向和法向量
@onready var collision_shape_2d: CollisionShape2D = $SlopeReal/Area2DReal/CollisionShape2D
## 真实斜面节点,用于获取所有的斜面区域
@onready var slope_real: Node2D = $SlopeReal
## 所有斜面的区域
var all_slope_area_real:Array[Area2D] = []

## 斜面的起始和结束位置(相对位置)
var start_pos_slope :Vector2
var end_pos_slope :Vector2

## 斜面的开始和结束全局x范围
var slope_global_pos_x_range:Vector2

## 与地面的夹角方向
var dir_ground : Vector2
## 斜面法向量,地面上方向
var normal_vector_slope :Vector2


func _ready() -> void:
	## 斜面形状
	var slope_shape:SegmentShape2D = collision_shape_2d.shape
	dir_ground = get_unit_direction(slope_shape.a, slope_shape.b)
	start_pos_slope = slope_shape.a
	end_pos_slope = slope_shape.b
	slope_global_pos_x_range = Vector2(start_pos_slope.x + global_position.x, end_pos_slope.x + global_position.x)

	print("屋顶斜面单位方向为:", dir_ground)
	## 逆时针旋转90度
	normal_vector_slope = Vector2(dir_ground.y, -dir_ground.x)
	print("屋顶斜面法向量方向(地面上方向)为:", normal_vector_slope)

	area_2d_slope_detection.area_entered.connect(_on_area_2d_area_entered)
	area_2d_slope_detection.area_exited.connect(_on_area_2d_area_exited)

	for area_node:Area2D in slope_real.get_children():
		all_slope_area_real.append(area_node)

## 计算线段的单位方向向量
func get_unit_direction(p1: Vector2, p2: Vector2) -> Vector2:
	var direction = p2 - p1  # 计算线段的方向向量
	var length = direction.length()  # 计算向量的模长（长度）
	if length != 0:
		return direction.normalized()  # 返回单位向量（方向相同，但长度为1）
	else:
		return Vector2.ZERO  # 如果线段的两个端点重合，返回零向量

## 僵尸\小推车进入
func _on_area_2d_area_entered(area: Area2D) -> void:
	var area_owner = area.owner
	## 如果检测到僵尸
	if area_owner is Zombie000Base:
		#print("检测到僵尸")
		area_owner.update_move_dir_y_correct(dir_ground)
	elif area_owner is RoofCleaner:
		area_owner.update_move_dir_y_correct(dir_ground)
		print("检测到屋顶小推车", dir_ground)

## 僵尸\小推车离开
func _on_area_2d_area_exited(area: Area2D) -> void:
	var area_owner = area.owner
	## 如果检测到僵尸
	if area_owner is Zombie000Base:
		area_owner.update_move_dir_y_correct(Vector2.ZERO)
	elif area_owner is RoofCleaner:
		area_owner.update_move_dir_y_correct(Vector2.ZERO)

## 根据x位置获取对应的斜面的y相对位置
func get_slope_y(x:float):
	var t = (x - slope_global_pos_x_range.x) / (slope_global_pos_x_range.y - slope_global_pos_x_range.x)  # 计算相对位置
	## 基于斜坡起始和结束点计算中间位置的y值
	var slope_y = start_pos_slope.y + (end_pos_slope.y - start_pos_slope.y) * t

	return slope_y

