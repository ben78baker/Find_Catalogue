# Find Catalogue development instructions

Read `docs/product_brief.md` before changing product behaviour or the data model.

## Product principles

- Build a private, local-first catalogue for varied field finds, not a social detector app.
- The first action is rapid discovery capture: photograph, timestamp, GPS coordinates, GPS accuracy, and automatic permanent log number.
- Treat the original discovery evidence as immutable. Later corrections and interpretations belong in an auditable research history.
- Keep observed facts separate from interpretations. An identification must support alternatives, confidence, evidence, sources, and later revision.
- Preserve exact findspots privately. Any exported or shared record must require an explicit precision choice and default to redaction.
- The user's data must remain portable. Provide complete, documented export and restore; never make the app the only copy.
- Support physical storage through permanent log numbers, concise labels, and QR codes that resolve locally without exposing a private location.
- Work offline for all essential capture and catalogue operations.

## Engineering constraints

- Use Flutter and Dart for iOS, Android, and macOS.
- Prefer a relational local database with explicit migrations. Do not store full-resolution image bytes inside database rows.
- Preserve original media; create derivatives such as thumbnails without modifying originals.
- Use platform services behind interfaces so camera, location, export, printing, and storage can be tested.
- Keep domain models independent of widgets and plugins.
- Add tests for log-number allocation, migrations, redaction, export/restore, and research-history behaviour.
- Avoid accounts, cloud sync, community feeds, valuations, or automated identification in the initial product.
- Do not introduce a package without explaining why it is needed and checking that it is maintained and compatible.

## Working practice

- Deliver in small vertical slices, beginning with capture and reliable retrieval.
- Run `flutter analyze` and `flutter test` after material changes.
- Update `docs/product_brief.md` when a product decision changes; do not silently encode new policy only in code.
- Never use real private coordinates in fixtures, screenshots, examples, or tests.
