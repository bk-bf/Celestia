# ROADMAP

# ERP

## Phase 1: Complete Foundation \& Basic Visualization (1-2 weeks)

- **Finish Core Structure**
    - [x] MapData, Tile, and Grid classes
    - [x] Complete coordinate system setup
    - [x] Implement basic FastNoiseLite integration with your existing classes
- **Simple Visualization Layer**
    - [x] Create a basic converter from your MapData to TileMapLayers
    - [x] Implement 5 basic terrain types


## Phase 2: Essential Generation Systems (2 weeks)

- **Streamlined Terrain Generation**
    - [x] Basic density generation using FastNoiseLite (simplify from 4 algorithms to 1)
    - [x] Simple water system (lakes and rivers without complex flow simulation)
    - [x] Basic biome assignment (forest, plains, mountains, swamp)
- **Core Gameplay Elements**
    - [x] Implement pathfinding using your Tile.walkable property
    - [x] Basic monster territory system using your existing territory_owner property
    - [x] Add resource generation focusing on 2-3 main resources


## Phase 3A: Core Pawn \& Territory Systems (2-3 weeks)

- **Pawn Creation \& Attributes**
    - [x] Implement basic pawn class with core attributes
    - [x] Implement pawn movement with terrain movement multipliers
    - [x] Simple resource harvesting mechanics
    - [x] Create a simple trait system for pawn personality
    - [x] Add basic pawn color differentiation
    - [x] Implement basic randomised pawn naming system
- **TileMap Integration (Technical Improvement)**
    - [x] Replace current `draw()` implementation with TileMap-based rendering
    - [x] Create basic placeholder sprites for terrain types
    - [x] Implement proper z-indexing for entities and terrain
    - [x] Add basic, TileMap-based resource visualization
- **Database Foundation**
    - [x] Create comprehensive DatabaseManager to handle all database types
    - [x] Initial Database Population (Phase 1)
        - [x] Populate TerrainDatabase with 5 main terrain types
        - [x] Expand TerrainDatabase with 15+ subtypes
        - [x] Populate TerritoryDatabase with 4 territory types


## Phase 3B: Survival \& Colony Management (2-3 weeks)

- **Pawn Needs \& Work Systems**
    - [x] Implement hunger and rest needs
    - [x] Add mood tracking
    - [ ] Create job assignment interface
    - [ ] Implement work priorities system
    - [ ] Add basic pawn AI for autonomously selecting tasks
- **Item System Foundation**
    - [ ] Implement ItemDatabase with categorized item definitions
    - [ ] Create ItemManager for spawning and tracking items
    - [ ] Develop item property system (weight, quality, magical effects)
    - [ ] Implement basic item transformation framework
    - [ ] Connect item system with existing inventory functionality
- **Resource Management \& Construction**
    - [ ] Implement stockpile zones with territory safety ratings
    - [ ] Create inventory and equipment systems for pawns, implement all the different item effects
    - [ ] Implement core building mechanics

# Revised UI Development Roadmap for Celestia

## Phase 3C: Essential UI - Dynamic Contextual Interface Foundation (2-3 weeks)

**Navigation and Menu Framework**
- [ ] Implement dynamic bottom bar system that adapts based on selection state
- [ ] Create expandable menu system with minimalist default state
- [ ] Implement pawn selection UI transformation (expand interface when pawn selected)
- [ ] Design consistent UI hierarchy for collapsed/expanded states

**Game Information Displays**
- [ ] Implement transparent log window on right side of screen for immersive event narration
- [ ] Create collapsible pawn information panels for selected pawns (needs, mood, traits, stats)
- [ ] Design inventory visualization system with contextual actions
- [ ] Add job status indicators that appear during active tasks

**Basic Interaction Systems**
- [ ] Design work priorities interface that appears when relevant
- [ ] Implement context-sensitive action buttons based on selection state
- [ ] Create resource designation controls with visual feedback
- [ ] Develop skill hotbar system for combat abilities

**Status and Feedback Elements**
- [ ] Develop subtle event communication through environmental changes and log entries
- [ ] Implement tooltip system for game objects with contextual information
- [ ] Add context-sensitive cursor system that changes based on action type
- [ ] Create unobtrusive visual/audio indicators for new log entries


## Phase 4: Exploration \& Vision Systems (2-3 weeks)

