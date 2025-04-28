
# TASKS.md

## Phase 1: Complete Foundation & Basic Visualization (1-2 weeks)

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
    - [ ] Add resource generation focusing on 2-3 main resources

## Phase 3: Game Mechanics Integration (2 weeks)

- **Key Systems**
    - [x] Basic monster territory system using your existing territory_owner property
    - [ ] Simple resource harvesting mechanics
    - [ ] Implement pawn movement with terrain movement multipliers

## Phase 4: Pawn Implementation (2-3 weeks)

- **Pawn Creation & Attributes**
    - [ ] Implement basic pawn class with core attributes (strength, dexterity, intelligence)
    - [ ] Create simple trait system for pawn personality
    - [ ] Add basic pawn appearance generation
    - [ ] Implement pawn naming system

- **Pawn Needs System**
    - [ ] Implement hunger and rest needs
    - [ ] Add mood/happiness tracking
    - [ ] Create basic temperature effects (comfort zone)
    - [ ] Implement shelter requirements

- **Work & AI System**
    - [ ] Create job assignment interface
    - [ ] Implement work priorities system
    - [ ] Add basic pawn AI for autonomously selecting tasks
    - [ ] Implement idle behaviors when no work is available

- **Basic Social Layer**
    - [ ] Add simple relationship tracking between pawns
    - [ ] Implement basic social interactions
    - [ ] Create foundational mood effects from relationships

## Phase 5: Colony Essentials (2 weeks)

- **Resource Management**
    - [ ] Implement stockpile zones for storage
    - [ ] Create simple inventory system for pawns
    - [ ] Add basic item categories and properties

- **Basic Construction**
    - [ ] Implement construction interface
    - [ ] Create fundamental building types (walls, doors, beds)
    - [ ] Add deconstruction mechanics

- **Time & Environment**
    - [ ] Implement day/night cycle
    - [ ] Add basic weather system
    - [ ] Create simple temperature fluctuations

# Post-MVP Task List

## Phase 1: Advanced World Generation (3-4 weeks)

1. **Enhanced Terrain System**
   * [ ] Create Diamond-Square generator for terrain features
   * [ ] Add PDS (Perlin + Diamond-Square) hybrid generator
   * [ ] Implement erosion simulation for river paths
   * [ ] Create ocean and lake definition system

2. **Environmental Systems**
   * [ ] Implement temperature generation based on density and position
   * [ ] Create humidity system spreading from water sources
   * [ ] Add wind generation affecting temperature and humidity
   * [ ] Implement seasonal variation system

3. **Territory and Exploration**
   * [ ] Enhance monster territory system with difficulty gradients
   * [ ] Add visual territory boundary indicators (claw marks, etc.)
   * [ ] Implement fog of war with pawn vision radius
   * [ ] Create scouting mechanics for map exploration

## Phase 2: Pawn and Colony Systems (3-4 weeks)

4. **Advanced Pawn Mechanics**
   * [ ] Implement combat skills system with progression
   * [ ] Create elemental magic system with environmental affinities
   * [ ] Add rideable animals with unique stats
   * [ ] Develop complex social dynamics between pawns

5. **Colony Management**
   * [ ] Create detailed crafting chains with intermediate steps
   * [ ] Implement organic research system tied to pawn skills
   * [ ] Add contextual disease system based on environment
   * [ ] Develop master-apprentice teaching mechanics

6. **Resource and Item Systems**
   * [ ] Create resource distribution system based on biomes
   * [ ] Implement special resource generation in monster territories
   * [ ] Add procedural artifact and legendary item generation
   * [ ] Develop inventory management system

## Phase 3: World Interaction and Events (2-3 weeks)

7. **Environmental Interaction**
   * [ ] Create elemental interaction systems (water + fire = steam)
   * [ ] Implement biome-specific events and hazards
   * [ ] Add magical material crafting from monster resources
   * [ ] Create weather effects with gameplay impact

8. **Event System**
   * [ ] Implement customizable event probabilities
   * [ ] Create interconnected events (heat waves → droughts)
   * [ ] Add relationship crises triggering unique events
   * [ ] Develop faction-based event chains

9. **World Map and Locations**
   * [ ] Create overworld map system for exploration
   * [ ] Implement procedural dungeon generation
   * [ ] Add NPC faction settlements and diplomacy
   * [ ] Develop quest system with rewards

## Phase 4: Technical Improvements (2-3 weeks)

10. **Performance Optimization**
    * [ ] Implement spatial partitioning for large maps
    * [ ] Add multithreading for generation steps
    * [ ] Create chunk-based processing for memory efficiency
    * [ ] Implement path caching for frequently traveled routes

11. **User Interface**
    * [ ] Create save/load system for games
    * [ ] Implement advanced control schemes
    * [ ] Add preview generation options
    * [ ] Create comprehensive tutorial system

12. **Enhanced Visuals**
    * [ ] Implement animated terrain elements
    * [ ] Add visual effects for magic and combat
    * [ ] Create day/night lighting system
    * [ ] Develop atmospheric weather visualization
