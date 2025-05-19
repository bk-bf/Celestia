
## 2025-04-10
 * Initial project structure setup (Kirill Boychenko)
 * Remove .gitignore file, cleaning up project structure. (Kirill Boychenko)
 * Remove configuration and resource files, further cleaning up project structure. (Kirill Boychenko)
 * Refactor project structure by removing unused configuration files and optimizing resource organization. (Kirill Boychenko)
 * Add camera input configurations and remove empty sprites directory, made tiles and started work on a 50x50 proceedurally generated tilemap (Kirill Boychenko)
 * Update README.md to provide a comprehensive project overview, detailing core features, development goals, and technical specifications for Fantasy Colony Sim. (Kirill Boychenko)
 * Update README.md to reflect the use of Godot Engine version 4.4. (Kirill Boychenko)

## 2025-04-22
 * Update project configuration and remove unused assets. Added Gaea plugin support in project.godot, while deleting placeholder images and related import files to streamline resources. (Kirill Boychenko)
 * Update tile_map_layer.tscn to enhance resource connections and adjust node positions for improved tilemap generation. Added new resource definitions and modified existing parameters for better functionality. (Kirill Boychenko)
 * Remove unused sprite assets and their import files from the project. Update tile_map_layer.tscn to replace references to the deleted sprites with new texture resources, enhancing the tilemap's visual elements. (Kirill Boychenko)

## 2025-04-23
 * Update README.md (bk)

## 2025-04-26
 * feat: Implement terrain grid and tile system (Kirill Boychenko)

## 2025-04-27
 * refactor: Remove obsolete world data and test scripts - Enhanced grid.gd with cell size management and coordinate conversion methods. - Modified tile.gd to replace altitude with density. (Kirill Boychenko)
 * feat: Connect coordinate grid with MapData, improved coordinate number readability (Kirill Boychenko)
 * Update MVP_Task_List.md (bk)
 * Update MVP_Task_List.md (bk)
 * Update MVP_Task_List.md (bk)
 * refactor: Update terrain system and remove obsolete scripts (Kirill Boychenko)
 * Update README.md (bk)
 * Refactor map generation and statistics system (Kirill Boychenko)
 * Rename MVP_Task_List.md to TASKS.md (bk)
 * Enhance map generation and statistics features (Kirill Boychenko)

## 2025-04-28
 * refactor: - Enhance map generation and territory management systems - Fixed a pesky bug where the territory terrain would not load properly or adhere to the no water/preferred terrain rules - am ready to shoot myself (Kirill Boychenko)
 * refactor: Update task list with completed items and enhance clarity (Kirill Boychenko)
 * Update README.md (bk)
 * refactor: Revise map generation and added a prototype pathfinding system, enhance grid handling and movement costs (Kirill Boychenko)
 * refactor: Update scene and configuration for larger map dimensions, enhance pathfinding logic through adding a maximum tiles check limit, and improve movement cost display (Kirill Boychenko)
 * Update TASKS.md (bk)

## 2025-04-29
 * Update TASKS.md (bk)
 * Update TASKS.md (bk)
 * Update TASKS.md (bk)
 * Update TASKS.md (bk)
 * Update and rename TASKS.md to ROADMAP.md (bk)
 * Update ROADMAP.md (bk)
 * Update ROADMAP.md (bk)
 * Update ROADMAP.md (bk)
 * Update ROADMAP.md (bk)

## 2025-04-30
 * Restructured the repo so it is more sensibly organised (Kirill Boychenko)
 * Refactor resource paths and update identifiers in map and pathfinding scripts (Kirill Boychenko)
 * Enhance EditorConfig settings, cleaned up shadowed variables (Kirill Boychenko)
 * Add comments to clarify limitations of the pathfinding algorithm (Kirill Boychenko)
 * Add progress reports detailing core architecture, systems, and pathfinding development; enhance documentation structure for clarity and organization. (Kirill Boychenko)
 * ups (Kirill Boychenko)

## 2025-05-02
 * Refactor map rendering into dedicated renderer class (Kirill Boychenko)
 * Refactors map generation and statistics system (Kirill Boychenko)
 * Updates map rendering and font mipmap settings (Kirill Boychenko)
 * Update ROADMAP.md (bk)
 * Add files via upload (bk)
 * Update Progress_Report_#4.md (bk)

## 2025-05-03
 * Update ROADMAP.md (bk)
 * Enhances resource system with skill requirements (Kirill Boychenko)
 * Add test_map.tres to gitignore (Kirill Boychenko)
 * Update ROADMAP.md (bk)
 * Restructure game scene and add map center utilities (Kirill Boychenko)
 * Update ROADMAP.md (bk)

