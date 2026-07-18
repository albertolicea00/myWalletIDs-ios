# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| Latest | ✅ |

Only the latest release receives security updates.

## Reporting a vulnerability

This app is fully offline and stores no user data on any server. However, if you
find a security issue — a data leak, a bypass of the biometric lock, or any other
vulnerability — please open a **[private security advisory](https://github.com/albertolicea00/myWalletIDs-ios/security/advisories/new)**
on GitHub.

Do **not** file a public issue for security vulnerabilities.

You can expect:
- Acknowledgment within 72 hours.
- An initial assessment within one week.
- A fix or mitigation published in the next release, depending on severity.

## Security design

- **No network access.** The app declares no network entitlements. Data never
  leaves the device.
- **No analytics, no telemetry, no crash reporting.** The app contains zero
  tracking SDKs.
- **App lock.** Face ID / Touch ID (with passcode fallback) gate on launch and
  on return from background.
- **Sensitive field masking.** Sensitive values are hidden by default (`••••`)
  and only revealed on explicit user action.
- **Local storage only.** SwiftData store and card photos are kept in the app's
  sandboxed container.
