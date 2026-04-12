# Architecture - Planzy

Planzy is built with a focus on **Separation of Concerns** using modern Flutter best practices.

## Core Technologies
- **State Management**: [Riverpod](https://riverpod.dev) (specifically `AsyncNotifier` for handling data loading and persistence).
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) with `StatefulShellRoute` for efficient bottom navigation.
- **Local Database**: [Isar](https://isar.dev) for high-performance, NoSQL local storage.
- **Data Classes**: [Freezed](https://pub.dev/packages/freezed) for immutable models and pattern matching.

## Data Flow
1. **Models**: Domain models (Freezed) represent the app logic. Isar models map these to the database.
2. **Repositories**: Act as a bridge between the data source (Isar) and the application.
3. **Notifiers (Providers)**: Consume Repositories to expose data to the UI.
4. **Views**: ConsumerWidgets that watch Notifiers and rebuild when data changes.

## Persistence Note
- Initialized in `main.dart` via `isarServiceProvider`.
- Uses `getApplicationDocumentsDirectory` for cross-platform data safety.
- `IsarService` handles multiple schemas: `CommitmentIsar`, `GoalIsar`, and `UserSettingsIsar`.
