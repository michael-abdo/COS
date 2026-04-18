# Knowledge Systems Architecture

## Part 1: Building a Layered Knowledge Graph

### Core Idea

Build it as a layered note system, not as one giant graph.

Obsidian can handle this well if you treat markdown files as typed objects and links as typed edges by convention.

**Do not make one note per topic like "networking."**

Make one note per entity type:
- Component
- Failure archetype
- Failure instance
- Symptom
- Impact
- Mitigation

Then connect them with consistent fields.

That gives you a file-based knowledge graph.

---

## Folder Structure

Use top-level folders by ontology, not by domain:

```
00_Maps/
01_Components/
02_Failure_Archetypes/
03_Failure_Instances/
04_Symptoms/
05_Impacts/
06_Mitigations/
07_Runbooks/
08_Postmortems/
09_Views/
```

Why this works:
- Folders encode what kind of thing
- Tags/properties encode where it lives and how it behaves

Example:
- "DNS" goes in Components
- "Staleness" goes in Failure_Archetypes
- "Stale DNS cache after deploy" goes in Failure_Instances

---

## Each File Needs Frontmatter

That gives you structure.

### Component Template

```yaml
---
type: component
name: DNS Cache
layer: networking
domain: service_discovery
scale: host
depends_on:
  - "[[Authoritative DNS]]"
failure_archetypes:
  - "[[Staleness]]"
  - "[[Misconfiguration]]"
  - "[[Exhaustion]]"
tags:
  - component
  - networking
---
```

### Failure Archetype Template

```yaml
---
type: failure_archetype
name: Staleness
class: temporal_inconsistency
applies_to_layers:
  - networking
  - storage
  - distributed_systems
  - deployment
common_components:
  - "[[DNS Cache]]"
  - "[[Replica]]"
  - "[[Configuration Cache]]"
common_symptoms:
  - "[[Intermittent Wrong Endpoint]]"
  - "[[Stale Reads]]"
common_mitigations:
  - "[[Reduce TTL]]"
  - "[[Force Refresh]]"
tags:
  - failure-archetype
  - time
---
```

### Symptom Template

```yaml
---
type: symptom
name: Intermittent Wrong Endpoint
observable_in:
  - logs
  - client_errors
  - traces
possible_failure_archetypes:
  - "[[Staleness]]"
  - "[[Misconfiguration]]"
possible_components:
  - "[[DNS Cache]]"
  - "[[Load Balancer]]"
  - "[[Service Discovery]]"
tags:
  - symptom
---
```

### Mitigation Template

```yaml
---
type: mitigation
name: Force Refresh
targets:
  - "[[Staleness]]"
tradeoffs:
  - "[[Increased Upstream Load]]"
speed: fast
risk: low
tags:
  - mitigation
---
```

---

## Separate Archetype from Instance

This matters most.

You do not want only generic notes like "timeout."

You also need concrete notes like:
- 2026-04-17 stale DNS cache after deploy

### Failure Archetype

Reusable abstract pattern:
- Timeout
- Staleness
- Saturation
- Partition
- Corruption

### Failure Instance

Specific real-world event:
- Stale DNS cache after region cutover
- Disk saturation during Ceph rebalance
- Retry storm after vendor timeout spike

That gives you both:
- Theory
- Memory

This mirrors how real engineers learn.

---

## Use Domains as Tags, Not Folders

Do not make folders like:
- Networking
- Storage
- Linux

That duplicates ontology.

Instead use tags or frontmatter:
```
layer: networking
domain: dns
```

This lets one archetype span multiple domains.

Example: [[Staleness]] applies to:
- DNS
- Caches
- Replicas
- Config rollout

That cross-domain reuse matters.

---

## Build "Map Notes" for Views

This is where Obsidian becomes useful.

Keep atomic notes in the ontology folders, then create human-readable map notes in 00_Maps/.

Examples:
```
00_Maps/
  Networking Failure Map.md
  Storage Failure Map.md
  Linux Runtime Map.md
  Databento Role Map.md
  Timeout Across The Stack.md
```

A map note might look like:

```
# Networking Failure Map

## Components
- [[DNS Cache]]
- [[Load Balancer]]
- [[Socket]]
- [[Router]]

## Failure Archetypes
- [[Staleness]]
- [[Packet Loss]]
- [[Partition]]
- [[Misconfiguration]]

## Symptoms
- [[Intermittent Wrong Endpoint]]
- [[Timeouts]]
- [[Connection Reset]]

## Mitigations
- [[Reduce TTL]]
- [[Fail Over]]
- [[Add Backoff]]
```

