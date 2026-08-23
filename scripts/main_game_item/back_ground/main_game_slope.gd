extends Node2D
class_name MainGameSlope

var all_slopes:Array[Slope]
## 所有斜面的全局x范围


func _ready() -> void:
	for c in get_children():
		c = c as Slope
		all_slopes.append(c)

## 根据全局x获取相对y,一整行获取
func get_all_slope_y(global_x:float)->float:
	var y:float
	## 要保证斜面按从左到右的顺序
	for i in range(all_slopes.size()):
		var slope = all_slopes[i]
		var r = slope.slope_global_pos_x_range
		## 如果在斜面左边
		if global_x < r.x:
			y = slope.start_pos_slope.y
			break
		## 在斜面中
		elif global_x > r.x and global_x < r.y:
			y = slope.get_slope_y(global_x)
			break
		## 如果还有下一个斜面
		if i < all_slopes.size() - 1:
			## 检查是否在两个范围之间
			var next_r = all_slopes[i + 1].slope_global_pos_x_range
			if global_x > r.y and global_x < next_r.x:
				y = slope.end_pos_slope.y
				break
		else:
			y = slope.end_pos_slope.y
			break
	return y
