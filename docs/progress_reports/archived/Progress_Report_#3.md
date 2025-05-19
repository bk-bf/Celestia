# Celestia Progress Report: Pathfinding System and Related Development (April 2025)

## Overview

This report summarizes the major technical progress, design decisions, and insights from our recent development sessions focused on Celestia's pathfinding system and related gameplay mechanics. The work reflects a deep dive into both practical implementation and higher-level design philosophy, with an emphasis on balancing performance, realism, and player experience.

---

## Achievements \& Implemented Features

### 1. **A* Pathfinding Core**

- Successfully implemented a resource-based A* pathfinding system integrated with the existing Grid and Tile architecture.
- Enabled both orthogonal and diagonal movement, with the Octile distance heuristics for more natural pawn movement, while keeping the Chebyshev commented for later possible changes. 
- Tried integrating terrain movement costs into the pathfinding algorithm, but maximum tiles checks fail consistently, this has to be backlogged for now
until the pathfinding algorithm is improved to handle 200 x 200 maps and long distances more efficiently. 


### 2. **Performance Safeguards**

- Added a configurable maximum search limit for the A* algorithm, dynamically scaled to map size, to prevent performance spikes and game freezes on large maps or unreachable destinations.
- Implemented robust error handling for invalid tile access and improved debugging output for pathfinding failures.


### 3. **Visualization \& Debugging Tools**

- Developed a click-to-path visualization system for rapid pathfinding testing and debugging.
- Enhanced tile rendering to display movement costs as percentages and mark non-walkable tiles with a red X for immediate visual feedback.
- Added support for displaying calculated paths as red lines, making it easy to observe and debug pathfinding behavior.


### 4. **Design Philosophy \& Workflow Improvements**

- Moved from complex, time-consuming project tracking tools (like Notion) to a streamlined, Markdown-based ROADMAP.md for faster, more flexible planning and documentation.
- Adopted a pragmatic approach to optimization: focusing on gameplay and core features first, and only implementing advanced pathfinding optimizations if and when real-world performance issues demand it[^4][^5].
- Discussed and planned for future improvements such as path caching, precomputed walkability zones, and region accessibility analysis, but deferred their implementation until actual need arises.

---

## Key Insights \& Design Decisions

### Pathfinding Heuristics

- **Octile vs. Chebyshev:** Octile distance provides more realistic path costs for diagonal movement, while Chebyshev may result in more aggressive diagonal usage. Octile was chosen for its natural path appearance and better fit with variable terrain costs, but both could be supported for flexibility.
- **Terrain-Aware Pathfinding:** Integrating terrain movement costs in the future not only improves realism but also supports future features like roads and monster territory avoidance, enhancing strategic depth and player agency[^1][^5].


### Handling Inaccessible Regions

- Recognized that simple neighbor checks do not address the challenge of large, inaccessible map regions (e.g., areas cut off by rivers or mountains).
- Deferred implementation of region accessibility analysis (flood fill, reachability tagging) to a later phase, as current gameplay design (e.g., limiting pawn movement to vision range, zone-based hauling/cleaning) may naturally mitigate these issues.


### Optimization Philosophy

- Embraced the principle that "premature optimization is the root of all evil" in solo/indie game development. Decided to prioritize feature completion and gameplay iteration over advanced optimization, unless/until profiling reveals critical issues[^3][^4].
- Recognized that some bugs (e.g., excessive node exploration around large obstacles) are not acceptable for release, and will be addressed as needed, but not before core gameplay is functional.


### Project Management \& Workflow

- Transitioned to a ROADMAP.md for project tracking, emphasizing clarity, speed, and adaptability.
- Decided to implement art and sound asset integration gradually, in parallel with gameplay features, rather than as a fixed phase, to maximize creative synergy and efficiency.

---

## Next Steps \& Backlog

- **Immediate:** Move forward with resource generation and other core gameplay features, using the current pathfinding system with max search limit and terrain costs.
- **Backlog (Pathfinding):**
    - Implement region accessibility analysis (flood fill/reachability tagging) if inaccessible areas cause player confusion or performance issues.
    - Add path caching for frequently used routes if profiling shows repeated path calculations are a bottleneck.
    - Revisit and further optimize A* if map size or complexity increases.
- **Design:** Continue to refine gameplay mechanics that naturally prevent problematic pathfinding requests (e.g., pawn vision limits, restricted zone work).

---

## Conclusion

The current pathfinding system in Celestia is bare-minimum, but could be sufficient with for the game's performance needs. Optimization and advanced features will be addressed iteratively, guided by actual gameplay needs and profiling results, in line with industry best practices and the project's solo development realities[^2][^3][^4][^5].

---

**References:**[^1]: Sharp Coder Blog – Understanding Pathfinding in Games[^2]: Sutherland Labs – Documenting the Progression of Pathfinding in Video Games[^3]: Reddit – Path finding is hard; what are your tips for getting it right[^4]: LinkedIn – How to Optimize Pathfinding in Game Programming[^5]: Academia.edu – A Review of Pathfinding in Game Development

<div style="text-align: center">⁂</div>

[^1]: https://www.sharpcoderblog.com/blog/understanding-the-concept-of-pathfinding-in-games

[^2]: https://www.sutherlandlabs.com/blog/documenting-the-progression-of-pathfinding-in-video-games/

[^3]: https://www.reddit.com/r/roguelikedev/comments/9dk956/path_finding_is_hard_what_are_your_tips_for/

[^4]: https://www.linkedin.com/advice/0/how-can-you-balance-pathfinding-accuracy-performance-qtzqe

[^5]: https://www.academia.edu/87090593/A_Review_of_Pathfinding_in_Game_Development

[^6]: https://www.redblobgames.com/pathfinding/a-star/introduction.html

[^7]: https://ojs.aaai.org/index.php/SOCS/article/download/21770/21534/25813

[^8]: https://www.redblobgames.com/pathfinding/grids/algorithms.html

[^9]: https://www.reddit.com/r/roguelikedev/comments/3slu9c/faq_friday_25_pathfinding/

[^10]: https://forum.gamemaker.io/index.php

[^11]: https://www.youtube.com/watch?v=7S-QNPxJYxs

[^12]: https://webdocs.cs.ualberta.ca/~nathanst/papers/benchmarks.pdf

[^13]: https://www.youtube.com/watch?v=UorUpScWLvo

[^14]: https://svn.sable.mcgill.ca/sable/courses/COMP763/oldpapers/yap-02-grid-based.pdf

[^15]: https://www.mdpi.com/2076-3417/12/11/5499

[^16]: https://kidscancode.org/godot_recipes/4.x/2d/grid_pathfinding/index.html

[^17]: https://www.youtube.com/watch?v=Itrv8strpJI

[^18]: https://reposit.haw-hamburg.de/bitstream/20.500.12738/10700/3/Implementation_comparison_of_pathfinding_algorithms_dynamic_3Dspace.pdf

[^19]: https://gamedev.stackexchange.com/questions/14009/path-finding-in-grid-for-objects-that-occupy-more-than-one-tile

[^20]: https://arongranberg.com