- **Pawn Vision \& Exploration System**
    - [ ] Implement pawn vision range system
    - [ ] Create fog of war mechanics based on pawn visibility
    - [ ] Implement vision radius affected by terrain and time of day
    - [ ] Add vision sharing between colony pawns
- **Monster AI \& Spawning**
    - [ ] Implement monster spawning based on territory type
    - [ ] Develop animal and monster AI behaviors
    - [ ] Implement territory-based aggression for monsters
- **Expanded Database Implementation**
    - [ ] Extend ItemDatabase with more item types
    - [ ] Create EntityDatabase structure for monsters and animals
    - [ ] Enhance TerritoryDatabase with unique behaviors and difficulty gradients
    - [ ] Expand ResourceDatabase with territory-specific resources


## Phase 5: Core Differentiation Systems (3-4 weeks)

- **Basic Magic Framework**
    - [ ] Implement environmental affinity mechanics for different magic types
    - [ ] Create MagicDatabase with 4 elemental types
    - [ ] Add simple environmental interactions (water + fire = steam)
- **Combat \& Monster Interaction**
    - [ ] Implement basic combat system with weapon types
    - [ ] Create SkillDatabase with combat progression tracking
    - [ ] Add basic critical strikes and special attacks
- **Multi-Stage Crafting System**
    - [ ] Create ItemDatabase with crafting requirements
	- [ ] Add sprite-based visualization for ItemDatabase entries
    - [ ] Implement multi-step crafting for key resource chains
    - [ ] Design specialized workstations for different crafting types
- **Enhanced Monster Territory System**
    - [x] Basic monster territory system using territory_owner property
    - [ ] Expand territory system with difficulty gradients from map-center to periphery
    - [ ] Add visual boundary indicators (claw marks, monster signs)
    - [ ] Create territory-specific resource generation (rare materials)


## Phase 6: Environmental Systems & Social Layer (2-3 weeks)

- **Dynamic Environment**
    - [ ] Implement day/night cycle with territory behavior changes
    - [ ] Create weather system with magical anomalies
    - [ ] Add seasonal changes affecting territory expansion/contraction
    - [ ] Design environmental events triggered by territory conflicts
- **Basic Social Layer**
    - [ ] Implement relationship tracking between pawns
    - [ ] Create social interactions affected by territory experiences
    - [ ] Add mood effects from relationships and territory stress
    - [ ] Design social roles based on territory interaction aptitude
- **Additional Database Population**
    - [ ] Expand EntityDatabase with 8+ monster types with unique behaviors
    - [ ] Add 10-15 crafting recipes with magical components
    - [ ] Create EventDatabase with territory-triggered events
    - [ ] Implement DiseaseDatabase with territory-specific afflictions


## Phase 7: Art and Sound Integration (2-3 weeks)

- **Visual Asset Implementation**
    - [ ] Set up Stable Diffusion 3 pipeline with custom LORA for fantasy style
    - [ ] Generate monster sprites with territory-specific variations
    - [ ] Create terrain textures with magical influence indicators
    - [ ] Design visual effects for territory boundaries and magic interactions
- **Sound Design**
    - [ ] Create ambient territory-specific soundscapes
    - [ ] Generate monster sounds based on territory type
    - [ ] Implement magical effect audio
    - [ ] Design environmental audio cues for territory dangers
          

## Phase 8: UI/UX Polish - Fantasy Theme Integration (2-3 weeks)

**Visual Theme Enhancement**
- [ ] Implement gothic-inspired visual styling for all UI components
- [ ] Create fantasy-themed border elements and panel designs
- [ ] Develop consistent color palette for different interaction categories
- [ ] Add subtle animations for UI transitions between selection states

**Advanced Information Displays**
- [ ] Enhance territory map with visual cues for danger levels
- [ ] Design monster encyclopedia that integrates with territory information
- [ ] Implement skill tree visualization for pawn development
- [ ] Create magical effect visualization system for spells and environmental interactions

**Immersive Feedback Systems**
- [ ] Design environmental visual effects that communicate territory dangers
- [ ] Implement skill-specific visual feedback during combat
- [ ] Create dynamic sound design system for UI interactions
- [ ] Develop subtle notification animations for the log window

**Player Experience Refinement**
- [ ] Implement custom UI scaling options for accessibility
- [ ] Create configuration panel for UI element visibility
- [ ] Design comprehensive help system with context-sensitive tooltips
- [ ] Add save/load interface with territory discovery visualization


