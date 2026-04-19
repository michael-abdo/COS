# CREATE Manager

**Quick Answer:** The CREATE Manager governs all object instantiation (entities, work items, relationships). It enforces RBAC rules, validates required fields, and reports version on load.

## Version Reporting

**Summary:** On startup, the CREATE Manager reads the global COS VERSION file and reports it to the user. This enables version awareness across all domains and synchronizes the manager state with the system baseline. If VERSION file is missing, manager exits with error. (49 words)

When loaded, the CREATE Manager must report: `Using CREATE Manager v[VERSION]` where VERSION is read from `/COS/VERSION`.

If VERSION file cannot be found or read, the manager must exit with an error and report the missing file path.

**Behavior:**
- Read `/COS/VERSION` at manager startup
- Extract version string (e.g., "1.0", "1.1")
- Display to user: "Using CREATE Manager v1.0"
- All creation operations log this version
- If VERSION missing: exit with "ERROR: VERSION file not found"

---

## RBAC (Role-Based Access Control)

**Summary:** All CREATE operations enforce role-based access control. Roles define which entity types a user can create and under what constraints. Roles inherit permissions hierarchically. If a user lacks permission for an entity type, the operation is rejected. (43 words)

### Role Permission Model

| Role | Entities | Constraint |
|------|----------|-----------|
| **admin** | All | No constraints |
| **manager** | Work, Relationship, Status | Cannot create Users |
| **contributor** | Work | Can only create under own project |
| **viewer** | None | Read-only, cannot create |

### Permission Checking

All CREATE operations must:
1. Identify the caller's role
2. Check if role permits the entity type
3. Check if constraints allow this specific instance
4. Reject with clear error if permission denied
5. Log the attempt (success or failure)

---

## Validation Rules

**Summary:** All created entities must pass validation before being written. Required fields, type constraints, and reference integrity are checked. Invalid data is rejected with specific error messages. No partial creates are allowed. (37 words)

### Required Fields

All entities must include:
- `id` (unique identifier, auto-generated if not provided)
- `created_by` (caller's user ID or email)
- `created_at` (ISO 8601 timestamp, auto-set)
- `type` (entity type, e.g., "candidate", "position")

### Type Validation

| Type | Required | Optional |
|------|----------|----------|
| User | name, email, role | department, phone |
| Work | title, status, owner | tags, priority |
| Relationship | from_id, to_id, type | metadata |

### Integrity Checks

- **Reference validation:** If creating a Work with `owner_id`, verify that user exists
- **Uniqueness:** If a field is marked unique, check for duplicates
- **Constraint satisfaction:** Check domain-specific constraints (e.g., email format)
- **State validity:** New entities must have valid initial state

---

## Operation Flow

**Summary:** CREATE operations follow a five-step flow: parse → authorize → validate → write → confirm. If any step fails, operation stops and user is informed. Failures do not leave partial state. (32 words)

1. **Parse** — Extract and normalize input
2. **Authorize** — Check RBAC rules for caller and entity type
3. **Validate** — Check required fields, types, constraints
4. **Write** — Commit to database (atomic)
5. **Confirm** — Report success with created entity ID and version

---

## Error Handling

**Summary:** CREATE operations fail explicitly. No partial creates. Errors include: insufficient permissions, missing required field, invalid type, duplicate key, constraint violation, invalid reference. User receives specific error code and message. (32 words)

### Error Codes

| Code | Reason | Action |
|------|--------|--------|
| `ERR_PERMISSION_DENIED` | Caller lacks role permission | Check role and entity type |
| `ERR_INVALID_FIELD` | Missing or malformed required field | Provide all required fields |
| `ERR_DUPLICATE_KEY` | Unique field already exists | Use different value |
| `ERR_INVALID_REFERENCE` | Referenced entity does not exist | Verify entity ID exists |
| `ERR_CONSTRAINT_VIOLATION` | Domain constraint not met | Check domain rules |

---

## Logging & Audit

**Summary:** All CREATE operations are logged with caller, entity type, entity ID, success/failure, timestamp, and manager version. Logs enable audit trail and debugging. Logs live in git commits (audit log). (32 words)

- Every CREATE logs: caller, entity_type, entity_id, status, timestamp, version
- Failed CREATEs log the error code and reason
- Successful CREATEs log the entity ID for reference
- Version number from COS/VERSION is included in every log entry

---

## FAQ

**Q: What if VERSION file is out of sync across domains?**
A: Each domain reads the same COS/VERSION file (the single source of truth). Sync the base plugins with `./scripts/sync-base-plugins.sh` to ensure all domains have the same version.

**Q: Can a contributor create a Work for another user's project?**
A: No. Contributors can only create Work under their own project (enforced by constraint in RBAC).

**Q: What happens if I try to create an entity with a duplicate unique field?**
A: CREATE rejects the operation with `ERR_DUPLICATE_KEY` and reports the conflicting field. No partial create occurs.

**Q: How do I know which version of CREATE Manager I'm using?**
A: On startup, CREATE Manager prints: "Using CREATE Manager v[VERSION]". The version comes from COS/VERSION.

**Q: Can I override RBAC rules for emergencies?**
A: No. RBAC rules are hard constraints. Contact an admin to grant elevated permissions if needed.
