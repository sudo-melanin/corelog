# Core

The `core` layer contains application-wide infrastructure and shared components that are not specific to a single feature.

## Structure

* `constants/` - Application-wide constant values.
* `database/` - Shared local database infrastructure.
* `error/` - Shared exceptions, failures, and error-handling abstractions.
* `routing/` - Application navigation and routing configuration.
* `theme/` - Design tokens and application theme configuration.
* `utils/` - Reusable utilities that have no feature-specific responsibility.
* `widgets/` - Shared UI components used across multiple features.

Feature-specific logic should not be placed in `core/`.
