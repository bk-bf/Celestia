# SIDE TASKS

## Polish, Bugfixes & Questions

(Important)
- [x] fix the SleepingState.enter() and EatingState.enter() not being called properly, so rest counter is paused properly and incremented during sleep state
- [] implement all effects and conditions from the TraitDatabase traits


- [ ] add meal system improvemnts:
	- [ ] 	Implement meal deterioration tracking (percentage consumed)
	- [ ]  	Add quality levels to meals that affect the chance of eating past "well-fed"
	- [ ] 	Create meaningful benefits for the "stuffed" status
	- [ ] 	Implement the weight gain system as a consequence of frequent overeating
	- [ ] 	Add traits that affect eating behavior (some pawns might naturally stop at "satisfied" while others might always eat to "stuffed")

(Optional)
- [x] what to do with current get_carrying_capacity()
- [x] we set max_carry_weight = 50 but then reset it to 30 * 5 in _ready(), so why specifically 50?
- [x] should we implement a state machine now?
- [x] 2 harvest_resource() in pawn.gd and map_data.gd, currently resource is being updated by harvest_state.gd but moving it to map_data might be better
- [x] add state tracker in debug log, similar to current job tracker
- [x] implement autogen debug naming for pawns, eg. Pawn1, Pawn2 etc.
- [x] apply random coloring to pawn sprites (to differentiate between them)
- [ ] implement quick progress bar for harvesting (maybe)
- [ ] Initial Database Population (Phase 1) has to possibly be refactored again to ensure -> @onready var map_data = DatabaseManager.map_data
- [ ] fix func _on_tile_resource_changed()
- [ ] implemenet some vegetation culling mechanism to reduce tree/bush density
- [ ] ensure the camera doenst move if Shift + W,A,S,D is pressed





