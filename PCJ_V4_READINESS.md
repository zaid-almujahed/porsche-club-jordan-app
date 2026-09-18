# PCJ v4 Readiness Report

Date: 2026-09-18

## Verdict

The recovered PCJ v4 source has been completed as far as the supplied contract
allows. Core screens and guarded state transitions are implemented, but the
project is **integration-ready, not store-release-ready**. The remaining
blockers require backend decisions, production credentials, licensed brand
assets, signing identities, or real-device execution; none can be safely
invented in application code.

## Implemented and hardened

- OTP login uses purpose `login`; registration uses `registration`; password
  recovery uses `forgot_password`.
- Password policy is shared by registration and reset: at least eight
  characters and at least one number, with matching confirmation.
- The login `400 {"detail":"Waiting for admin approval."}` response creates a
  pending application session and routes to the status screen.
- Successful OTP login stores the access token securely, then reads `/auth/me`
  and `/member/membership` before routing.
- Membership routing is fail-closed: `ACTIVE` enters member content,
  `APPROVED` goes to membership payment, pending/denied go to application
  status, and unknown non-empty states do not unlock the app.
- Startup-session and OTP-navigation race guards prevent stale restore results
  and root-route pops from causing the previous black-screen failure.
- Registration sends all supplied multipart field names, including the
  backend's intentional `licens_plate_photo` spelling and 10/17-character VIN
  rule.
- Events, details, sponsors, galleries, capacity, maps, weather fallback,
  guest limits, guest notice, RSVP, cancellation, member events, and QR ticket
  flows are wired.
- RSVP always sends `{"guest_count": n}`, including zero. RSVP responses retain
  `rsvp_id`, `payment_status`, and `amount`.
- A paid RSVP is not described as paid or allowed to expose a ticket until the
  backend reports payment completion. An attended ticket never requests a new
  QR code.
- Profile editing, avatar upload, membership card/QR, phone update, account
  deletion, and sign-out cache clearing are wired.
- Account deletion explicitly warns that membership is cancelled and a future
  return requires a new application and review.
- Existing claimed offers are loaded from `/member/my-offers`; new claims use
  the documented claim route.
- Product catalogue/details and exact variant selection are dynamic. Cart
  state is safely session-local until its server request schema is supplied.
- Home data loads independent sections concurrently, preserves partial
  results, and reports an error if every source fails.
- Support includes topic and message composition and opens the device email
  application. Until an official mailbox is supplied, the member's own email
  is intentionally used as the temporary recipient and reply address.
- Sensitive request/response logging was removed.
- Unit tests were added for password policy, access-state parsing, event
  parsing/capacity, RSVP payment gating, and product variants.

## Release blockers requiring owner/backend input

### 1. Payment and checkout contracts

- Membership payment start is known as `POST /member/membership/payment`, but
  the provider redirect/deep-link/SDK response contract is not supplied. The
  app starts the request and remains locked unless a subsequent membership
  read returns `ACTIVE`.
- Event payment start is known as `POST /member/events/{rsvp_id}/payment`, but
  its response and provider handoff are not supplied. The app creates the RSVP
  and truthfully shows payment pending; it does not invent a redirect URL.
- Cart route names are known, but exact add/update/delete payloads, cart
  response shape, checkout payload, order response, and payment handoff are
  missing. The current cart is session-local and checkout returns a clear
  unsupported-contract error instead of creating a potentially wrong order.
- The membership response documentation does not provide a guaranteed fee
  field. The UI displays `Fee pending` when the backend does not send one.

### 2. API points that need one production confirmation

- RSVP material conflicted between `/member/events/{event_id}/rsvp` and
  `/members/events/{event_id}/rsvp`. The code uses singular `/member`, matching
  the rest of the member API and the project documentation. Confirm against
  the deployed OpenAPI before release.
- Password reset uses `POST /auth/reset-password`; one earlier note omitted the
  `/auth` prefix. Confirm the deployed route.
- The reset-token parser accepts documented and observed variants, including
  `reset_token`, `reset-token`, `resent_token`, and `resent-token`.
- The registration example shows date of birth as `1-2-2000`; the app sends
  zero-padded `DD-MM-YYYY`. Confirm whether the backend parser requires the
  unpadded example literally.
