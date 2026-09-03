# 🎯 Planzy - Refined Neo-Brutalist Financial Planner

Planzy is a modern, premium personal finance and wealth management application built with Flutter. It stands out with a striking, custom-crafted **Refined Neo-Brutalist** (or Neo-Pop) design system that combines bold aesthetics with fluid user experiences. Powered by Riverpod and Firebase, Planzy allows users to take absolute control of their financial life.

---

## 🎨 Visual Identity & Design System

Planzy breaks away from generic, boring financial app designs. It utilizes a curated Neo-Brutalist interface featuring:
*   **Tactile Aged Paper Background** (`#FDFCF2`): A warm, premium eye-friendly background.
*   **Deep Maroon Primary Accent** (`#8B001B`): For high-contrast focal points, buttons, and brand identity.
*   **Acid Green Secondary Accent** (`#BDFF00`): Used for secondary elements, badges, and interactive feedback.
*   **Cyber Blue Accent** (`#00D1FF`): Used for visual variations.
*   **Thick Black Boundaries** (`#111111`, `3.r` width): To give widgets a physical, comic-book-inspired tactile card feeling.
*   **Offset Drop Shadows**: Elevating interactive elements on press and hover for a retro-tactile feel.
*   **Micro-animations**: Smooth entries, elastic scaling on button clicks, and tab transitions using `flutter_animate`.

---

## 🚀 Key Features

*   **🔒 Secured Authentication**: Sign-up and Login using Firebase Auth with profile synchronization.
*   **📱 Interactive Onboarding**: Animated onboarding slides highlighting control, goal-smashing, and budgeting.
*   **🏦 Multi-Account Management**: Track multiple financial accounts (Cash, Bank Accounts, E-Wallets, Prepaid Cards, Savings Accounts) with unique custom emojis and colors.
*   **💸 Transaction Ledger (Income/Expense/Transfer)**: Record transactions with categories, notes, account links, and camera/gallery receipt attachments stored securely on Firebase Storage.
*   **🔄 Instant Transfers**: Move funds between different accounts with automatic balance updates and optional transfer fee logging.
*   **🎯 Savings Goals (Vaults)**: Create visual savings goals, set priorities, linked accounts, target dates, and easily deposit or withdraw (refund) funds directly into your goals.
*   **🗓️ Subscription Tracker (Renewals & Alerts)**: Track active subscriptions (Netflix, Spotify, Cloud, etc.) with custom renewal cycle logs, upcoming renewal calendars, auto-deduct toggles, and push notification reminders.
*   **📊 Rich Insights & Analytics**: Visual interactive monthly breakdown charts (powered by `fl_chart`) comparing income vs. expenses and category distributions.
*   **⚙️ Custom Profile & Settings**: Adjust username, upload profile pictures, manage custom currency (default `EGP`), and toggle notification intervals.

---

## 🛠️ Technology Stack

Planzy is built using modern Flutter development best practices:

*   **Core Framework**: [Flutter SDK](https://flutter.dev) (Dart `^3.10.3`)
*   **State Management**: [Riverpod (flutter_riverpod)](https://riverpod.dev) for reliable, testable, and reactive state tracking.
*   **Routing**: [GoRouter](https://pub.dev/packages/go_router) implementing stateful shell routing (nested tabs navigation).
*   **Backend & Database**: [Firebase Suite](https://firebase.google.com/) (Firebase Core, Firebase Auth, Cloud Firestore, Firebase Storage).
*   **UI Components**: [Shadcn UI for Flutter](https://shadcn-flutter.com/) for high-quality accessible design inputs.
*   **Responsive Layouts**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil) ensuring design consistency across all device sizes (base: `390x844`).
*   **Data Models**: [Freezed](https://pub.dev/packages/freezed) and [Json Serializable](https://pub.dev/packages/json_serializable) for type-safe immutable code generation.
*   **Visual Enhancements**: [Flutter Animate](https://pub.dev/packages/flutter_animate) for clean animations, [Lucide Icons](https://pub.dev/packages/lucide_icons), and [Google Fonts](https://pub.dev/packages/google_fonts).

---

## 📂 Project Architecture

Planzy uses a **Clean, Feature-first Directory Structure** for maintainability and scalability:

```text
lib/
├── core/                     # Core utilities shared across features
│   ├── constants/            # Global app constants
│   ├── models/               # Core data models (e.g., UserSettings)
│   ├── providers/            # Shared providers (e.g., Auth, Firebase)
│   ├── router/               # Navigation configuration & custom shell route
│   ├── theme/                # Neo-Brutalist color tokens and AppTheme
│   └── widgets/              # Reusable core widgets (AppCard, NeoButton, etc.)
│
└── features/                 # Modular feature domains
    ├── accounts/             # Multi-account data models, repositories, and UI screens
    ├── auth/                 # Login, signup, and authentication choices UI
    ├── goals/                # Savings goals management, vault deposits, and reminders
    ├── home/                 # The main financial dashboard containing charts and summaries
    ├── insights/             # Monthly budgets, income-to-expense charts, and category breakdowns
    ├── onboarding/           # Splash screen and onboarding carousel UI
    ├── profile/              # User profile settings and edit profile screen
    ├── subscriptions/        # Recurring subscription lists and renewal alert calculations
    ├── tools/                # Toolbox screen listing tools (Subscriptions, coming soon budgets)
    └── transactions/         # Transaction ledger, add-transaction forms, and category selectors
```

---

## 🏁 Getting Started

### Prerequisites

*   Flutter SDK installed (`>= 3.10.3`).
*   Android SDK / Xcode configured for mobile emulation.
*   Firebase Project created on your Firebase Console.

### Setup Instructions

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Elboraeyy/planzy.git
    cd planzy
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    Configure Firebase for Android and iOS using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) or place the configuration file generated:
    *   Add your Firebase details to `lib/firebase_options.dart`.

4.  **Run Code Generator**:
    Planzy uses `freezed` and `json_serializable` for data serialization. Build generated files:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 📖 Complete App Guide

For an in-depth breakdown of Planzy's features, visual flow screenshots, user guide, and step-by-step instructions on how to manage your wealth with Planzy, please check out our detailed guide:

👉 **[PLANZY_GUIDE.md](file:///e:/Dev/flutter_apps/planzy/PLANZY_GUIDE.md)** *(Arabic & English documentation)*
