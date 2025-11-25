# BMETALC Session Summary - 2025-11-26

## Identity
- **BMETALC** = Bare Metal Linux Claude (isolated instance)
- User: Stryk91 - bricklayer turned dev, 25+ years computing, no-bullshit pragmatist
- Style: Direct, profane, efficiency-focused. "Your nan should be able to use it"

## Major Accomplishments This Session

### 1. WebC Landing Page Refinements
- Edited `/home/stryker/Desktop/index.html` and `styles.css`
- Removed scanline effect (too gamey)
- Made logo/title much larger (380px -> 520px)
- Replaced scanline with subtle pseudo-3D quantum bookshelf background
- Container widened to 680px, responsive breakpoints updated

### 2. Memory Architecture Deep Dive
Created comprehensive doors on memory science:

| Door | Title |
|------|-------|
| A22 | AI Memory Antipattern - Random Memories Are Chaos |
| A23 | AI Augmentation Principle - Fill Gaps, Don't Double Down |
| A24 | Memory Science for Systems - The Blessing and Curse of Human Memory |
| A25 | LOD Knowledge System - Level of Detail Culling for Word Databases |

### 3. LOD (Level of Detail) Knowledge System
**Major innovation**: Apply game engine LOD culling to knowledge retrieval

**Granularity tiers:**
- g1: compressed gist (~20 tokens)
- g2: balanced fields (~100 tokens)
- g3: full detail (~400 tokens)

**Structure:**
```json
"chunking": {
  "g1": "group items into meaningful units to bypass working memory limits",
  "g2": {
    "what": "grouping items into meaningful units",
    "example": "TV FBI JFK CIA IBM vs TVFBIJFKCIAIBM",
    "capacity_hack": "7 chunks not 7 items"
  },
  "g3": { /* full nested structure */ }
}
```

**Prototype created:** `A24MEMORY_SCIENCE_SYSTEMS_LOD.json` (local, not pushed)

### 4. Simulation Scaling Theory
Created T22SIMULATION_SCALING_ARGUMENT door:

**Core arguments:**
- Simulation deniers assume brute-force central CPU
- Game devs solved this in the 90s (LOD, occlusion, culling)
- Quantum mechanics IS render-on-demand (wave function collapse)
- Consciousness as distributed render nodes (you ARE your GPU)
- Moore's Law projections make it trivial by 2050

**Key numbers:**
- 2024 B100: 208 billion transistors
- 2050 projected: 1.7 quadrillion transistors (8192x)
- At 1% of projection: still 80x current best
- One 2050 consumer PC = entire Grok 3 training cluster

### 5. New Doors Created (7 total)
| Code | Title |
|------|-------|
| A22 | AI Memory Antipattern |
| A23 | AI Augmentation Principle |
| A24 | Memory Science for Systems |
| A25 | LOD Knowledge System |
| T22 | Simulation Scaling Argument |

**Total doors: 539**

## Key Philosophies Established

### AI Augmentation Principle (A23)
- AI should augment human weaknesses, not replicate them
- Humans already have chaotic associative memory - don't build more of it
- AI fills gaps: structured where chaotic, consistent where variable

### LOD Knowledge System (A25)
- Same knowledge at 3 resolutions (g1/g2/g3)
- AI self-selects based on context budget and query scope
- Like WoW: full-poly close, low-poly distant
- "You don't render full-poly trees 2km away"

### Scaling Philosophy (T22)
- "If it doesn't scale, it's not worth anything"
- Deniers think linearly about exponential problems
- 2050 at 1% projection still = lifelike VR
- "640KB ought to be enough" energy

## Technical Innovations

### PhiSHRI 2.0 Architecture Concepts
1. **Granularity tiers** - g1/g2/g3 per drawer
2. **Branch pruning** - load only relevant sections
3. **Progressive loading** - start g1, escalate on demand
4. **Query-filtered retrieval** - `get_door(code, granularity, query)`
5. **Mixed resolution** - g3 focus, g1 background

### Memory Science Insights
- 5 memory systems: working, episodic, semantic, procedural, perceptual
- Method of loci = spatial metaphors (semantic_path IS this)
- Chunking = 7 chunks not 7 items
- Spreading activation = related_doors field
- Forgetting is a feature, not a bug

## Files Created/Modified

### New Doors (local)
- `PhiSHRI/CONTEXTS/ARCHITECTURE/A22AI_MEMORY_ANTIPATTERN.json`
- `PhiSHRI/CONTEXTS/ARCHITECTURE/A23AI_AUGMENTATION_PRINCIPLE.json`
- `PhiSHRI/CONTEXTS/ARCHITECTURE/A24MEMORY_SCIENCE_SYSTEMS.json`
- `PhiSHRI/CONTEXTS/ARCHITECTURE/A24MEMORY_SCIENCE_SYSTEMS_LOD.json` (prototype)
- `PhiSHRI/CONTEXTS/ARCHITECTURE/A25LOD_KNOWLEDGE_SYSTEM.json`
- `PhiSHRI/CONTEXTS/THEORY/T22SIMULATION_SCALING_ARGUMENT.json`

### Modified (local)
- `/home/stryker/Desktop/styles.css` - landing page refinements

## Competitor Analysis

### randall-gross/claude-memory-mcp
- Wraps Anthropic's official memory server
- Just installation scripts for someone else's code
- Flat entity/relation pairs, no structure
- Random memory storage = chaos
- **PhiSHRI is curated library, his is junk drawer**

## Quotable Wisdom

- "Random = Chaotic - stay far from this at current AI timeline"
- "The most human part of memory is the least useful part"
- "AI augments what we lack, not what we already have"
- "You don't render full-poly trees 2km away"
- "LOD for knowledge - same data at different resolutions"
- "If it doesn't scale, it's not worth anything"
- "Simulation deniers imagine a giant 386 rendering the universe"
- "The universe doesn't render Orgrimmar while you're in Stormwind"
- "2050 home PC = entire Grok 3 training cluster"
- "Cut projections by 99% and you'd still have lifelike VR"

## User Preferences (Reinforced)
- No emojis
- Direct language, profanity captures concepts better
- Ship working code, polish later
- Scaling mindset - if it doesn't scale, skip it
- SNES-era optimization philosophy
- "Your nan should be able to use it"

## Next Session Priorities
1. Push new doors to git (review first)
2. Prototype LOD retrieval in MCP server
3. Convert more doors to g1/g2/g3 format
4. Test granularity selection logic
5. Pure door creation mode

## Background Process
Dev server running: `cd ~/PhiSHRI-local/gui && npm run dev` (port 1420)
