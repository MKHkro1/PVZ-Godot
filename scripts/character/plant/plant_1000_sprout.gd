extends Plant000Base
class_name Plant1000Sprout

## 花园植物发芽成长信号
signal signal_garden_sprout_grow

func ready_garden():
	super()
	garden_component.signal_sprout_grow.connect(func():signal_garden_sprout_grow.emit())
