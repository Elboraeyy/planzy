# Design System - Planzy

Planzy uses a **Gen-Z / Modern Minimalist** design aesthetic: rounded corners, soft shadows, and a warm, high-contrast color palette.

## Color Palette
- **Primary**: `#8B001B` (Deep Maroon) - Used for buttons and key actions.
- **Background**: `#FFFCEE` (Cream) - Warm, eye-friendly background.
- **Accent**: `#F4A261` (Peach/Orange) - Highlights and icons.
- **Card/Surface**: `#FFFFFF` (Pure White) - Floating elements with subtle elevation.
- **Text (Dark)**: `#1A1A1B` - High contrast for readability.
- **Text (Light)**: `#8E8E93` - For secondary information.

## Typography
- Uses standard Material 3 typography with a focus on **Bold Headers** for a confident "Planner" feel.
- Numbers typically use **Bold/ExtraBold** weights to emphasize financial amounts.

## Core Components
- **RoundedCard**: Standard container with 24dp radius and soft shadows (`core/widgets/rounded_card.dart`).
- **PlanzyButton**: Rounded primary button with consistent padding and Maroon color (`core/widgets/planzy_button.dart`).

## Animations
- Subtle haptics and smooth transitions are expected for a premium feel.
- High use of the `flutter_animate` library for micro-interactions (Upcoming).
