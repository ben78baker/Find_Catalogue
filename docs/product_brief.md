# Find Catalogue product brief

## Purpose

Find Catalogue is a private research catalogue for objects discovered in the field. It begins with evidence captured at discovery and grows into a detailed, revision-friendly digital record linked to a short physical label.

The app must accommodate coins, buttons, fittings, tools, fragments, unidentified objects, and other finds without forcing them into a narrow taxonomy.

## Core workflow

### Opening screen

The initial screen offers three deliberately distinct actions:

- **Instant Find** starts a record at the find event and captures a discovery photograph, current time, and current location.
- **Create Find Record** catalogues an existing object later, using an existing photograph and manually entered, approximate, or unknown discovery details.
- **View Records** opens the complete catalogue in date order, with global search across every field and filters.

An always-available information action opens the published privacy policy and support page without competing with those three catalogue workflows.

Selecting a record tile opens the full record. Editing is a separate, explicit action from the detail view.

Records with stored coordinates offer a private in-app map view. The records screen can map the current result set: all located records when no search or filters are active, or only located records matching the active search and filters. The manual Create Find Record flow also allows a findspot to be positioned precisely on the map.

### 1. Capture a discovery

The primary field action should take only a few seconds:

1. Take or select the initial photograph.
2. Capture the device timestamp, coordinates, altitude when available, and horizontal location accuracy.
3. Allocate a permanent, human-readable log number such as `FO-000001`.
4. Save locally even without connectivity.

Depth, detector reading, field/session, landowner reference, recovery notes, and a manually adjusted position are useful optional fields. The app must distinguish device-captured values from later user-entered values.

### 2. Build the object record

The initial editor remains approachable and includes:

- discovery, front, reverse, edge, scale, detail, and contextual photographs;
- preferred identification, material, and identification confidence;
- an optional interpreted timeline range, entered as From and To catalogue years (negative years represent BCE);
- length, width, height, diameter, thickness, and weight;
- discovery date and location, including whether each was device-captured, manually entered, or unknown;
- factual observations and separate research reasoning/notes;
- research sources or links and physical storage location.

Unneeded fields may remain blank. A later **More details** or **Add field** route will expose specialist fields without crowding every record. Those additional fields can include:

- front, reverse, edge, scale, detail, and contextual photographs;
- dimensions, weight, material, construction, condition, and diagnostic features;
- inscriptions and maker marks, including uncertain or partial transcriptions;
- storage location and conservation notes;
- object category and descriptive keywords;
- possible identification, date range, cultural period, and confidence;
- alternative identifications and reasons for rejecting or retaining them;
- research notes, citations, comparison links, museum records, and PAS/FLO references.

Observed attributes must not be overwritten by an identification. For example, "regular diagonal grooves survive on the edge" is an observation; "imitation-guinea gaming counter" is an interpretation.

### 3. Revise the research

Identification is expected to change. Each revision should retain:

- the previous interpretation;
- when it changed;
- why it changed;
- supporting or contradicting evidence;
- confidence at that time;
- optional attribution to the user, an FLO, museum specialist, publication, or other source.

The current preferred interpretation should be easy to find without erasing the history.

### 4. Label and retrieve

Generate a compact printable label containing at minimum:

- permanent log number;
- short preferred identification or `Unidentified object`;
- broad date or `Date uncertain`;
- optional material and find year;
- QR code or compact machine-readable code.

The QR target must work locally and must not encode exact coordinates or other sensitive information directly.

## Privacy model

The private record can retain exact coordinates, landowner details, permission documents, and precise field information. Sharing and export are separate actions.

Every shared record must offer an explicit findspot precision, for example:

- hidden;
- county or broad area;
- parish;
- reduced grid reference;
- exact coordinates.

Default to hidden or deliberately reduced precision. A research export and a private backup are different products and should be clearly named.

CSV and PDF sharing may be started from one record or from the records list. List sharing operates on the current search and filters, with an optional discovery-date range, so unrelated private records are not included accidentally.

A PDF-and-photos bundle contains the formatted PDF at its root and saveable photographs grouped into folders by permanent log number. The ZIP bundle is the dependable way to deliver image files without relying on viewer-specific PDF attachment support. When exact locations are included, the bundle preserves untouched originals. When locations are hidden, it instead re-encodes supported photos without embedded metadata (including GPS); a photo that cannot be sanitised safely is omitted and named in the bundle manifest.

## Data ownership and resilience

- No account is required for the initial product.
- All essential functions work offline.
- Backups include the database, original photographs, derivatives needed for display, and a manifest describing versions and checksums.
- Media references stored in the database are portable paths relative to the app's documents directory, so an iOS sandbox-path change after an update does not detach records from their photographs.
- Export should include an open tabular format for core records plus a documented media folder structure.
- Restore must be tested and must never silently replace an existing catalogue.
- Permanent log numbers are never reused after deletion or record merging.
- Record coordinates and search results remain local. Interactive base-map tiles are requested from OpenStreetMap only when a user opens a map; visible attribution and the map provider's caching and usage requirements must be respected. Coordinate entry and the underlying catalogue continue to work without map tiles.

## Initial release slices

1. Create and retrieve either an instant or retrospective discovery from a photograph, discovery evidence, and allocated log number.
2. Browse in date order, search across all stored fields, filter, open, and deliberately edit object details; attach additional photographs.
3. Record preferred and alternative identifications with confidence, evidence, sources, and revision history.
4. Export and restore a complete portable archive.
5. Create private-safe PDF labels and QR codes.
6. Add session, PAS/FLO, and richer reporting functions only after the catalogue foundation is reliable.

## Explicitly deferred

- social feeds, public profiles, leaderboards, or valuation;
- cloud accounts and multi-user collaboration;
- automated identification presented as fact;
- route tracking and detector hardware integration;
- direct submission to external archaeological databases;
- subscription or marketplace features.