These notes become curated views, not source of truth.

---

## Represent Edges by Explicit Sections

Markdown lacks native typed edges, so fake them with consistent headings.

Every note should contain sections like:
- Depends on
- Common failure archetypes
- Appears as
- Impacts
- Mitigations
- Tradeoffs
- Leaks into
- First checks

That gives you semantic consistency.

Example:

```
## Appears as
- [[Timeouts]]
- [[Partial Outage]]

## Impacts
- [[Customer Request Failure]]
- [[Revenue Delay]]

## Mitigations
- [[Retry With Backoff]]
- [[Fail Over]]

## Tradeoffs
- [[Retry Storm]]
```

Now links become typed by section.

---

## Use Naming Rules

Keep names predictable.

**Good:**
- DNS Cache
- Staleness
- Intermittent Wrong Endpoint
- Retry Storm
- Force Refresh

**Bad:**
- Some notes on DNS
- Thoughts on stale stuff
- Network problems

Short, noun-like names make the graph cleaner.

For instances, use:
- 2026-04-17 - Stale DNS Cache After Deploy

That sorts chronologically.

---

## Minimal Schema

If you want this to stay usable, keep only these required fields:

```
type:
layer:
tags:
```

Then add optional fields by type.

Do not over-engineer frontmatter too early.

Because if updating notes feels heavy, you will stop using it.

---

## Practical Workflow

### While Learning

Create:
- One component note
- One archetype note
- One symptom note
- One mitigation note

Then link them.

### While Debugging

Create:
- One failure instance note
- One postmortem note
- Update the generic archetype if you learned something reusable

### While Reviewing

Create or refine:
- Map notes
- Runbooks

That creates a living system.

---

## Suggested Note Relationships

Here is the clean chain:

```
Component → common failure archetypes
Failure archetype → common symptoms
Symptom → possible impacts
Mitigation → targets failure archetypes
Failure instance → links one component + one archetype + many symptoms + one impact + chosen mitigations
Postmortem → links to failure instance + lessons
Runbook → links symptoms to first checks and mitigations
```

That structure fits both theory and operations.

---

## The Most Useful Extra File Type: Runbooks

Runbooks bridge knowledge and action.

Example:

```yaml
---
type: runbook
trigger_symptom:
  - "[[Timeouts]]"
layer: networking
---

# Runbook - Timeouts

## First Checks
- Is DNS resolving correctly?
- Is service listening on target port?
- Is packet loss visible?
- Are retries spiking?
- Did a deploy just happen?

## Likely Failure Archetypes
- [[Staleness]]
- [[Partition]]
- [[Saturation]]
- [[Misconfiguration]]

## Fast Mitigations
- [[Fail Over]]
- [[Reduce Load]]
- [[Rollback Deploy]]
```

This turns your vault into an operational brain, not just a wiki.

---

## If You Want Graph View to Remain Readable

Do not graph the whole vault.

Instead:
- Graph one folder
- Graph one map note neighborhood
- Graph one domain tag

Otherwise it becomes spaghetti.

The markdown system should store truth.

The graph view should act as a temporary lens.

---

## Simplest Version to Start Today

Create just these 6 files:

```
01_Components/DNS Cache.md
02_Failure_Archetypes/Staleness.md
04_Symptoms/Intermittent Wrong Endpoint.md
05_Impacts/Partial Outage.md
06_Mitigations/Force Refresh.md
03_Failure_Instances/2026-04-17 - Stale DNS Cache After Deploy.md
```

Then wire them together.

If that feels good, scale the pattern.

---

## Mental Model for Obsidian

Obsidian should not try to be the system itself.

It should be:
- Knowledge graph
- Case library
- Runbook library
- Pattern memory

So the file system stores:
- Stable abstractions
- Recurring failure patterns
- Concrete incidents
- Interventions

That matches the way senior engineers think.

---

## Part 2: Constraining LLM Writes

### The Core Problem

Use strict schemas, controlled vocabularies, and write boundaries.

If you let the LLM "freely edit notes," drift will happen fast.

**The goal should not be "make the model smart enough to stay consistent."**

**The goal should be: make inconsistency hard to express.**

---

## Separate What the Model May Write

Do not give the model equal write access to everything.

Split notes into three classes:

### A. Canonical Notes

Stable ontology:
- Components
- Failure archetypes
- Symptoms
- Impacts
- Mitigations

The LLM should rarely create or rename these automatically.

