extends PlantCellGarden
class_name PlantCellGardenAquarium

@onready var plantshadow: Sprite2D = $Plantshadow

## 激活独轮车时
func wheel_barrow_activate():
	plantshadow.visible = true

## 不激活独轮车时
func wheel_barrow_deactivate():
	plantshadow.visible = false
