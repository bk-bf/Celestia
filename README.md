# Celestia - Fantasy Colony Simulation

A fantasy-themed colony simulation game inspired by RimWorld, Dwarf Fortress, Battle Brothers, Stoneshard, and Baldur's Gate, built using Godot Engine 4.4. This project aims to provide a unique and immersive experience by combining proven gameplay mechanics with innovative features tailored to a vibrant fantasy setting.

## Project Overview

Celestia is a hobby project designed to create a personal gaming experience. It focuses on building a colony in a rich, procedurally generated world, managing pawns with complex needs and relationships, and exploring unique gameplay systems. The game introduces several innovations that make it stand out from its inspirations, such as detailed crafting chains, monster territory systems, combat skills, and magical abilities.

## Core Features

### 1. Detailed Crafting Chains
- Crafting involves multiple intermediate steps, reflecting technological progression
- Example: Walls progress from mud → wood → clay → wood → stone → brick → magical stone
- Leather production includes hunting animals, tanning hides, drying leather, and archiving fur
- Magical materials can be crafted by processing resources obtained from dangerous magical creatures

### 2. Enhanced Map Exploration
- Fog of War: Players can only see areas within their pawns' vision radius
- Predator Mechanics: Animals attack when pawns enter their aggression zones rather than randomly hunting
- Scout Specialization: Pawns with favorable traits can be trained as scouts to explore the map effectively

### 3. Monster Territory System
- Monsters control specific areas of the map in a procedurally generated and terrain-dependend territory structure
- Visual cues (like claw marks on trees) indicate territory boundaries
- Difficulty increases from periphery to center, with weaker monsters on the outside and stronger ones near the core
- Boss monsters reside at the territory center, guarding valuable resources
- Defeating monsters allows access to previously blocked resources (minerals, magical items, herbs)

### 4. Combat Skills System
- Pawns develop combat skills similar to Battle Brothers progression
- Skills include weapon proficiency, evasion, armor usage, and critical strikes
- Skill trees allow for specialization (e.g., crossbow users can become close-range skirmishers or long-range snipers)
- Skills improve through actual combat performance
- More challenging enemies provide better skill improvement opportunities

### 5. Elemental Magic System
- Mages gain affinity bonuses based on their environment:
  - Geomancers gain bonuses when standing on stone
  - Hydromancers gain bonuses near water
  - Aeromancers gain bonuses during windy weather
  - Pyromancers gain bonuses during hot weather or near heat sources
- Environmental interactions create tactical opportunities (e.g., water + fire creates steam for rogue cover)
- Positioning is crucial for maximizing magical effectiveness and avoiding friendly fire

### 6. Organic Research System
- Research is tied to pawn skills
- Pawns contribute to tech discovery naturally through their primary jobs (e.g., cooking)
- High learning traits improve research contributions
- Master-apprentice dynamics allow skilled pawns to teach others, speeding up skill progression

### 7. Customizable Event System
- Players can toggle event probabilities instead of choosing predefined storytellers
- Examples:
  - Acid rain increases the likelihood of acid creature raids
  - Heat waves increase the chance of droughts
- Events are interconnected to create a responsive world

### 8. Contextual Disease System
- Illness likelihood depends on:
  - Exposure to filth
  - Hygiene (impacted by traits)
  - Food quality
  - Mood
  - Magic (e.g., mage abilities or potions reducing illness risk)
- Certain enemies or animals may induce illnesses as part of combat mechanics

### 9. Enhanced Aesthetic Experience
- Vibrant visuals inspired by Stoneshard's detailed pixel art style
- Detailed yet readable art with excellent contrast between elements
- Strategic use of texture direction to help different elements stand out
- Effective color palette with vibrant colors for important elements
- Depth through shading and atmospheric lighting
- Intense colors for fires and magical effects
- Cozy music during peaceful colony life
- Action-packed music during combat

### 10. Rideable Animals
- Pawns can ride animals for faster movement and exploration
- Mount types include both mundane (horses) and magical creatures (griffins)
- Mounts have unique stats like speed, carrying capacity, and combat abilities
- Mount care involves feeding, sheltering, and training
- Some pawns can fight on or with their tamed animals, providing tactical variety

### 11. Complex Social Dynamics
- Pawns have intricate relationships
- Gift-giving system based on preferences
- Emotional contagion (e.g., joy or depression spreading through social networks)
- Buffs/debuffs based on relationship status (e.g., work bonuses for romantic partners)
- Relationship crises trigger unique events
  - Romantic rivalry might lead to jealousy buffs/debuffs
  - Friendships might influence decision-making in combat or tasks

### 12. Kingdom Interaction System (Planned for Future Development)
- Expand gameplay beyond the colony
- Visit dungeons and other locations on an overworld map
- Undertake quests for NPC factions
- Engage in diplomacy or trade with neighboring realms
- Discover procedural artifacts and legendary items in dungeons
- Face increasingly difficult raids and wandering monsters

## Game Loop

1. **Survival Phase**: Establish a foothold in a hostile environment, focusing on immediate needs like shelter, food, and basic defenses.

2. **Expansion Phase**: Begin exploring the map, encountering monsters that guard valuable resources, and gradually expanding domain of influence.

3. **Conquest Phase**: Venture into the overworld, tackle dungeons, interact with factions, and defend against increasingly difficult threats.

## Combat System

- Real-time with pause mechanics allow for thoughtful tactical decisions
- Positioning is crucial for success:
  - Elemental mages gain bonuses on appropriate terrain
  - Ranged attacks risk friendly fire based on distance and positioning
  - Environmental interactions create tactical opportunities
- Pawns progress from zero to hero through combat experience
- Procedural artifacts and legendary items provide long-term goals

## Development Goals

### MVP Features
1. Procedural map generation with five terrain types
2. Basic pawn movement and pathfinding
3. Resource gathering system (wood, stone)
4. Simple construction mechanics (walls, shelters)
5. Basic pawn needs system (hunger, rest)
6. Event system with customizable probabilities

### Post-MVP Expansion
1. Detailed crafting chains with intermediate steps
2. Fog of war exploration mechanics
3. Monster territory system
4. Combat skills system
5. Elemental magic system
6. Rideable animals with specialized stats

## Technical Details

- **Engine**: Godot Engine version 4.4
- **Programming Language**: GDScript