### B. Event Notes

High-churn notes:
- Failure instances
- Postmortems
- Runbook drafts

The LLM can write these more freely.

### C. Derived Notes

Generated views:
- Map notes
- Summaries
- Study guides

The LLM can regenerate these anytime.

That alone prevents most chaos.

---

## Give Every Note a Stable ID

Do not rely on title alone.

Use frontmatter like:

```yaml
id: comp_dns_cache
type: component
name: DNS Cache
version: 1
status: canonical
```

Then links can reference:
- ID
- Canonical title
- Aliases

Titles may drift. IDs should not.

If the LLM wants to mention "DNS cache," it should map to `comp_dns_cache`, not invent:
- DNS caching
- Local DNS cache
- Resolver cache
- Host DNS

All of those should become aliases or synonyms, not new nodes.

---

## Use Controlled Vocabularies

This matters most.

Fields like `type`, `layer`, `status`, `edge_type` should come from fixed enums.

Example:

```
type: component | failure_archetype | failure_instance | symptom | impact | mitigation | runbook | postmortem

layer: compute | os | networking | storage | distributed_systems | deployment | observability | application

status: draft | reviewed | canonical | deprecated

relation_type: causes | appears_as | worsens | hides | mitigates | leaks_into | depends_on
```

Do not let the LLM invent:
- "Sort of causes"
- "Kind of looks like"
- "Associated with"

Natural language should live in body text.

Structure should stay constrained.

---

## Keep a Central Registry

Have one machine-readable file:

```yaml
components:
  - id: comp_dns_cache
    title: DNS Cache
  - id: comp_load_balancer
    title: Load Balancer

failure_archetypes:
  - id: fa_staleness
    title: Staleness
  - id: fa_saturation
    title: Saturation
```

The LLM should read this before writing.

When it wants to create a link, it must first check:
- Does this node already exist?
- Is there already a synonym?
- Is this actually a new concept?

This registry becomes the source of truth.

---

## Enforce Templates Per Note Type

Every type should have:
- Required fields
- Optional fields
- Forbidden fields

Example:

**Component:**
Required:
- id
- type
- name
- layer
- status

**Failure Instance:**
Required:
- id
- type
- date
- component_refs
- archetype_refs
- symptom_refs
- impact_refs
- mitigation_refs
- status

The LLM should fill the template, not improvise the schema.

---

## Distinguish Extraction from Inference

This is huge.

Every LLM-written statement should implicitly belong to one of three classes:
- **Observed:** Directly supported by source material
- **Inferred:** Reasoned from evidence
- **Proposed:** Suggested but unconfirmed

Represent this explicitly.

Example:

```yaml
evidence_status: observed
confidence: high
source_refs:
  - log_2026_04_17_01
```

Or in the body:

```
## Observed
- Requests resolved to old IP on hosts A and B.

## Inferred
- Likely stale DNS cache on those hosts.

## Proposed Mitigation
- Lower TTL and add consistency check.
```

If you do not separate these, the LLM will blur fact and explanation.

---

## Use Append-Only Intake, Then Normalization

Best pattern:

### Step 1: Raw Capture

The LLM writes to an inbox note or JSON record:
- Raw facts
- Candidate links
- Candidate new nodes

### Step 2: Normalization

A second pass:
- Resolves names to canonical IDs
- Validates allowed fields
- Flags duplicates
- Converts free text into structured links

### Step 3: Promotion

Only then does content enter canonical folders.

This gives you a buffer between generation and truth.

---

## Make Node Creation Expensive

Most inconsistency comes from duplicate node creation.

Require the LLM to pass a decision gate:

Before creating a new canonical node, it must answer:

1. What existing nodes did you compare against?
2. Why does none match?
3. Is this a synonym, subtype, or truly new concept?
4. What layer and type does it belong to?

You can even store this:

```yaml
creation_justification:
  checked_against:
    - comp_dns_cache
    - comp_authoritative_dns
  reason_new: "This refers specifically to host-local resolver cache behavior."
```

That slows ontology sprawl.

---

## Version Canonical Notes

Canonical notes should not silently change.

Use fields like:

```yaml
version: 3
last_reviewed: 2026-04-17
change_type: clarification
```

And maintain a changelog section.

Then if the LLM updates a definition, you can inspect:
- What changed
- Whether ontology drift occurred
- Whether links need updating

---

## Separate Links from Prose

Do not depend only on wikilinks embedded in paragraphs.

Keep a structured relation block:

