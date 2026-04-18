Use strict schemas, controlled vocabularies, and write boundaries.

  

If you let the LLM “freely edit notes,” drift will happen fast.

  

The goal should not be “make the model smart enough to stay consistent.”

  

The goal should be:

make inconsistency hard to express.

  

  

1. Separate what the model may write

  

  

Do not give the model equal write access to everything.

  

Split notes into three classes:

  

  

A. Canonical notes

  

  

Stable ontology:

  

- components
- failure archetypes
- symptoms
- impacts
- mitigations

  

  

The LLM should rarely create or rename these automatically.

  

  

B. Event notes

  

  

High-churn notes:

  

- failure instances
- postmortems
- runbooks drafts

  

  

The LLM can write these more freely.

  

  

C. Derived notes

  

  

Generated views:

  

- map notes
- summaries
- study guides

  

  

The LLM can regenerate these anytime.

  

That alone prevents most chaos.

  

  

  

  

2. Give every note a stable ID

  

  

Do not rely on title alone.

  

Use frontmatter like:

id: comp_dns_cache

type: component

name: DNS Cache

version: 1

status: canonical

Then links can reference:

  

- id
- canonical title
- aliases

  

  

Titles may drift. IDs should not.

  

If the LLM wants to mention “DNS cache,” it should map to comp_dns_cache, not invent:

  

- DNS caching
- local DNS cache
- resolver cache
- host DNS

  

  

All of those should become aliases or synonyms, not new nodes.

  

  

  

  

3. Use controlled vocabularies

  

  

This matters most.

  

Fields like type, layer, status, edge_type should come from fixed enums.

  

Example:

type: component | failure_archetype | failure_instance | symptom | impact | mitigation | runbook | postmortem

layer: compute | os | networking | storage | distributed_systems | deployment | observability | application

status: draft | reviewed | canonical | deprecated

For relationships too:

relation_type: causes | appears_as | worsens | hides | mitigates | leaks_into | depends_on

Do not let the LLM invent:

  

- “sort of causes”
- “kind of looks like”
- “associated with”

  

  

Natural language should live in body text.

Structure should stay constrained.

  

  

  

  

4. Keep a central registry

  

  

Have one machine-readable file:

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

The LLM should read this before writing.

  

When it wants to create a link, it must first check:

  

- does this node already exist?
- is there already a synonym?
- is this actually a new concept?

  

  

This registry becomes the source of truth.

  

  

  

  

5. Enforce templates per note type

  

  

Every type should have:

  

- required fields
- optional fields
- forbidden fields

  

  

Example:

  

  

Component

  

  

Required:

  

- id
- type
- name
- layer
- status

  

  

  

Failure instance

  

  

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

  

  

  

  

6. Distinguish extraction from inference

  

  

This is huge.

  

Every LLM-written statement should implicitly belong to one of three classes:

  

- Observed: directly supported by source material
- Inferred: reasoned from evidence
- Proposed: suggested but unconfirmed

  

  

Represent this explicitly.

  

Example:

evidence_status: observed

confidence: high

source_refs:

  - log_2026_04_17_01

Or in the body:

## Observed

- Requests resolved to old IP on hosts A and B.

  

## Inferred

- Likely stale DNS cache on those hosts.

  

## Proposed mitigation

- Lower TTL and add consistency check.

If you do not separate these, the LLM will blur fact and explanation.

  

  

  

  

7. Use append-only intake, then normalization

  

  

Best pattern:

  

  

Step 1: raw capture

  

  

The LLM writes to an inbox note or JSON record:

  

- raw facts
- candidate links
- candidate new nodes

  

  

  

Step 2: normalization

  

  

A second pass:

  

- resolves names to canonical IDs
- validates allowed fields
- flags duplicates
- converts free text into structured links

  

  

  

Step 3: promotion

  

  

Only then does content enter canonical folders.

  

This gives you a buffer between generation and truth.

  

  

  

  

8. Make node creation expensive

  

  

Most inconsistency comes from duplicate node creation.

  

Require the LLM to pass a decision gate:

  

Before creating a new canonical node, it must answer:

  

1. What existing nodes did you compare against?
2. Why does none match?
3. Is this a synonym, subtype, or truly new concept?
4. What layer and type does it belong to?

  

  

You can even store this:

creation_justification:

  checked_against:

    - comp_dns_cache

    - comp_authoritative_dns

  reason_new: "This refers specifically to host-local resolver cache behavior."

That slows ontology sprawl.

  

  

  

  

9. Version canonical notes

  

  

Canonical notes should not silently change.

  

Use fields like:

version: 3

last_reviewed: 2026-04-17

change_type: clarification

And maintain a changelog section.

  

Then if the LLM updates a definition, you can inspect:

  

- what changed
- whether ontology drift occurred
- whether links need updating

  

  

  

  

  

10. Separate links from prose

  

  

