Yes. That’s the right center.

  

You’re not mainly asking for “data.”

  

You’re asking for a transformation set:

  

- expected input state
- expected output state
- examples of the mapping between them

  

  

That matters because Claude Code cannot optimize a wish.

It can only optimize a mapping.

  

  

The core stakeholder question

  

  

Not:

  

- what do you want?

  

  

But:

  

- when you hand the system X, what do you want it to return as Y?

  

  

And then:

  

- show me 20, 50, 200 examples

  

  

Because examples do three things at once:

  

  

1. They define the boundary of the entity

  

  

What actually counts as a valid input?

  

  

2. They define the transformation

  

  

What change should happen?

  

  

3. They define the evaluator

  

  

What would make you say “yes, this output is correct”?

  

So yes, your focus should sit heavily on:

  

input → output expectation pairs

  

  

  

  

What you really want from the stakeholder

  

  

For each transformation, extract:

  

  

A. Input object

  

  

What enters the system?

  

Examples:

  

- raw prompt
- codebase snapshot
- support ticket
- speech transcript
- customer lead
- image
- page layout

  

  

  

B. Output object

  

  

What should come out?

  

Examples:

  

- fixed code
- classified ticket
- extracted traits
- improved landing page
- rewritten copy
- routed lead

  

  

  

C. Transformation rule

  

  

What property should change?

  

Examples:

  

- less latency
- more clarity
- correct classification
- cleaner structure
- better conversion
- lower false positives

  

  

  

D. Acceptance criteria

  

  

What makes an output good enough?

  

Examples:

  

- passes tests
- matches gold label
- CTR improves
- error drops
- human reviewer approves
- no regressions

  

  

  

E. Example pairs

  

  

Concrete:

  

- input example
- desired output example
- why that output is correct

  

  

That last part matters a lot.

  

Because the explanation often reveals the hidden scoring function.

  

  

  

  

Best stakeholder template

  

  

Ask them for this, repeatedly:

  

  

Transformation spec

  

  

- Input type: what comes in?
- Output type: what should come out?
- Goal of transformation: what should improve?
- Examples: give me as many input/output pairs as possible
- Edge cases: show me hard or ambiguous cases
- Failure examples: show me bad outputs
- Acceptance rule: how would you judge correctness?
- Non-goals: what should the system never do?

  

  

That gives you the transformation set.

  

  

  

  

The most important distinction

  

  

You do not just want:

  

- examples of inputs
- examples of outputs

  

  

You want:

  

- paired mappings

  

  

Because otherwise you do not know which output belongs to which input.

  

So the real unit becomes:

(input, desired_output, rationale, acceptance_rule)

That is the atomic transformation record.

  

  

  

  

Even better: ask for contrastive examples

  

  

Stakeholders often reveal more by comparison than by definition.

  

Ask:

  

- for this input, what would be a great output?
- what would be an acceptable output?
- what would be a bad output?
- what would be an unacceptable output?

  

  

That gives you gradient, not just binary correctness.

  

Very important for vague domains.

  

  

  

  

Why this matters for the closed loop

  

  

Claude Code needs four things:

  

  

1. Current input state

  

  

What are we transforming now?

  

  

2. Desired output pattern

  

  

What should it look like after?

  

  

3. Scoring function

  

  

How close did we get?

  

  

4. Memory of prior attempts

  

  

What worked or failed before?

  

Your transformation set gives you 1 and 2 directly, and often gives you 3 implicitly.

  

  

  

  

Practical data model

  

  

For each stakeholder example, store:

id:

transformation_id:

input_ref:

desired_output_ref:

rationale:

acceptance_criteria:

edge_case: false

confidence:

source: stakeholder

That becomes the core training / evaluation / iteration object.

  

  

  

  

The hidden thing you’re extracting

  

  

What you are really trying to uncover is the stakeholder’s:

  

latent function from state A to state B

  

They may describe it badly in words, but examples expose it.

  

So your job becomes:

  

- collect enough examples
- detect the invariants
- formalize the transformation
- turn that into an evaluator
- let Claude iterate against it

  

  

  

  

  

The best practical question to ask

  

  

If you want one high-leverage stakeholder prompt, use this:

  

“For as many cases as possible, show me what goes in, what should come out, and why that output is right.”

  

Then follow with:

  

“Now show me cases where a naive system would get it wrong.”

  

That second question often matters more than the first.

  

  

  

  

Final compression

  

  

Yes:

you should focus almost entirely on transformational sets.

  

More precisely:

  

You want a library of input/output expectation pairs that reveal the stakeholder’s desired state transition and implicit scoring logic.

  

That is the substrate for the closed feedback loop.

  

The strongest atomic unit is:

  

input → desired output → reason → acceptance rule

  

That gives you something Claude Code can actually optimize.

  

We can keep going and design the exact stakeholder intake form for collecting these transformation sets.


Prescriptive versus descriptive. 


![[Pasted image 20260417043458.png]]




So the full target becomes:

  

- success should look clear
- failure should look diagnosable
- deployment should look bounded
- progress should look legible


Your job involves rejecting fake specs and forcing reality into the conversation.

![[Pasted image 20260417044705.png]]


  

Stage 1: Fast collection

  

  

“Give me as many examples as you can. Just label them good, bad, or ambiguous.”

  

  

Stage 2: System inference

  

  

You and Claude extract:

  

- candidate rules
- edge cases
- conflict patterns
- missing dimensions

  

  

  

Stage 3: Targeted clarification

  

  

Go back with only:

  

- contradictions
- unclear cases
- high-impact gaps