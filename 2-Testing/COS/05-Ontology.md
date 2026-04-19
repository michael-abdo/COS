# Ontology: What Patterns Persist?

**Quick Answer:** Ontology names the primitives in your domain that persist across state changes—bounded objects you track, measure, and act on. Without explicit boundaries, you cannot distinguish one object from another or know when it fails.

## What Counts as Real?

**Summary:** Every system requires a named set of primitives. Traders track positions and fills; recruiters track candidates and requisitions; engineers track processes and sockets. Objects persist across state changes: a candidate remains "candidate" despite status changes (applied → screening → rejected). Naming is not decoration; it is prerequisite for measurement and control. Without explicit boundaries, you cannot distinguish objects or know when they fail. (58 words)

Objects are patterns that maintain coherence across time. The question: What deserves a name because it persists?

**Examples across domains:**

| Domain | Primitives | Persistence | Measurement |
|--------|-----------|-------------|-------------|
| **Systems** | process, thread, socket, disk, filesystem | Created, lives, dies; state changes but identity persists | CPU %, memory, file descriptors, I/O latency |
| **Recruiting** | candidate, requisition, application, engagement | Applied → screening → interview → offer; candidate persists through all states | pass rate, time-to-hire, interview-to-offer ratio |
| **Trading** | position, order, fill, market signal | Opened, amended, closed; position persists across multiple fills | position size, entry price, current P&L, margin ratio |
| **Consulting** | engagement, deliverable, client relation, risk item | Initiated → active → completed; engagement persists across work phases | billable hours, scope adherence, client satisfaction |

## Why This Matters

**For measurement:** You cannot measure what you don't name. A "process" that sometimes crashes and sometimes hangs is one object with two failure modes. A "candidate" in multiple states is one object with one identity.

**For control:** Risk gates and decisions operate on named objects. "Do not advance unqualified candidates" requires defining what "qualified" means at the object level.

**For feedback:** Learning loops depend on tracking objects over time. "This candidate succeeded" only makes sense if you track the same candidate object from application through six months post-hire.

## FAQ

**Q: How granular should ontology be?**
A: Granular enough to distinguish decision points. A "message" is too coarse if you need to distinguish "message received" from "message processed" from "message acked." Create named primitives for each state that requires a different action.

**Q: What if objects overlap?**
A: Overlap is fine. A "requisition" and an "engagement" can both reference the same candidate. Each captures a different aspect of persistence.

**Q: How do I know when an ontology is complete?**
A: When you can answer: "At any point in the workflow, I can name what object we're talking about and what state it's in." If you can't, you're missing a primitive.
