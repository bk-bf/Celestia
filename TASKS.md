
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

**Phase 1: Foundation Setup (2-3 weeks)**

1. **Create Core Data Structures**
    * [x] Create `MapData` class to store all terrain information
    * [x] Define `Tile` class with properties (density, biome, resources)
    * [x] Implement a `Grid` class to manage tile collections
    * [x] Set up coordinate system and grid dimensions
2. **Design Generator Framework**
    * [x] Create a `StepGenerator` base class/interface
    * [x] Implement `ChainMapGenerator` to run generators sequentially
    * [ ] Create a system to track and validate generation dependencies
    * [ ] Design a state tracking system (similar to `MapAspects` in the thesis)
3. **Implement Basic Visualization**
    * [x] Create debug visualization for terrain data
    * [x] Set up conversion from generator data to `TileMapLayers`
    * [x] Implement system to display generation progress

**Phase 2: Primary Generators (3-4 weeks)**

4. **Density Generation**
    * [x] Implement Perlin noise generator for base terrain
    * [ ] Create Diamond-Square generator for terrain features
    * [ ] Add PDS (Perlin + Diamond-Square) hybrid generator
    * [x] Implement density smoothing algorithms
5. **Water System Generation**
    * [ ] Create ocean and lake definition system
    * [x] Implement river generation algorithm with flow paths
    * [ ] Set up water level tracking for different water bodies
    * [ ] Implement erosion simulation for river paths
6. **Environment Factor Generation**
    * [ ] Create temperature generation system based on density and position
    * [ ] Implement humidity system spreading from water sources
    * [ ] Add wind generation affecting temperature and humidity
    * [ ] Create seasonal variation system (optional)

**Phase 3: Biome and Resource System (2-3 weeks)**

7. **Biome System Implementation**
    * [x] Create biome classification system based on environmental factors
    * [ ] Implement biome smoothing with cellular automata
    * [x] Add transition zones between biomes
    * [x] Set up biome metadata storage
8. **Resource Generation**
    * [ ] Create resource distribution system based on biomes
    * [ ] Implement resource density variation
    * [ ] Add resource clustering algorithms
    * [ ] Create special resource generation for unique terrain features
9. **Object Placement System**
    * [ ] Implement tree placement on valid terrain
    * [ ] Create rock and boulder placement algorithms
    * [ ] Add object variation based on biome types
    * [ ] Implement object density controls

**Phase 4: Integration and Optimization (2-3 weeks)**

10. **TileMap Integration**
    * [x] Convert generator output to multiple `TileMapLayers`
    * [ ] Set up proper layer ordering (ground, objects, etc.)
    * [ ] Add collision shapes to appropriate layers
    * [x] Implement custom data attributes for interactive tiles
11. **User Interface and Controls**
    * [x] Create generator parameter controls
    * [x] Implement seed management for reproducible maps
    * [ ] Add preview generation options
    * [ ] Create save/load system for generator configurations
12. **Optimization**
    * [ ] Implement spatial partitioning for large maps
    * [x] Set up chunk-based processing for memory efficiency (added max search limits)
    * [ ] Add multithreading for generation steps
    * [ ] Implement caching for frequently accessed data

<div style="text-align: center">⁂</div>

[^1]: https://pplx-res.cloudinary.com/image/private/user_uploads/uOIaYrVNjJmCZpv/Selection_007.jpg

[^2]: https://pplx-res.cloudinary.com/image/private/user_uploads/KrhYMGbKCevhekB/Selection_008.jpg

[^3]: https://pplx-res.cloudinary.com/image/private/user_uploads/NmwTmXtTlFOgmja/Selection_009.jpg
