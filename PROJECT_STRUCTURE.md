# Project Structure - Planzy

This project follows a **Feature-First** and **Clean Architecture** approach to ensure scalability and maintainability.

## Directory Layout

```text
lib/
├── core/               # Shared logic, themes, and global widgets
│   ├── providers/      # Centralized Riverpod providers (e.g., Isar)
│   ├── router/         # GoRouter configuration and navigation logic
│   ├── theme/          # AppTheme and Color system
│   └── widgets/        # Universal UI components (RoundedCard, PlanzyButton)
├── data/               # Persistent storage logic
│   └── database/       # Isar schemas and initialization
├── features/           # Feature-based modular logic
│   ├── commitments/    # Managed expenses and payments
│   ├── goals/          # Savings goals and progress
│   ├── home/           # Dashboard and main overview
│   ├── insights/       # Financial analysis and charts
│   ├── timeline/       # Sequential view of commitments
│   └── profile/        # User settings and personal info
└── main.dart           # App entry point and provider initialization
```

## Layers within Features
Each feature folder generally contains:
- `data/`: Models and Repositories for that feature.
- `presentation/`: Riverpod providers (Notifiers).
- `view/`: UI screens and feature-specific widgets.
