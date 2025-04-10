# Fantasy Colony Sim

A fantasy-themed colony simulation game inspired by Rimworld and Dwarf Fortress, built using Godot Engine. This project aims to provide a unique and immersive experience by combining proven gameplay mechanics with innovative features tailored to a vibrant fantasy setting.

---

## **Project Overview**

Fantasy Colony Sim is a hobby project designed to create a personal gaming experience. It focuses on building a colony in a rich, procedurally generated world, managing pawns with complex needs and relationships, and exploring unique gameplay systems inspired by both Rimworld and Dwarf Fortress.

While the core gameplay loop is similar to its inspirations, the game introduces several innovations that make it stand out, such as detailed crafting chains, enhanced map exploration mechanics, organic research systems, and more.

---

## **Core Features**

### **1. Detailed Crafting Chains**
- Crafting involves multiple intermediate steps, reflecting technological progression.
- Example: Walls progress from mud → clay → wood → stone brick → magical stone.
- Leather production includes hunting animals, tanning hides, drying leather, and archiving fur.
- Magical materials can be crafted by processing resources obtained from dangerous magical creatures.

---

### **2. Enhanced Map Exploration**
- **Fog of War**: Players can only see areas within their pawns' vision radius.
- **Elevation System**: Higher terrain expands view radius and introduces strategic advantages.
- **Predator Mechanics**: Animals attack when pawns enter their aggression zones rather than randomly hunting.
- **Scout Specialization**: Pawns with favorable traits can be trained as scouts to explore the map effectively.

---

### **3. Organic Research System**
- Research is tied to pawn skills:
  - Pawns contribute to tech discovery naturally through their primary jobs (e.g., cooking).
  - High learning traits improve research contributions.
- Master-apprentice dynamics allow skilled pawns to teach others, speeding up skill progression.

---

### **4. Customizable Event System**
- Players can toggle event probabilities instead of choosing predefined storytellers.
- Examples:
  - Acid rain increases the likelihood of acid creature raids.
  - Heat waves increase the chance of droughts.
- Events are interconnected to create a responsive world.

---

### **5. Contextual Disease System**
- Diseases are no longer random "birthday events."
- Illness likelihood depends on:
  - Exposure to filth
  - Hygiene (impacted by traits)
  - Food quality
  - Mood
  - Magic (e.g., mage abilities or potions reducing illness risk)
- Certain enemies or animals may induce illnesses as part of combat mechanics.

---

### **6. Enhanced Aesthetic Experience**
- Vibrant visuals inspired by Stardew Valley:
  - Intense colors for fires and magical effects
  - Cozy music during peaceful colony life
  - Action-packed music during combat
- Furniture and environmental graphics are designed to feel alive and immersive.

---

### **7. Rideable Animals**
- Pawns can ride animals for faster movement and exploration.
- Mount types include both mundane (horses) and magical creatures (griffins).
- Mounts have unique stats like speed, carrying capacity, and combat abilities.
- Mount care involves feeding, sheltering, and training.

---

### **8. Complex Social Dynamics**
- Pawns have intricate relationships:
  - Gift-giving system based on preferences
  - Emotional contagion (e.g., joy or depression spreading through social networks)
  - Buffs/debuffs based on relationship status (e.g., work bonuses for romantic partners)
- Relationship crises trigger unique events:
  - Romantic rivalry might lead to jealousy buffs/debuffs.
  - Friendships might influence decision-making in combat or tasks.

---

### **9. Kingdom Interaction System** *(Planned for Future Development)*
- Expand gameplay beyond the colony:
  - Visit kingdoms on an overworld map
  - Undertake quests for NPC factions
  - Engage in diplomacy or trade with neighboring realms
- Potential evolution into Baldur's Gate-style RPG mechanics.

---

## **Development Goals**

### MVP Features:
1. Procedural map generation with five terrain types.
2. Basic pawn movement and pathfinding.
3. Resource gathering system (wood, stone).
4. Simple construction mechanics (walls, shelters).
5. Basic pawn needs system (hunger, rest).
6. Event system with customizable probabilities.

### Post-MVP Expansion:
1. Detailed crafting chains with intermediate steps.
2. Fog of war and elevation-based exploration mechanics.
3. Organic research tied to pawn skills.
4. Contextual disease system based on hygiene metrics.
5. Rideable animals with specialized stats.

---

## **Technical Details**

### Engine:
Godot Engine (version 4.4)

### Programming Language:
GDScript

