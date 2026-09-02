# Core Architecture

The `core` layer contains functionality shared across CoreLog features.

Core functionality should remain independent of specific application features. Feature-specific business logic belongs inside the relevant feature module.

## Structure

The core layer is organised by responsibility:

    core/
    ├── constants/
    ├── database/
    ├── error/
    ├── routing/
    ├── theme/
    ├── utils/
    └── widgets/

Not every directory needs to contain files immediately. Directories are introduced as their functionality becomes necessary.

## Barrel Exports

CoreLog uses barrel files to expose related modules through a single import.

A barrel represents the public API of its module and should only export members intended for use outside that module.

For example:

    core/
    ├── core.dart
    └── error/
        ├── error.dart
        ├── exceptions.dart
        └── failures.dart

The error barrel exposes the error module:

    export 'exceptions.dart';
    export 'failures.dart';

The core barrel exposes the core modules:

    export 'error/error.dart';

Consumers can therefore import the core API through:

    import 'package:corelog/core/core.dart';

## Barrel Conventions

- Barrels are created at agreed module boundaries.
- Each module may expose its public API through its own barrel.
- Internal implementation details should not be exported unnecessarily.
- Features maintain their own boundaries.
- Feature modules should not be combined into one global export-everything barrel.
- Circular dependencies between modules must be avoided.
- Barrel files should simplify imports without hiding architectural boundaries.
- Relative exports are used within a barrel when referencing files in the same module.

## Import Convention

Application code should use package imports when importing modules across architectural boundaries:

    import 'package:corelog/core/core.dart';

Within a module's barrel, relative exports are preferred:

    export 'exceptions.dart';
    export 'failures.dart';

This keeps module internals organised while giving consumers a stable public entry point.

## Architecture Boundary

Core provides shared infrastructure and utilities to the application.

Features should depend on core functionality where necessary, but core should not depend on individual features.

The dependency direction is therefore:

    Features → Core

rather than:

    Core → Features

This helps prevent circular dependencies and keeps the architecture maintainable as CoreLog grows.