# Methodology: From Stakeholder to Execution

## Part 1: Project Design Through Transformation

### The Core Move

You're not mainly asking for "data."

You're asking for a **transformation set**:
- Expected input state
- Expected output state
- Examples of the mapping between them

That matters because Claude Code cannot optimize a wish.

It can only optimize a mapping.

---

## The Core Stakeholder Question

**Not:** What do you want?

**But:** When you hand the system X, what do you want it to return as Y?

And then: **show me 20, 50, 200 examples**

---

## Why Examples Matter

Examples do three things at once:

### 1. They Define the Boundary of the Entity

What actually counts as a valid input?

### 2. They Define the Transformation

What change should happen?

### 3. They Define the Evaluator

What would make you say "yes, this output is correct"?

---

## What You Really Want from the Stakeholder

For each transformation, extract:

### A. Input Object

What enters the system?

Examples:
- Raw prompt
- Codebase snapshot
- Support ticket
- Speech transcript
- Customer lead
- Image
- Page layout

### B. Output Object

What should come out?

Examples:
- Fixed code
- Classified ticket
- Extracted traits
- Improved landing page
- Rewritten copy
- Routed lead

### C. Transformation Rule

What property should change?

Examples:
- Less latency
- More clarity
- Correct classification
- Cleaner structure
- Better conversion
- Lower false positives

### D. Acceptance Criteria

What makes an output good enough?

Examples:
- Passes tests
- Matches gold label
- CTR improves
- Error drops
- Human reviewer approves
- No regressions

### E. Example Pairs

Concrete:
- Input example
- Desired output example
- Why that output is correct

That last part matters a lot.

Because the explanation often reveals the hidden scoring function.

---

## Best Stakeholder Template

Ask them for this, repeatedly:

**Transformation spec:**

- Input type: what comes in?
- Output type: what should come out?
- Goal of transformation: what should improve?
- Examples: give me as many input/output pairs as possible
- Edge cases: show me hard or ambiguous cases
- Failure examples: show me bad outputs
- Acceptance rule: how would you judge correctness?
- Non-goals: what should the system never do?

That gives you the transformation set.

---

## The Most Important Distinction

You do not just want:
- Examples of inputs
- Examples of outputs

You want:
- **Paired mappings**

Because otherwise you don't know which output belongs to which input.

So the real unit becomes:

```
(input, desired_output, rationale, acceptance_rule)
```

That is the atomic transformation record.

---

## Contrastive Examples Are Even Better

Stakeholders often reveal more by comparison than by definition.

Ask:
- For this input, what would be a **great** output?
- What would be an **acceptable** output?
- What would be a **bad** output?
- What would be an **unacceptable** output?

That gives you gradient, not just binary correctness.

Very important for vague domains.

---

## Why This Matters for the Closed Loop

Claude Code needs four things:

### 1. Current Input State

What are we transforming now?

### 2. Desired Output Pattern

What should it look like after?

### 3. Scoring Function

How close did we get?

### 4. Memory of Prior Attempts

What worked or failed before?

Your transformation set gives you 1 and 2 directly, and often gives you 3 implicitly.

---

## Practical Data Model

For each stakeholder example, store:

```
id:
transformation_id:
input_ref:
desired_output_ref:
rationale:
acceptance_criteria:
edge_case: false
confidence:
source: stakeholder
```

That becomes the core training / evaluation / iteration object.

---

## The Hidden Thing You're Extracting

What you are really trying to uncover is the stakeholder's:

**Latent function from state A to state B**

They may describe it badly in words, but examples expose it.

So your job becomes:
- Collect enough examples
- Detect the invariants
- Formalize the transformation
- Turn that into an evaluator
- Let Claude iterate against it

---

## The Best Practical Question to Ask

If you want one high-leverage stakeholder prompt, use this:

**"For as many cases as possible, show me what goes in, what should come out, and why that output is right."**

Then follow with:

**"Now show me cases where a naive system would get it wrong."**

That second question often matters more than the first.

---

## Prescriptive vs Descriptive

The full target becomes:
- Success should look clear
- Failure should look diagnosable
- Deployment should look bounded
- Progress should look legible

Your job involves **rejecting fake specs** and forcing reality into the conversation.

---

## Three Stages of Specification

### Stage 1: Fast Collection

"Give me as many examples as you can. Just label them good, bad, or ambiguous."

### Stage 2: System Inference

You and Claude extract:
- Candidate rules
- Edge cases
- Conflict patterns
- Missing dimensions

### Stage 3: Targeted Clarification

Go back with only:
- Contradictions
- Unclear cases
- High-impact gaps

---

## Final Compression: Transformational Focus

**Yes:** You should focus almost entirely on transformational sets.

More precisely:

You want a library of **input/output expectation pairs** that reveal the stakeholder's desired **state transition** and **implicit scoring logic**.

That is the substrate for the closed feedback loop.

The strongest atomic unit is:

```
input → desired output → reason → acceptance rule
```

That gives you something Claude Code can actually optimize.

---

## Part 2: The Human Role in the Loop

### The Core Insight

The human's power comes from their ability to:
- Compress structure
- Retrieve the right pattern
- Stay at the right abstraction layer
- Resolve ambiguity under time pressure

Use the knowledge system and LLM to convert infinite structure into a small number of **decision-ready chunks**.

---

## The Closed Feedback System

Much of this is a closed feedback system because we use Claude Code to do the execution.

There's a general pipeline:
1. A stakeholder defines what the entity and state should be
2. You and Claude Code define the infinitely queriable dataset needed to create a feedback loop
3. That loop creates the entity

So it's up to you as a designer to:
- Understand the system being created
- Understand the transformations being requested
- Define the before and after data sets
- Use those to create a closed feedback loop to infinitely iterate
- Ensure you have a system that reliably creates that transformation

---

## The Three Roles

### Your Job

Convert requested transformation into a measurable control loop.

### Claude Code's Job

Execute candidate actions inside that loop.

### The Knowledge System's Job

Store the causal memory so each iteration improves.

---

## What Makes a Good Control Loop

The loop must have:

1. **Clear input state** - What you're starting with
2. **Clear output specification** - What you want to end up with
3. **Measurable feedback** - How you know you're progressing
4. **Iteration capacity** - The ability to try multiple approaches
5. **Memory** - Learning from what worked and didn't

---

## Why Transformation Sets Work

Because they:
- Ground stakeholder wishes in concrete examples
- Expose implicit scoring functions
- Make "done" unambiguous
- Give Claude Code something to optimize toward
- Create a testable hypothesis

---

## The Deepest Job

Your real job is not to "manage a project."

Your real job is to:
- Extract the stakeholder's hidden transformation function
- Encode it in a way Claude Code can iterate against
- Build feedback that validates progress
- Store learning so the system improves over time

That is systems design.
