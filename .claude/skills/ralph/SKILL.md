---
name: ralph
description: "Convert PRDs to prd.json format for the Ralph autonomous agent system. Use when you have an existing PRD and need to convert it to Ralph's JSON format. Triggers on: convert this prd, turn this into ralph format, create prd.json from this, ralph json."
---

# Ralph PRD Converter

Converts existing PRDs to the prd.json format that Ralph uses for autonomous execution.

---

## The Job

Take a PRD (markdown file or text) and convert it to `prd.json` in your .ralph directory.

---

## Output Format

```json
{
    "project": "[Project Name]",
    "description": "[Feature description from PRD title/intro]",
    "userStories": [
      {
        "id": "US-001",
        "title": "[Story title]",
        "description": "As a [user], I want [feature] so that [benefit]",
        "acceptanceCriteria": [
          "Criterion 1",
          "Criterion 2",
          "Typecheck passes"
        ],
        "priority": 1,
        "passes": false,
        "inProgress": false,
        "checkpoint": false,
        "notes": ""
      }
    ]
}
```


---

## Story Size: The Number One Rule

**Each story must be completable in ONE Ralph iteration (one context window).**

Ralph spawns a fresh session per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):
- "Build the entire dashboard" - Split into: schema, queries, UI components, filters
- "Add authentication" - Split into: schema, middleware, login UI, session handling
- "Refactor the API" - Split into one story per endpoint or pattern

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

**Wrong order:**
1. UI component (depends on schema that does not exist yet)
2. Schema change

---

## Checkpoint Stories: Review Gates

Mark stories as `checkpoint: true` when you want Ralph to **pause for user review** after completing them.

### When to use checkpoints:

| Situation | Why checkpoint |
|-----------|----------------|
| After database/schema changes | User should verify migrations before UI work |
| After completing backend logic | User may want to test API before building UI |
| Before risky refactors | User approval before touching critical code |
| End of a logical phase | Natural review point (e.g., "Phase 1 complete") |
| After complex features | User should manually test before continuing |

### How checkpoints work:

1. Ralph completes the checkpoint story normally
2. Ralph provides a **summary of all work done so far**
3. Ralph **stops** - does NOT auto-continue to next story
4. User reviews, asks questions, requests small fixes (same session)
5. User clicks "Continue" when satisfied → fresh session starts next story

### Example with checkpoints:

```json
  {
    "userStories": [
      { "id": "US-001", "title": "Add status column to tasks", "checkpoint": false, ... },
      { "id": "US-002", "title": "Add status enum type", "checkpoint": true, ... },
      { "id": "US-003", "title": "Display status badge on cards", "checkpoint": false, ... },
      { "id": "US-004", "title": "Add status filter dropdown", "checkpoint": true, ... }
    ]
}
```

In this example:
- US-001 → US-002 runs automatically
- After US-002 (checkpoint): Ralph stops, user reviews schema changes
- User continues → US-003 → US-004 runs
- After US-004 (checkpoint): Ralph stops, user reviews complete UI

Guidelines:

- Don't overuse - every 3-5 stories is usually enough
- Always checkpoint after schema/migration stories
- Always checkpoint at the end of distinct phases
- Consider checkpoint before stories that touch critical/risky code

---

## Acceptance Criteria: Must Be Verifiable

Each criterion must be something Ralph can CHECK, not something vague.

### Good criteria (verifiable):
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"
- "Typecheck passes"
- "Tests pass"

### Bad criteria (vague):
- "Works correctly"
- "User can do X easily"
- "Good UX"
- "Handles edge cases"

### Always include as final criterion:
```
"Typecheck passes"
```

For stories with testable logic, also include:
```
"Tests pass"
```

### For stories that change UI, also include:
```
"Verify in browser using dev-browser skill"
```

Frontend stories are NOT complete until visually verified. Ralph will use the dev-browser skill to navigate to the page, interact with the UI, and confirm changes work.

---

## Conversion Rules

1. **Each user story becomes one JSON entry**
2. **IDs**: Sequential (US-001, US-002, etc.)
3. **Priority**: Based on dependency order, then document order
4. **All stories start with**: `passes: false`, `inProgress: false`, empty `notes`
5. **Add checkpoints**: After schema changes and at phase boundaries
6. **Always add**: "Typecheck passes" to every story's acceptance criteria

---

## Splitting Large PRDs

If a PRD has big features, split them:

**Original:**
> "Add user notification system"

**Split into:**
1. US-001: Add notifications table to database
2. US-002: Create notification service for sending notifications
3. US-003: Add notification bell icon to header
4. US-004: Create notification dropdown panel
5. US-005: Add mark-as-read functionality
6. US-006: Add notification preferences page

Each is one focused change that can be completed and verified independently.

---

## Example

**Input PRD:**
```markdown
# Task Status Feature

Add ability to mark tasks with different statuses.

## Requirements
- Toggle between pending/in-progress/done on task list
- Filter list by status
- Show status badge on each task
- Persist status in database
```

**Output prd.json:**
```json
  {
    "project": "TaskApp",
    "description": "Task Status Feature - Track task progress with status indicators",
    "userStories": [
      {
        "id": "US-001",
        "title": "Add status field to tasks table",
        "description": "As a developer, I need to store task status in the database.",
        "acceptanceCriteria": [
          "Add status column: 'pending' | 'in_progress' | 'done' (default 'pending')",
          "Generate and run migration successfully",
          "Typecheck passes"
        ],
        "priority": 1,
        "passes": false,
        "inProgress": false,
        "checkpoint": true,
        "notes": ""
      },
      {
        "id": "US-002",
        "title": "Display status badge on task cards",
        "description": "As a user, I want to see task status at a glance.",
        "acceptanceCriteria": [
          "Each task card shows colored status badge",
          "Badge colors: gray=pending, blue=in_progress, green=done",
          "Typecheck passes",
          "Verify in browser using dev-browser skill"
        ],
        "priority": 2,
        "passes": false,
        "inProgress": false,
        "checkpoint": false,
        "notes": ""
      },
      {
        "id": "US-003",
        "title": "Add status toggle to task list rows",
        "description": "As a user, I want to change task status directly from the list.",
        "acceptanceCriteria": [
          "Each row has status dropdown or toggle",
          "Changing status saves immediately",
          "UI updates without page refresh",
          "Typecheck passes",
          "Verify in browser using dev-browser skill"
        ],
        "priority": 3,
        "passes": false,
        "inProgress": false,
        "checkpoint": false,
        "notes": ""
      },
      {
        "id": "US-004",
        "title": "Filter tasks by status",
        "description": "As a user, I want to filter the list to see only certain statuses.",
        "acceptanceCriteria": [
          "Filter dropdown: All | Pending | In Progress | Done",
          "Filter persists in URL params",
          "Typecheck passes",
          "Verify in browser using dev-browser skill"
        ],
        "priority": 4,
        "passes": false,
        "inProgress": false,
        "checkpoint": true,
        "notes": ""
      }
    ]
  }
```
Note: US-001 (schema) and US-004 (final story) are checkpoints.

---

## Checklist Before Saving

Before writing prd.json, verify:

- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories are ordered by dependency (schema → backend → UI)
- [ ] Every story has "Typecheck passes" as criterion
- [ ] UI stories have "Verify in browser using dev-browser skill"
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No story depends on a later story
- [ ] **Checkpoints placed** after schema changes and at phase boundaries
- [ ] All stories have `passes: false` and `inProgress: false`