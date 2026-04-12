# AI Interaction Rules - Planzy

Follow these rules when modifying the Planzy project to ensure consistency and quality.

## Coding Standards
- **Feature-First**: Always place new logic in the appropriate `features/` folder.
- **Naming**: 
  - Domain models: `Name`
  - Isar models: `NameIsar` (to avoid naming collisions).
  - Repositories: `NameRepository`.
  - Providers: `nameProvider`.
- **State Management**: Use `AsyncNotifier` (Riverpod 2+) for any state that involves data fetching or persistence.
- **Colors**: Never use `Colors.xxx`. Always use `AppColors.xxx` from `core/theme/app_colors.dart`.
- **Widgets**: Prefer using `RoundedCard` for and `PlanzyButton` for UI consistency.

## Database (Isar)
- When adding a new field to a Freezed model, also add it to the corresponding `Isar` model and the repository mapper.
- Always run `flutter pub run build_runner build --delete-conflicting-outputs` after changing any models.

## Android Specifics
- **Namespace Fix**: Do not remove the dynamic namespace fix in `android/build.gradle.kts`. It is required for older plugins to work with modern AGP versions.
- **Impeller**: Keep Impeller disabled in `AndroidManifest.xml` to maintain compatibility with mid-range Samsung devices.

## Performance
- Ensure all images/icons use `LucideIcons` where possible.
- Avoid large widget trees in a single file; split them into small components.
