extends Plant000Base
class_name Plant026Plantern

func ready_norm():
	super()
	var all_plant_cells_surrounding:Array[PlantCell] = plant_cell.get_plant_cell_surrounding()
	for curr_plant_cell:PlantCell in all_plant_cells_surrounding:
		if is_instance_valid(curr_plant_cell.pot):
			curr_plant_cell.pot.add_plant_can_look_pot(self)