- The registration example shows a local Jordanian `079...` number; the UI
  normalizes to international `+962...`. Confirm the canonical server format.
- The supplied RSVP body contains only `guest_count`. The registered-vehicle
  selector is therefore not transmitted; confirm whether a vehicle identifier
  is intentionally unnecessary or publish the required field.
- Validate production response samples for `/auth/me`, membership, events,
  items/variants, offers, orders, QR, and mutation responses. The parsers are
  defensive, but only the live server can prove exact envelopes and keys.

### 3. Product configuration and brand assets

- Replace `YOUR_ANDROID_GOOGLE_MAPS_API_KEY` and
  `YOUR_IOS_GOOGLE_MAPS_API_KEY` with platform-restricted production keys.
- Replace temporary IDs `com.example.pcj_v4` (Android) and
  `com.example.pcjV4` (iOS) with the approved identifiers.
- Configure the Android release keystore and Apple development team,
  provisioning, capabilities, and App Store signing. Android currently uses
  debug signing for release builds so local release runs remain possible.
- Replace the default Flutter launcher icons with the approved square PCJ app
  icon. The supplied horizontal club logo is not a safe app-icon substitute.
- Supply the referenced `bgimage.jpg`, `membership_payment_texture.png`, and
  `registration_vehicle_car.png`. Runtime fallbacks prevent crashes, but the
  intended visuals are absent.
- Supply and license the Porsche Next, Inter, and Hanken Grotesk font files, or
  approve system-font substitutions. The styles reference these font names,
  but no font assets were included.
- Supply the official support mailbox or a support endpoint and replace the
  deliberate self-addressed email fallback.
- Confirm the public version/build number; the project remains `1.0.0+1`.

### 4. Features awaiting a backend/product decision

- No email-update endpoint was supplied, so email is visibly locked while a
  repository method is retained for future integration.
- No vehicle-deletion endpoint was supplied; the app returns a clear error if
  that action is requested.
- Notification read/token endpoints exist in code, but a notification screen,
  Firebase/APNs configuration, permission copy, and lifecycle behavior were
  not specified.

## Verification performed in this handoff

- Reviewed all Dart source and platform configuration from the supplied
  checkpoint.
- Static checks found no unresolved internal imports or delimiter errors across
  139 Dart files; XML/plist, JSON, and YAML files parsed successfully.
- Checked endpoint strings, OTP purposes, multipart field names, placeholders,
  asset references, bundle identifiers, release signing, and sensitive-log
  patterns.
- Added `analysis_options.yaml` and focused unit tests.
- Removed the stale `pubspec.lock`; it lacked `qr_flutter`,
  `google_maps_flutter`, and `url_launcher` despite those dependencies being
  declared.

The current execution environment does not contain Flutter or Dart, so
`flutter pub get`, formatting, analyzer, tests, native compilation, and device
tests could not be executed here. This is an explicit verification gap, not a
claim of a passing build.

## Required release verification matrix

Run these after supplying the blockers above:

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
flutter build ios --release --no-codesign
```

Then exercise on real Android and iOS devices:

1. Fresh install, app restart, token restore, sign-out, expired/401 session.
2. Wrong credentials, pending approval exact error, rejected, approved, active,
   expired, and an unknown membership status.
3. Login, registration, and forgot-password OTP request/resend/invalid/expired
   flows, including the reset-token spelling returned by production.
4. Registration with both 10- and 17-character VINs, image permission denial,
   files over 5 MB, DOB/phone server validation, and both upload formats.
5. Free, paid, full, guest-enabled, cancelled, and attended events; verify no
   QR regeneration after check-in and no QR before payment confirmation.
6. Maps on both platforms with restricted keys and weather-provider failure.
7. Profile edits, avatar replacement, account deletion, and cross-account
   cache isolation after sign-out/sign-in.
8. Existing/new offer claims, product variants and stock limits, cart changes,
   checkout/payment after the final server contract, and order history.
9. Email composer installed/not installed, official recipient, and reply path.
10. Small/large screens, text scaling, offline/timeouts, slow responses, and
    store-signed release builds.
