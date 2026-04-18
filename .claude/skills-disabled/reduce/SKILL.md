---
name: reduce
description: Dimensional reduction on any system or concept. Takes something complex with many parts and iteratively collapses it down to a single underlying variable, producing a snap-judgment decision tree.
user-invocable: true
---

# Reduce — Find the Single Axis

Take a system, concept, or set of features and reduce it to its single underlying variable through iterative dimensional collapse. The output is a binary decision tree the user can apply instantly.

`$ARGUMENTS` is the system or concept to reduce. If empty, ask the user what they want to understand.

## Process

Work through these phases WITH the user — each phase requires their input before moving on. Do not rush ahead. The user's pattern recognition is the engine; you're the facilitator.

### Phase 1: Enumerate the parts

1. List every component/feature/option in the system
2. For each, write one line: what it is and what it does
3. Present as a table to the user
4. Ask: "Is this complete? Anything missing?"

### Phase 2: Find the first pattern

1. Look across the parts — what do they have in common? How do they differ?
2. Propose a grouping or spectrum the parts seem to sit on
3. Present to the user and ask: "Does this grouping feel right?"

### Phase 3: Name the dimensions

1. For each group or axis identified, name what it measures
2. Present as a table: dimension name, what it measures, how it splits the parts
3. Ask: "What differentiates these dimensions from each other?"

### Phase 4: Collapse — the critical loop

This is where the reduction happens. Repeat until you cannot collapse further:

1. Take the current set of dimensions
2. Ask: "Are any of these measuring the same underlying thing?"
3. If yes — merge them, name the deeper variable they share
4. If no — challenge it: "If we had to explain all of these with ONE variable, what would it be?"
5. Present the collapsed model
6. Ask: "Is this simpler and still accurate?"

**Keep collapsing until the user agrees you've hit a single axis.**

### Phase 5: Build the decision tree

1. Take the single axis and the buckets (the original parts, now ordered on the axis)
2. Create binary yes/no questions that walk someone from the axis to the right bucket
3. First version: frame questions as cost analysis ("Is the risk worth X?")
4. Second version: rephrase each question as a snap judgment ("Can X handle this?")
5. Present both versions

### Phase 6: Produce artifacts

1. Save the final model as a markdown file with:
   - The single axis / underlying variable
   - The cost analysis tree (ASCII)
   - The snap judgment tree (ASCII)
   - A mapping table: original parts → position on axis → what it means
2. Create a Mermaid diagram (.mmd) of the snap judgment tree
3. Render to PNG and open for the user

## Rules

- **Never skip the user's input.** Each phase ends with a question. Wait for their answer. Their "aren't these the same thing?" moments are the breakthroughs.
- **Show your work visually.** Tables, ASCII trees, spectrums — never paragraphs of prose about the relationships.
- **Name things simply.** The final axis name should be something a non-expert would understand. If you need jargon to name it, you haven't reduced far enough.
- **The snap judgment questions must be answerable in under 3 seconds.** If a question requires thinking, rephrase it.
- **Challenge premature convergence.** If the user agrees too quickly, push back: "Are we sure these are the same, or just correlated?"
- **Challenge premature divergence.** If the user insists things are different, ask: "What specific scenario would give different answers for these two dimensions?"