Do not depend only on wikilinks embedded in paragraphs.

  

Keep a structured relation block:

relations:

  - type: depends_on

    target: comp_authoritative_dns

  - type: mitigated_by

    target: mit_force_refresh

  - type: appears_as

    target: sym_intermittent_wrong_endpoint

Then prose can stay human-readable, while structure stays machine-safe.

  

This makes LLM writes much more consistent.

  

  

  

  

11. Add validators

  

  

You want automatic checks after every write.

  

Validator rules:

  

- required frontmatter exists
- type matches folder
- all referenced IDs exist
- no forbidden fields
- no duplicate titles or aliases
- relation types come from allowed enum
- canonical notes cannot be edited without review flag
- note title matches name

  

  

This can run as:

  

- local script
- git pre-commit hook
- CI job
- Obsidian plugin script

  

  

Without validation, consistency will decay.

  

  

  

  

12. Use confidence and review queues

  

  

Do not pretend every write deserves equal trust.

  

Add:

llm_confidence: 0.72

review_status: pending_review

Then route notes:

  

- high confidence + non-canonical → auto-accept
- low confidence → review queue
- canonical modifications → always review

  

  

The LLM should not get a single trust level.

  

  

  

  

13. Keep ontology notes mostly human-owned

  

  

Best division:

  

  

Human-owned

  

  

- component definitions
- archetype definitions
- official symptom taxonomy
- impact taxonomy
- relation vocabulary

  

  

  

LLM-assisted

  

  

- incident extraction
- postmortem draft generation
- runbook draft updates
- candidate link suggestions
- duplicate detection

  

  

That gives you leverage without surrendering structure.

  

  

  

  

14. Use aliases aggressively

  

  

People and models use inconsistent words.

  

For every canonical note, include:

aliases:

  - local resolver cache

  - host DNS cache

  - DNS resolver cache

Then the LLM can map language variation to one object.

  

This reduces duplicate node explosion.

  

  

  

  

15. Define allowed write operations by note type

  

  

This helps a lot.

  

For example:

  

  

Canonical component note

  

  

Allowed:

  

- update aliases
- add examples
- propose new relations

  

  

Not allowed without review:

  

- rename
- change type
- change layer
- delete relation

  

  

  

Failure instance

  

  

Allowed:

  

- append new evidence
- add timestamps
- add linked symptoms
- add mitigation applied

  

  

This turns the system from “free text editing” into a bounded state machine.

  

  

  

  

16. Use a two-model pattern if possible

  

  

One model writes. Another model checks.

  

  

Writer

  

  

- extracts structure
- drafts notes
- proposes links

  

  

  

Critic

  

  

- checks schema
- checks duplication
- checks unsupported inferences
- checks canonical mapping

  

  

This works much better than one-pass generation.

  

  

  

  

17. Represent uncertainty explicitly

  

  

The LLM will often know something partially.

  

Do not force premature certainty.

  

Use fields like:

candidate_archetype_refs:

  - fa_staleness

  - fa_misconfiguration

primary_archetype_ref: fa_staleness

confidence: medium

or

## Uncertainty

Possible causes:

- [[Staleness]]

- [[Misconfiguration]]

  

Current best fit:

- [[Staleness]]

This preserves consistency by preventing fake precision.

  

  

  

  

18. Think in terms of state transitions

  

  

A note should move through states:

  

- draft
- normalized
- reviewed
- canonical
- deprecated

  

  

The LLM may move notes from:

  

- draft → normalized

  

  

A human may move:

  

- normalized → reviewed → canonical

  

  

That workflow matters more than perfect prompting.

  

  

  

  

19. Best practical stack

  

  

If you want this to work in markdown/Obsidian:

  

- markdown files with YAML frontmatter
- one registry.yaml for canonical IDs
- templates for each note type
- a validation script in Python or Node
- git version control
- inbox folder for raw LLM output
- review folder for flagged changes

  

  

That gives you:

  

- human readability
- machine structure
- rollback
- auditability

  

  

  

  

  

20. Final design principle

  

  

To keep an LLM consistent, do not ask it to “maintain a knowledge base.”

  

Ask it to perform one of these narrow actions:

  

- classify this note into a type
- resolve this phrase to a canonical ID
- extract structured fields from this incident
- suggest candidate relations
- draft a postmortem from a failure instance
- detect duplicates
- validate schema conformance

  

  

Narrow operations create consistency.

Open-ended authorship creates drift.

  

  

Best compression

  

  

Use this formula:

  

canonical ontology + strict templates + controlled vocabularies + validation + staged promotion

  

That will get you most of the way.

  

The single most important rule:

  

LLM writes drafts, validators enforce structure, humans own ontology.

  

I can draft the exact file schema and validator rules next.





The shortest summary:

  

- The meta-schema handles structure.
- The domain pack handles language.
- The validator protects consistency.
- The LLM fills drafts and cases.
- The human governs ontology and promotion.