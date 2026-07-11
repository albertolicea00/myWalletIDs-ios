# My Wallet IDs (iOS)

An offline personal vault for the cards in your pocket — credit and debit
cards, ID documents, business cards, loyalty programs and anything else you
would keep in a physical wallet. Cards are presented the way a real wallet
holds them: stacked, peeking out from under each other, sliding free as you
scroll.

## What it is / what it is NOT

**It is:**

- A private, fully offline vault for structured card data and card photos.
- A "digital twin" of your physical wallet, organized your way.
- Local-first: everything lives on your device, nothing leaves it.

**It is NOT:**

- A payment wallet. There is no NFC, no Apple Pay / PassKit integration and
  no transaction of any kind.
- A cloud service. There is no account, no sync, no server and no analytics.

## Features

- **Card templates** — credit/debit card, ID document, business card,
  loyalty card and free-form custom cards. Templates pre-populate sensible
  fields; every field can be renamed, retyped, reordered or removed.
- **Realistic wallet UI** — stacked card list, ID-1 aspect ratio card faces,
  12-color palette with five Canvas-drawn patterns (stripes, dots, waves,
  carbon, grid), or your own front/back photos.
- **3D flip** — tap the card in the detail screen to flip it and see the
  back: your photo, or a generated card back with the sensitive fields.
- **Sensitive values** — masked by default, revealed with an eye toggle,
  copied to the clipboard with one tap.
- **Sections as tabs** — optional, user-defined sections (name + SF Symbol +
  optional template filter) become tabs. With no sections there is no tab
  bar at all, just one wallet.
- **App lock** — optional Face ID / Touch ID (with passcode fallback) gate
  on launch and when returning from the background.
- **Theme** — system, light or dark.

## Screenshots

> _Coming soon — wallet stack, card detail flip, editor and sections._

## Architecture

Plain SwiftUI + SwiftData, no third-party dependencies.

- **Models** (`@Model`): `Card`, `CardField`, `WalletSection`. Enums
  (template, pattern, field type) are stored as raw strings with computed
  accessors, which keeps SwiftData happy and migrations trivial.
- **Images**: photos are files in Application Support managed by
  `ImageStore`; models store only filenames.
- **Navigation shell**: `RootView` observes sections with `@Query` and
  switches reactively between a single `NavigationStack` (no sections) and a
  `TabView` (one tab per visible section).
- **Editor**: works on value-type drafts (`FieldDraft`) and only writes back
  to SwiftData on Save, so Cancel is always safe.
- **App lock**: `AppLockManager` (LocalAuthentication) + `LockScreenView`
  overlay driven by scene phase changes.

## Project structure

```
my-wallet-ids-ios/
├── project.yml                  # XcodeGen definition (source of truth)
├── MyWalletIDs/
│   ├── App/                     # Entry point, root shell, Info.plist
│   ├── Models/                  # SwiftData models + field templates
│   ├── Support/                 # ImageStore, app lock, theme, helpers
│   ├── Views/
│   │   ├── Wallet/              # Stacked wallet list, card face
│   │   ├── Detail/              # Card detail, flip, field rows
│   │   ├── Editor/              # Card editor, drafts, add-field sheet
│   │   ├── Sections/            # Sections CRUD
│   │   ├── Settings/            # Settings, lock screen
│   │   └── Shared/              # Canvas pattern overlay
│   └── Resources/               # Asset catalog
└── .github/                     # PR / issue templates
```

## Tech stack

| Layer         | Choice                                    |
| ------------- | ----------------------------------------- |
| Language      | Swift 5.10+                               |
| UI            | SwiftUI (iOS 17.0+)                       |
| Persistence   | SwiftData                                 |
| Images        | Files in Application Support (`ImageStore`) |
| Photos input  | PhotosUI `PhotosPicker`                   |
| Biometrics    | LocalAuthentication                       |
| Project       | XcodeGen (`project.yml`)                  |
| Dependencies  | None                                      |

## Getting started

```bash
brew install xcodegen
git clone <this repo>
cd my-wallet-ids-ios
xcodegen generate
open MyWalletIDs.xcodeproj
```

The `.xcodeproj` is generated and gitignored — never edit it directly;
change `project.yml` and regenerate.

Build from the command line:

```bash
xcodebuild -project MyWalletIDs.xcodeproj -scheme MyWalletIDs \
  -destination 'generic/platform=iOS Simulator' build
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, branch naming and the
commit convention.

## License

MIT — see [LICENSE](LICENSE).