## 2025-05-04
 * Implements pawn movement with terrain multipliers (Kirill Boychenko)
 * Removed now depricated pathfinder_tester (Kirill Boychenko)
 * Add Progress_Report_#5 (Kirill Boychenko)
 * Implements resource harvesting and refines pawn management (Kirill Boychenko)
 * docs: Update project roadmap and remove completed notes, renamed notes.md to SIDE_TASKS.md to better reflect its purpose (Kirill Boychenko)

## 2025-05-05
 * docs: Expand UI/UX development phase with detailed tasks for interface design, player interaction, and feedback systems (Kirill Boychenko)
 * Enhance resource harvesting and visualization system (Kirill Boychenko)
 * Complete resource harvesting mechanics (Kirill Boychenko)
 * Marks resource harvesting mechanics as completed (Kirill Boychenko)
 * Add terrain transformation system to roadmap (Kirill Boychenko)
 * Adjusts development timeline by marking Phase 5 (Art/Sound) and Phase 6 (UI/UX) to run concurrently (Kirill Boychenko)
 * Restructures roadmap with expanded territory and database systems (Kirill Boychenko)
 * Enhance map rendering and camera initialization (Kirill Boychenko)
 * Restructures roadmap into clearer project phases (Kirill Boychenko)
 * Implements trait system for pawn customization (Kirill Boychenko)
 * Update ROADMAP.md (bk)
 * Update ROADMAP.md (bk)

## 2025-05-06
 * Enhances pawn customization and initialization (Kirill Boychenko)
 * Expands trait system (Kirill Boychenko)
 * Revamps territory generation system and pawn management (Kirill Boychenko)
 * Adds territory coexistence and debugging features (Kirill Boychenko)
 * Adds spawn area territory clearing and walkable tile checks (Kirill Boychenko)
 * Adds toggleable territory markers (Kirill Boychenko)
 * Expands terrain system with movement and subtypes (Kirill Boychenko)

## 2025-05-07
 * Consolidates database managers into unified singleton (Kirill Boychenko)
 * Completes DatabaseManager implementation (Kirill Boychenko)
 * The database initialization may need adjustment to properly handle map data loading with @onready var (Kirill Boychenko)
 * renamed directory (Kirill Boychenko)
 * Refactor map data initialization for pawn loading safety (Kirill Boychenko)
 * Enhances pawn class with typed properties and constants (Kirill Boychenko)
 * Refactors visualization to use tilemaps instead of sprites (Kirill Boychenko)
 * Removes tile resource change handling (Kirill Boychenko)

## 2025-05-08
 * Remove entity tilemap and refactor pawn rendering (Kirill Boychenko)
 * Update ROADMAP.md (bk)
 * Update ROADMAP.md (bk)
 * Update SIDE_TASKS.md (bk)
 * Create LICENSE (bk)
 * Create LICENSE (bk)

## 2025-05-10
 * Mark TileMap tasks as done and reorder phases (Kirill Boychenko)
 * Refactor TileMap integration by removing merge conflict markers and updating tasks for z-indexing and resource visualization (Kirill Boychenko)
 * Update ROADMAP.md to enhance TileMap resource visualization and reorganize monster territory system tasks (Kirill Boychenko)

## 2025-05-11
 * removed progress bar, since its not visible either way and causes an error (Kirill Boychenko)

## 2025-05-13
 * Adds pawn needs system with hunger and rest states (Kirill Boychenko)

## 2025-05-14
 * Enhances pawn needs management and state transitions (Kirill Boychenko)
 * Enhance pawn needs and state management system (Kirill Boychenko)
 * Update ROADMAP.md (bk)
 * Update SIDE_TASKS.md (bk)
 * Update SIDE_TASKS.md (bk)
 * Adds mood system and pawn attribute display features (Kirill Boychenko)
 * Update task tracking and reorganize meal system tasks (Kirill Boychenko)
 * Adds UI roadmap section with essential displays (Kirill Boychenko)

## 2025-05-15
 * Reorganizes roadmap phases and expands item system (Kirill Boychenko)
 * Add pawn-system merge task to side tasks (Kirill Boychenko)
 * Remove outdated roadmap document to streamline project planning (Kirill Boychenko)
 * Updates task list with new mood system plans (Kirill Boychenko)

## 2025-05-16
 * Delete docs/tasks/map_statistics.md (bk)
 * implemented a DatabaseManager and started work on the designation system, which is part of a broader basic UI feature (Kirill Boychenko)

## 2025-05-17
 * Removes draw designations feature from map renderer (Kirill Boychenko)
 * Remove unused designation colors and update task list (Kirill Boychenko)
 * Adds work priority management system (Kirill Boychenko)
 * Adds HUD panel with anchor points (Kirill Boychenko)

## 2025-05-18
 * Implements HUD framework and adjusts window settings (Kirill Boychenko)

## 2025-05-19
 * Refactor UI handling and improve job signaling system (Kirill Boychenko)
 * Update SIDE_TASKS.md (Kirill Boychenko)
 * Add comprehensive progress report for UI system implementation (Kirill Boychenko)
