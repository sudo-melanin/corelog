# Features

The `features` directory contains CoreLog's business capabilities.

Each feature is self-contained and follows the same architectural structure:

```text
feature/
├── data/
├── domain/
└── presentation/
```

## Layers

### Data

Handles external data sources, persistence, models, and repository implementations.

### Domain

Contains business rules, entities, repository contracts, and use cases.

### Presentation

Contains screens, widgets, and state-management providers.

Current CoreLog features:

* Tasks
* Habits
* Notifications

Feature-specific code should remain inside its feature boundary.
