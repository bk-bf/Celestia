# SIDE TASKS

## Polish, Bugfixes & Questions

(Important)
- [x] fix the SleepingState.enter() and EatingState.enter() not being called properly, so rest counter is paused properly and incremented during sleep state
- [x] merge pawn-system and main
- [] implement all effects and conditions from the TraitDatabase traits
- [] add default, progressive mood buffs and debuffs (new home buff)
- [] fix pawns standing on top of each other
- [] add a multi-marker to the designation manager
- [] fix the hunger and sleep need check frequency 

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





Notes:

HUD (CanvasLayer)
│
├── Control (Full Rect)
│   │
│   ├── BottomMenuBar (MarginContainer - Bottom Wide anchor)
│   │   ├── MenuContainer (HBoxContainer)
│   │   │   ├── ColonyButton (Button)
│   │   │   ├── ProductionButton (Button)
│   │   │   ├── PlanningButton (Button)
│   │   │   ├── ResearchButton (Button)
│   │   │   └── WorldButton (Button)
│   │   │
│   │   └── TabContainer (HBoxContainer)
│   │       └── [Dynamically loaded tab buttons]
│   │
│   ├── ContentPanels (MarginContainer - Full Rect with bottom margin)
│   │   └── [Dynamically loaded panel scenes]
│   │
│   ├── LogWindow (MarginContainer - Right anchor)
│   │   ├── VBoxContainer
│   │   │   ├── LogHeader (HBoxContainer)
│   │   │   │   ├── LogTitle (Label)
│   │   │   │   └── CollapseButton (TextureButton)
│   │   │   │
│   │   │   ├── LogScrollContainer (ScrollContainer)
│   │   │   │   └── LogEntries (VBoxContainer)
│   │   │   │
│   │   │   └── LogFilter (OptionButton)
│   │
│   └── PawnInfoPanel (MarginContainer - Left anchor)
│       └── VBoxContainer
│           ├── PawnHeader (HBoxContainer)
│           │   ├── PawnPortrait (TextureRect)
│           │   ├── PawnName (Label)
│           │   └── CloseButton (TextureButton)
│           │
│           ├── TabContainer (TabContainer)
│           │   ├── StatsTab (VBoxContainer)
│           │   ├── NeedsTab (VBoxContainer)
│           │   ├── SkillsTab (VBoxContainer)
│           │   └── InventoryTab (VBoxContainer)
│           │
│           └── SkillBar (HBoxContainer)
│               └── [Skill buttons dynamically loaded]





ok well the visual elements of the BottomMenuBar, the PawnInfoPanel and the LogWindow are in place in the for of node, now i need to implement the logic, the first  aspect i suppose would be the PawnInfoPanel, so if i click on a pawn the PawnInfoPanel appears and displays stats, needs, abilities and inventory of the pawn (the skillbar will be implemented later), currently i have this node layout in place: 
...
└── PawnInfoPanel (MarginContainer - Left anchor)
│       └── VBoxContainer
│           ├── PawnHeader (HBoxContainer)
│           │   ├── PawnPortrait (TextureRect)
│           │   ├── PawnName (Label)
│           │   └── CloseButton (TextureButton)
│           │
│           ├── TabContainer (TabContainer)
│           │   ├── StatsTab (VBoxContainer)
│           │   ├── NeedsTab (VBoxContainer)
│           │   ├── SkillsTab (VBoxContainer)
│           │   └── InventoryTab (VBoxContainer)
│           │
│           └── SkillBar (HBoxContainer)
│               └── [Skill buttons dynamically loaded]

and i implemented the above HUD script and attached it to the HUD CanvasLayer, but no PawnInfoPanel appea 
