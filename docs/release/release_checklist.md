# Find Catalogue release checklist

## Four decisions/blockers before upload

- [x] Approved non-Flutter app icon installed for iOS, Android and macOS. Release master: `assets/branding/find_catalogue_icon_1024.png`.
- [x] Publish the completed privacy policy at a public URL and provide an actual support URL/contact method.
- [x] Add an easily accessible privacy-policy link inside the app once that URL is known.
- [x] Version 1.0 is configured for iPhone only; iPad is not an App Store target.

## Privacy and policy

- [x] Replace all bracketed placeholders in `privacy_policy_draft.md`.
- [ ] Confirm the OpenStreetMap App Privacy answers in `app_store_privacy_answers.md`.
- [ ] Ensure the in-app map disclosure matches the published policy.
- [ ] Generate and inspect Xcode’s privacy report from the Release archive.
- [ ] Confirm App Store Connect shows no tracking.

## App Store Connect setup

- [ ] Confirm the latest Apple Developer agreement is accepted.
- [ ] Create the app record before uploading the first build.
- [ ] App name: **Find Catalogue** (subject to availability in App Store Connect).
- [ ] Bundle ID: `com.ingeneralapps.findCatalogue`.
- [ ] SKU: choose a stable internal value, for example `FINDCATALOGUE-IOS-001`.
- [ ] Primary language: English (U.K.) if that matches the intended listing.
- [ ] Price: decide Free or Paid; the app has no in-app purchases.
- [ ] Complete the age-rating questionnaire; the current feature set appears suitable for the lowest general rating, subject to your answers.
- [ ] Enter privacy-policy URL, support URL, category, copyright and listing copy.
- [ ] Enter App Privacy answers and publish them.

## Build and TestFlight

- [x] Version/build currently starts at `1.0.0+1`.
- [x] Bundle identifier and Apple development team are configured.
- [x] The project uses Xcode 26/iOS 26 SDK tooling, satisfying Apple’s current SDK floor.
- [ ] Complete Apple’s export-compliance questionnaire before adding `ITSAppUsesNonExemptEncryption`. The current features create unencrypted archives and use HTTPS, but archive/PDF dependencies contain optional encryption implementations, so do not make the declaration without confirming the final binary’s classification.
- [ ] Run `flutter analyze` and `flutter test` immediately before archiving.
- [ ] Test on a physical iPhone: first launch, denied camera/location, camera capture, library selection, map, offline catalogue, record edit and all three share formats.
- [ ] Test an upgrade over a copy containing records and photographs; confirm records and portable media paths survive.
- [ ] In Xcode, select **Any iOS Device (arm64)**, then **Product → Archive** from `ios/Runner.xcworkspace`.
- [ ] Validate the archive and inspect its privacy report.
- [ ] Upload to App Store Connect and use internal TestFlight before review.

## Google Play build

- [x] Restrict Play distribution to Android small and normal screen classes; large and extra-large tablet classes are not declared compatible.
- [ ] After uploading the first Android App Bundle, review the supported devices in Play Console's device catalogue and confirm tablets are excluded before rollout.
- [ ] Test the release build on at least one physical Android phone, including denied camera/location permissions, map use, offline catalogue access, editing and all three share formats.

## Store assets

- [ ] Capture one to ten screenshots using invented records and non-sensitive coordinates.
- [ ] Supply the highest required iPhone screenshot size accepted by App Store Connect.
- [x] No iPad screenshot set is required because version 1.0 is iPhone-only.
- [ ] Do not show real finds, names, storage locations or exact private findspots.
- [ ] Check the icon at small Home Screen and Settings sizes, not only at 1024 px.

## Review submission

- [ ] Copy the prepared description, keywords, promotional text and review notes from `app_store_listing.md`.
- [ ] Provide review contact name, email and telephone number.
- [ ] No demo account is required; state that clearly.
- [ ] Explain that a photo is required to save a record and that reviewers may select one from the library.
- [ ] Select the uploaded build and answer export-compliance questions.
- [ ] Choose manual release if you want approval without immediate public availability.

## Product risks that are not App Store form blockers

- [ ] Version 1.0 does not yet provide a full portable backup/restore workflow.
- [ ] Identification revision history, labels and QR codes remain planned later slices.
- [ ] OpenStreetMap’s community tile service is best-effort and may block unsuitable or heavy usage; monitor the policy before each release.
