# CoreLog Productivity Model

## Product Direction

CoreLog is a personal activity and productivity tracker.

Its purpose is to help a user:

1. Plan what they intend to do.
2. Execute planned activities.
3. Record what actually happened.
4. Review their history.
5. Measure consistency and time usage.
6. Improve future planning.

The core loop is:

**PLAN → DO → RECORD → REVIEW → MEASURE → IMPROVE**

## Core Domain Model

### Activity

An Activity represents something the user wants to spend time doing.

Examples:

* Flutter Development
* Trading
* Fitness
* Reading
* Work
* Learning

Activity is the central identity used for measuring time, consistency, and progress.

### Habit

A Habit represents a recurring intention associated with an Activity.

A Habit can generate HabitOccurrences for specific dates.

Example:

> Fitness every Monday, Wednesday, and Friday at 7:00 AM.

### Task

A Task represents a specific piece of work associated with an Activity.

Example:

> Implement authentication flow.

Tasks are actionable work items. They are not the primary unit of productivity measurement.

### TimeBlock

A TimeBlock represents a planned allocation of time.

A TimeBlock is independent of HabitOccurrence.

It may optionally be associated with:

* an Activity
* a HabitOccurrence
* a Task

It may also exist as an ad-hoc block without any of these relationships.

Example:

> Flutter Development, 2:00 PM–4:00 PM.

### Execution

Execution represents what actually happened during a planned TimeBlock.

It captures the relationship between planned time and actual activity.

This allows CoreLog to measure:

* planned duration
* actual duration
* completed duration
* skipped duration
* time adherence

### Activity History

Activity History represents the user's recorded past activity.

History must remain useful even when current planning data changes.

It should allow CoreLog to answer questions such as:

* What did I do today?
* How much time did I spend on Flutter this week?
* Which activities have I been consistent with?
* How much planned time did I actually complete?
* Which habits did I complete or miss?

## Domain Relationships

```text
Activity
├── Habits
│   └── HabitOccurrences
├── Tasks
└── TimeBlocks

TimeBlock
├── optional Activity
├── optional HabitOccurrence
└── optional Task

TimeBlock
└── Execution
    └── Activity History

Activity History
├── Metrics
├── Streaks
└── Visualisations
```

## Product Principles

### 1. TimeBlocks are independent

A user must be able to create a TimeBlock without first creating a Habit or HabitOccurrence.

### 2. Activities are measurable

Activities provide the stable identity needed for productivity metrics and progress tracking.

### 3. Habits represent recurrence

Habits describe repeated intentions. They are not the same thing as scheduled time.

### 4. Tasks represent specific work

Tasks should support actionable work without becoming the entire productivity model.

### 5. History is first-class

Completed activity should remain accessible after it leaves the current planning view.

### 6. Planned and actual time are different

CoreLog should distinguish what the user intended to do from what actually happened.

### 7. Metrics come from persisted activity

Metrics, streaks, and visualisations should derive from recorded activity rather than maintain separate sources of truth.

### 8. Projects are no longer a core domain concept

The existing Project model will be deprecated as the productivity model is introduced.

Existing project-related code should only be removed or migrated when the relevant M6 issue addresses it.

## Task and Time Tracking Model

CoreLog uses Task as the primary unit of planned and tracked work.

A separate TimeBlock entity is not required for the MVP.

A Task may exist without a schedule or may optionally have a planned start and end time.

### Unscheduled Task

An unscheduled task can be completed directly or skipped.

```text
Pending
├── Complete
└── Skip
```

### Scheduled Task

A scheduled task has a planned start and end time.

Before it starts:

```text
Pending
├── Start
└── Skip
```

A scheduled task cannot be completed directly from the pending state. It must first be started so that actual execution can be recorded.

### In-Progress Task

Once started:

```text
In Progress
├── Pause
└── Complete
```

A started task cannot be skipped.

### Paused Task

A paused task can be resumed or completed:

```text
Paused
├── Resume
└── Complete
```

### Terminal States

Completed and skipped tasks have no further actions.

```text
Completed → no actions
Skipped   → no actions
```

## Time Tracking

Scheduled duration and actual duration are separate concepts.

For a scheduled task:

```text
Planned Duration = plannedEnd - plannedStart
```

Actual duration represents only active execution time.

For example:

```text
Start   14:05
Pause   14:45
Resume  15:00
Complete 15:50

Active execution:
40 minutes + 50 minutes = 90 minutes
```

Actual duration is finalized when the task is completed.

Pause and resume must not inflate actual execution time.

Execution history should preserve enough information to support accurate active-duration calculation.

## Skip Recording

Skipping a task is a recorded outcome, not deletion.

A skipped task records:

* skipped timestamp
* structured skip reason
* optional user note

Initial skip reasons:

* Not enough time
* Higher priority came up
* Lost focus
* Not feeling well
* No longer relevant
* Other

Skip reasons exist to support historical analysis and consistency insights.

## Action Safety

Actions that permanently change or significantly affect task history should use confirmation dialogs.

Examples include:

* Delete
* Skip
* Complete when it finalizes tracked work

The interface should not expose every possible action at every stage. Available actions must reflect the current task state.

The goal is to make the correct action obvious while reducing accidental state changes.

## Out of Scope for M6

M6 establishes the productivity model and its foundations.

The following remain outside the current milestone unless specifically required:

* Cloud synchronisation
* Authentication
* AI coaching
* Social features
* Complex productivity scoring
* Advanced notification intelligence
* Multi-device synchronisation

## Target Architecture

```text
                         ACTIVITY
                            │
             ┌──────────────┼──────────────┐
             │              │              │
           HABIT           TASK        DIRECT PLAN
             │              │              │
        Occurrence          │              │
             │              │              │
             └──────────────┼──────────────┘
                            ↓
                        TIME BLOCK
                            │
                     ┌──────┴──────┐
                     ↓             ↓
                  Planned       Executed
                                    │
                                    ↓
                              ACTIVITY HISTORY
                                    │
                      ┌─────────────┼─────────────┐
                      ↓             ↓             ↓
                   Metrics       Streaks       Visuals
```
