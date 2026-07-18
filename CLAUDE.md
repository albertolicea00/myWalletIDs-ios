# CLAUDE.md — Development Guide

Guidance for coding assistants and contributors working in this repository.

## Project overview

**My Wallet IDs** is an offline personal vault for cards: credit/debit
cards, ID documents, business cards, loyalty cards and custom cards. It
stores structured fields plus optional front/back photos and presents cards
like a real physical wallet (stacked list, 3D flip detail).

It is **not** a payment wallet: no NFC, no Apple Pay / PassKit, no
transactions, no networking of any kind.

- App name: `MyWalletIDs` · Bundle id: `com.albertolicea.mywalletids`
- Swift 5.10+ / SwiftUI / SwiftData · iOS 17.0 deployment target
- Zero third-party dependencies

## XcodeGen workflow (important)

`project.yml` is the source of truth. The `.xcodeproj` is generated and
gitignored.

- **Never edit `MyWalletIDs.xcodeproj`.** Change `project.yml`, then run:
  ```bash
  xcodegen generate
  ```
- New Swift files under `MyWalletIDs/` are picked up automatically on the
  next `xcodegen generate` (the whole folder is the target's source path).

### Build command

```bash
xcodebuild -project MyWalletIDs.xcodeproj -scheme MyWalletIDs \
  -destination 'generic/platform=iOS Simulator' build
```

## File map

```
MyWalletIDs/
├── App/
│   ├── MyWalletIDsApp.swift      # @main; theme, model container, app lock wiring
│   ├── RootView.swift            # Shell switch: single wallet ⇄ TabView of sections
│   └── Info.plist                # NSFaceIDUsageDescription lives here
├── Models/
│   ├── Card.swift                # @Model Card + CardTemplate/PatternStyle enums
│   ├── CardField.swift           # @Model CardField + FieldType enum
│   ├── WalletSection.swift       # @Model WalletSection (user tabs)
│   └── FieldTemplates.swift      # FieldSeed lists per template
├── Support/
│   ├── ImageStore.swift          # Save/load/delete card photos (App Support dir)
│   ├── AppLockManager.swift      # LocalAuthentication gate
│   ├── AppTheme.swift            # system/light/dark (@AppStorage "appTheme")
│   ├── Color+Hex.swift           # Color(hex:) + CardPalette presets
│   ├── Formatters.swift          # "yyyy-MM-dd" date-field format
│   └── String+Masking.swift      # masked() for sensitive values
└── Views/
    ├── Wallet/                   # WalletView (stacked list), CardFaceView
    ├── Detail/                   # CardDetailView (flip), FieldRowView
    ├── Editor/                   # CardEditorView, FieldDraft(+Row), AddFieldSheet
    ├── Sections/                 # SectionsSettingsView, SectionEditorView
    ├── Settings/                 # SettingsView, LockScreenView
    └── Shared/                   # PatternOverlay (Canvas patterns)
```

## SwiftData conventions

- Models are `final class` with `@Model`; `id: UUID` marked
  `@Attribute(.unique)`.
- **Enums are never stored directly.** Store the raw string
  (`templateKey`, `patternStyleRaw`, `typeRaw`, `templateFilter`) and expose
  a computed accessor (`template`, `pattern`, `type`, `filterTemplate`)
  that falls back to a safe default on unknown raw values.
- `Card.fields` uses `@Relationship(deleteRule: .cascade, inverse:
  \CardField.card)`; the inverse is declared on the `Card` side only.
- Ordering is explicit via `orderIndex` (`Int`) on `Card`, `CardField` and
  `WalletSection`; sort with `sortedFields` / `@Query(sort:)`.
- Images are **not** stored in SwiftData. `ImageStore` writes files to
  Application Support and models keep only the filename.
- The editor mutates value-type drafts (`FieldDraft`) and reconciles them
  into models on Save, so Cancel never dirties the context.

## How to add things

### A new screen

1. Create the view under the matching `Views/` subfolder (new folder if it
   is a new area).
2. Navigate to it with `NavigationLink` (push) or `.sheet` (modal); the
   detail screen uses `.navigationDestination(for: Card.self)`.
3. Run `xcodegen generate` — no project.yml change needed for new files.

### A new field type

1. Add a case to `FieldType` in `Models/CardField.swift` with
   `displayName` and `systemImage`.
2. Add an input control case in `FieldDraftRow.valueInput`.
3. If it should be masked by default, extend `defaultsToSensitive`.

### A new card template

1. Add a case to `CardTemplate` in `Models/Card.swift` (`displayName`,
   `systemImage`).
2. Add its seed list in `Models/FieldTemplates.swift`.
3. Nothing else: pickers iterate `CardTemplate.allCases`.

### A new pattern

1. Add a case to `PatternStyle` in `Models/Card.swift`.
2. Draw it in `Views/Shared/PatternOverlay.swift` (Canvas).

## Commit convention

Conventional Commits, English, imperative, subject ≤72 chars:

```
feat(wallet): add drag reordering to the stack
fix(editor): keep drafts when template picker re-renders
docs: explain imagestore file layout
chore: regenerate project settings for xcode 16
```

One logical change per commit. Do not commit the generated `.xcodeproj`.
