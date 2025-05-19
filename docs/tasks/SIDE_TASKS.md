# SIDE TASKS

## Polish, Bugfixes & Questions

## Important & Urgent

- [ ] Implement all effects and conditions from the TraitDatabase traits
- [ ] Fix pawns standing on top of each other
- [ ] Fix the hunger and sleep need check frequency
- [ ] Update EatingState, SleepingState, etc. to emit update signal for HUD
- [ ] Add default, progressive mood buffs and debuffs (new home buff)

## Important & Not Urgent

- [ ] Add a multi-marker to the designation manager
- [ ] Meal system improvements:
  - [ ] Implement meal deterioration tracking (percentage consumed)
  - [ ] Add quality levels to meals that affect the chance of eating past "well-fed"
  - [ ] Create meaningful benefits for the "stuffed" status
  - [ ] Implement the weight gain system as a consequence of frequent overeating
  - [ ] Add traits that affect eating behavior

## Not Important & Urgent

- [ ] Initial Database Population (Phase 1) refactoring to ensure proper handling of `@onready var map_data = DatabaseManager.map_data`
- [ ] Fix func `_on_tile_resource_changed()`
- [ ] Ensure the camera doesn't move if Shift + W,A,S,D is pressed

## Not Important & Not Urgent

- [ ] Implement quick progress bar for harvesting
- [ ] Implement some vegetation culling mechanism to reduce tree/bush density
- [ ] Change pawns standing frozen during Idle to wandering around


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
