extends Zombie000Base
class_name Zombie016Jackbox

@onready var bomb_component_jackbox: BombComponentJackbox = $BombComponentJackbox

@export_group("动画状态")
@export var is_pop:=false

func ready_norm():
	super()
	## 罐子僵尸，直接爆炸
	if is_pot_zombie:
		_strigger_bomb()

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	bomb_component_jackbox.signal_trigger_bomb.connect(_strigger_bomb)
	hp_component.signal_hp_component_death.connect(bomb_component_jackbox.disable_component.bind(ComponentNormBase.E_IsEnableFactor.Death))

	signal_update_speed.connect(bomb_component_jackbox.owner_update_speed)


## 触发爆炸
func _strigger_bomb():
	is_pop = true
	SoundManager.play_character_SFX(&"boing")
	_stop_sfx_enter()

## 失去铁器道具
func loss_iron_item():
	super()
	bomb_component_jackbox.disable_component(ComponentNormBase.E_IsEnableFactor.Lose)
	_stop_sfx_enter()

func sfx_jack_suprise():
	SoundManager.play_character_SFX(&"jack_suprise")