# Post-ERP ROADMAP

## Phase 1: Magic \& Combat Systems (3-4 weeks)

- **Database Population - Phase 3**
    - [ ] Expand EntityDatabase with 10+ advanced monster types
    - [ ] Create SkillDatabase with 8-10 combat skills
    - [ ] Populate MagicDatabase with 4 elemental magic types and 5-8 spells each
    - [ ] Expand EventDatabase with 15-20 combat and magic-related events

- **Elemental Magic System**
    - [ ] Implement environmental affinity mechanics for different magic types
    - [ ] Create magic skill progression and spell learning
    - [ ] Add elemental interactions (water + fire = steam)
    - [ ] Implement visual effects for spells and environmental interactions
    - [ ] Create MagicDatabase with spell effects and progression

- **Combat Skills Framework**
    - [ ] Design skill trees for different weapon specializations
    - [ ] Implement combat skill progression through practical use
    - [ ] Add critical strikes and special attacks based on skill level
    - [ ] Create tactical positioning advantages system
	- [ ] Design territory discovery mechanics and rewards

- **Monster Territory Expansion**
    - [ ] Enhance monster territory system with difficulty gradients
    - [ ] Add visual boundary indicators (claw marks, etc.)
    - [ ] Implement boss monsters at territory centers
    - [ ] Create special resource drops from different monster types
	- [ ] Create territory-specific resource generation (rare materials)


## Phase 2: Advanced Pawn \& Colony Systems (3-4 weeks)

- **Database Population - Phase 4**
    - [ ] Expand EntityDatabase with 5-8 mount types
    - [ ] Populate PerkDatabase with 15-20 special abilities
    - [ ] Create 10-15 multi-step crafting chains in ItemDatabase
    - [ ] Add 8-10 social interaction types to EventDatabase

- **Rideable Animals**
    - [ ] Implement mount mechanics for faster movement
    - [ ] Add unique stats and abilities for different mount types
    - [ ] Create training system for animal companions
    - [ ] Design mounted combat advantages
- **Detailed Crafting Chains**
    - [ ] Implement multi-step crafting processes with intermediate products
    - [ ] Create magical material crafting from monster resources
    - [ ] Add quality variation in crafted items
    - [ ] Design specialized workstations for different crafting types
- **Complex Social Dynamics**
    - [ ] Implement relationship system between pawns
    - [ ] Create social interactions and events triggered by relationships
    - [ ] Add mood effects from relationship statuses
    - [ ] Design gift-giving mechanics based on preferences


## Phase 3: World Exploration \& Overmap (2-3 weeks)

- **Overworld Map System**
    - [ ] Implement procedural world generation inspired by Dwarf Fortress
    - [ ] Create different biome regions with unique characteristics
    - [ ] Add settlements, ruins, and dungeons to explore
    - [ ] Design travel mechanics between locations
- **Dungeon Generation System**
    - [ ] Create procedural dungeon layouts with varying difficulty
    - [ ] Implement specialized loot for different dungeon types
    - [ ] Add unique bosses for major dungeons
    - [ ] Design puzzle elements and traps
- **Faction \& Quest System**
    - [ ] Implement NPC factions with relationship values
    - [ ] Create diplomacy and trade mechanics
    - [ ] Design procedural quest generation
    - [ ] Add reputation effects on gameplay


## Phase 4: Technical Improvements (2-3 weeks)

- **Pathfinding Enhancements**
    - [ ] Implement hierarchical pathfinding for large maps
    - [ ] Add path caching for frequently traveled routes
    - [ ] Create advanced terrain cost calculations
    - [ ] Optimize group movement patterns
- **Performance Optimization**
    - [ ] Implement spatial partitioning for large maps
    - [ ] Add multithreading for generation steps
    - [ ] Create dynamic level-of-detail systems for distant areas
    - [ ] Optimize entity update scheduling
- **Enhanced User Experience**
    - [ ] Create comprehensive save/load system
    - [ ] Implement tutorial elements
    - [ ] Add atmospheric effects (day/night, weather)
    - [ ] Design customizable UI elements
- **Advanced Art and Sound Systems**
    - [ ] Implement sprite animation system for pawns and creatures
    - [ ] Create advanced particle effects for elemental magic
    - [ ] Develop weather-specific visual and sound effects
    - [ ] Generate territory-specific visual indicators

