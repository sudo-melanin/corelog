# CoreLog

CoreLog is an offline-first personal task and habit management application designed around structured daily routines, time blocks, and measurable progress.

The goal is to make planning and logging daily activities simple while providing a clear view of what was planned versus what was actually completed.

## Core Features

* Task creation and management
* Project and category organisation
* Recurring habits and streak tracking
* Time-blocked daily routines
* Planned versus actual activity tracking
* Weekly progress and rhythm visualisation
* Local notifications
* Offline-first operation

## Technology

* Flutter
* Dart
* Riverpod
* GoRouter
* Drift / SQLite
* fpdart
* flutter_local_notifications
* GitHub Actions

CoreLog v1 targets Android and does not require authentication, cloud storage, or multi-device synchronisation.

## Architecture

CoreLog follows a feature-first Clean Architecture approach.

```text
lib/
├── core/
│   ├── constants/
│   ├── database/
│   ├── error/
│   ├── routing/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── tasks/
│   ├── habits/
│   └── notifications/
│
└── main.dart
```

The main architectural layers are:

```text
presentation → domain → data
```

Shared application infrastructure belongs in `core`, while feature-specific functionality remains inside its respective feature.

## Error Handling

CoreLog uses `fpdart` and `Either<Failure, T>` for operations that may fail.

Infrastructure exceptions are translated into domain-friendly failures at the appropriate architectural boundary.

```text
Exception
    ↓
Failure
    ↓
Either<Failure, T>
```

## Development

Ensure Flutter is installed and available on your PATH.

Check the installed environment:

```bash
flutter doctor
```

Fetch dependencies:

```bash
flutter pub get
```

Format the project:

```bash
dart format lib test
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Git Workflow

CoreLog uses milestone-based development.

```text
main
  ↑
  │ Pull Request
dev
  ↑
  │ Pull Request
feature/milestone-X-name
```

Milestone branches contain the work for their respective milestone. Issues are used to track individual work items within the milestone.

Changes are developed on the milestone branch and integrated into `dev` through a pull request.

The `main` branch represents the stable application state.

## Continuous Integration

GitHub Actions automatically validates pull requests targeting `dev`.

The CI workflow:

1. Checks out the repository
2. Sets up the controlled Flutter SDK version
3. Restores dependencies
4. Runs `flutter analyze`
5. Runs `flutter test`

Pull requests must pass these checks before integration.

## Project Status

CoreLog is currently in the initial project foundation phase.

The current milestone establishes the architecture, dependencies, design system, static analysis, and continuous integration foundation required for feature development.