```yaml
relations:
  - type: depends_on
    target: comp_authoritative_dns
  - type: mitigated_by
    target: mit_force_refresh
  - type: appears_as
    target: sym_intermittent_wrong_endpoint
```

Then prose can stay human-readable, while structure stays machine-safe.

This makes LLM writes much more consistent.

---

## Add Validators

You want automatic checks after every write.

Validator rules:
- Required frontmatter exists
- Type matches folder
- All referenced IDs exist
- No forbidden fields
- No duplicate titles or aliases
- Relation types come from allowed enum
- Canonical notes cannot be edited without review flag
- Note title matches name

This can run as:
- Local script
- Git pre-commit hook
- CI job
- Obsidian plugin script

Without validation, consistency will decay.

---

## Use Confidence and Review Queues

Do not pretend every write deserves equal trust.

Add:

```yaml
llm_confidence: 0.72
review_status: pending_review
```

Then route notes:
- High confidence + non-canonical → auto-accept
- Low confidence → review queue
- Canonical modifications → always review

The LLM should not get a single trust level.

---

## Keep Ontology Notes Mostly Human-Owned

Best division:

**Human-owned:**
- Component definitions
- Archetype definitions
- Official symptom taxonomy
- Impact taxonomy
- Relation vocabulary

**LLM-assisted:**
- Incident extraction
- Postmortem draft generation
- Runbook draft updates
- Candidate link suggestions
- Duplicate detection

That gives you leverage without surrendering structure.

---

## Use Aliases Aggressively

People and models use inconsistent words.

For every canonical note, include:

```yaml
aliases:
  - local resolver cache
  - host DNS cache
  - DNS resolver cache
```

Then the LLM can map language variation to one object.

This reduces duplicate node explosion.

---

## Define Allowed Write Operations by Note Type

This helps a lot.

For example:

**Canonical Component Note:**

Allowed:
- Update aliases
- Add examples
- Propose new relations

Not allowed without review:
- Rename
- Change type
- Change layer
- Delete relation

**Failure Instance:**

Allowed:
- Append new evidence
- Add timestamps
- Add linked symptoms
- Add mitigation applied

This turns the system from "free text editing" into a bounded state machine.

---

## Use a Two-Model Pattern If Possible

One model writes. Another model checks.

**Writer:**
- Extracts structure
- Drafts notes
- Proposes links

**Critic:**
- Checks schema
- Checks duplication
- Checks unsupported inferences
- Checks canonical mapping

This works much better than one-pass generation.

---

## Represent Uncertainty Explicitly

The LLM will often know something partially.

Do not force premature certainty.

Use fields like:

```yaml
candidate_archetype_refs:
  - fa_staleness
  - fa_misconfiguration
primary_archetype_ref: fa_staleness
confidence: medium
```

Or in the body:

```
## Uncertainty

Possible causes:
- [[Staleness]]
- [[Misconfiguration]]

Current best fit:
- [[Staleness]]
```

This preserves consistency by preventing fake precision.

---

## Think in Terms of State Transitions

A note should move through states:
- Draft
- Normalized
- Reviewed
- Canonical
- Deprecated

The LLM may move notes from:
- Draft → Normalized

A human may move:
- Normalized → Reviewed → Canonical

That workflow matters more than perfect prompting.

---

## Best Practical Stack

If you want this to work in markdown/Obsidian:
- Markdown files with YAML frontmatter
- One registry.yaml for canonical IDs
- Templates for each note type
- A validation script in Python or Node
- Git version control
- Inbox folder for raw LLM output
- Review folder for flagged changes

That gives you:
- Human readability
- Machine structure
- Rollback
- Auditability

---

## Final Design Principle

To keep an LLM consistent, do not ask it to "maintain a knowledge base."

Ask it to perform one of these narrow actions:
- Classify this note into a type
- Resolve this phrase to a canonical ID
- Extract structured fields from this incident
- Suggest candidate relations
- Draft a postmortem from a failure instance
- Detect duplicates
- Validate schema conformance

**Narrow operations create consistency.**

**Open-ended authorship creates drift.**

---

## Best Compression

```
canonical ontology + strict templates + controlled vocabularies + validation + staged promotion
```

That will get you most of the way.

**The single most important rule:**

**LLM writes drafts, validators enforce structure, humans own ontology.**

---

## Shortest Summary

- The meta-schema handles structure.
- The domain pack handles language.
- The validator protects consistency.
- The LLM fills drafts and cases.
- The human governs ontology and promotion.
