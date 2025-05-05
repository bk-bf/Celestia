# SIDE TASKS

## Polish, Bugfixes & Questions

**Pawn Creation & Attributes**

*Simple resource harvesting mechanics:*
(For Completion)
- [x] ensure 1 harvest removes the specified resource to harvest from the harvested map tile
- [x] remove resource drawing after it has been harvested
- [x] add debug log how much resources where harvested and which pawn got it added to its inventory

(Optional)
- [x] what to do with current get_carrying_capacity()
- [x] we set max_carry_weight = 50 but then reset it to 30 * 5 in _ready(), so why specifically 50?
- [x] should we implement a state machine now?
- [x] 2 harvest_resource() in pawn.gd and map_data.gd, currently resource is being updated by harvest_state.gd but moving it to map_data might be better
- [ ] add state tracker in debug log, similar to current job tracker
- [ ] implement autogen debug naming for pawns, eg. Pawn1, Pawn2 etc.
- [ ] apply random coloring to pawn sprites (to differentiate between them)
- [ ] implement quick progress bar for harvesting (maybe)




