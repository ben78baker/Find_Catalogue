# Find Catalogue

A private, local-first research catalogue for field finds.

The app begins with rapid discovery capture—a photograph, location, timestamp, and permanent log number—and lets that evidence grow into a detailed, revision-friendly object record with research sources and physical labels.

See [the product brief](docs/product_brief.md) for the intended workflow and scope. Development agents must also follow [AGENTS.md](AGENTS.md).

## Release platforms

- iPhone (iOS)
- Android phones
- macOS

The first mobile release is deliberately not distributed for iPad or Android tablet screen classes.

## Current status

The first working vertical slice is implemented:

- `Instant Find` captures a discovery photograph, time, and current location;
- `Create Find Record` supports retrospective records with manual or unknown discovery evidence;
- original photographs are copied into app-owned storage and kept outside the database;
- records receive permanent sequential numbers such as `FO-000001`;
- the catalogue is stored locally in SQLite through Drift and works offline;
- all records can be searched across every stored field, filtered, sorted, opened, and edited;
- basic identification, material, confidence, interpreted timeline, measurements, observations, research notes, sources, and storage fields are available;
- records with locations can be viewed individually or as the current searched/filtered result set on a map;
- manual records can be positioned on the map;
- one record or the current result set can be shared as CSV, PDF, or a PDF-and-photos ZIP bundle, with exact locations either deliberately included or hidden.

Portable backup/restore, research revision history, labels, and QR codes remain later release slices.

Release preparation notes and draft App Store material are in [`docs/release`](docs/release/).

## Privacy and support

- [Privacy policy](https://ben78baker.github.io/find-catalogue-privacy-policy/)
- [Support](https://ben78baker.github.io/find-catalogue-privacy-policy/find-catalogue-support/)

The source is published for transparency. See [LICENSE](LICENSE) for the repository's terms.

## Getting Started

Install the current Flutter stable SDK, then run:

```sh
flutter pub get
dart run build_runner build
flutter run
```

Quality checks:

```sh
flutter analyze
flutter test
```
