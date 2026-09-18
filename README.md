# Porsche Club Jordan — PCJ v4

Flutter member application for Porsche Club Jordan. The app is connected to
the documented `https://porscheclubjo.com` REST routes and contains the member
registration, OTP authentication, status routing, events, RSVP, tickets,
profile, membership, offers, shop catalogue, local cart, and order-history
experiences.

## Required toolchain

- Flutter `>=3.38.4`
- Dart `>=3.11.0 <4.0.0`
- Android SDK with API 24 or newer
- Xcode, CocoaPods, and iOS 14 or newer for iOS builds

The dependency lockfile is intentionally not included: the recovered
checkpoint's lockfile did not contain all declared plugins. Generate a correct
lockfile with the target Flutter SDK instead of building against stale pins.

## Local setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Before a release build, replace the Android and iOS Google Maps placeholders,
set production application identifiers and signing, add the approved brand
assets/fonts, then run the release verification matrix in
[`PCJ_V4_READINESS.md`](PCJ_V4_READINESS.md).

## Safety behavior

- Access tokens are stored with platform secure storage.
- Passwords, OTPs, tokens, personal data, VINs, filenames, URLs, and response
  bodies are not logged by the API client.
- Unknown non-empty membership states fail closed.
- Paid access is not presented as complete until the backend confirms payment.
- Undocumented email-update, vehicle-deletion, checkout, and payment handoff
  payloads are not guessed.

## Current release status

The app source is implementation-complete for the supplied API contract, but
it is not store-release-ready until the external items listed in
[`PCJ_V4_READINESS.md`](PCJ_V4_READINESS.md) are supplied and verified on real
Android and iOS devices.
