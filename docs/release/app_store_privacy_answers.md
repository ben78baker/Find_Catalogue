# App Store privacy answers — working draft

These answers are deliberately conservative and must be checked against the final build and the exact OpenStreetMap disclosure chosen at submission time.

## Tracking

- **Does the app or any partner use data for tracking?** No.
- There are no advertising SDKs, analytics SDKs, cross-app identifiers or data brokers.

## Data kept only on the device

The following data is processed and stored locally and, by itself, is not “collected” under Apple’s App Privacy definition:

- precise find locations and location accuracy;
- photographs;
- discovery dates;
- identification and catalogue fields;
- search queries; and
- the local SQLite catalogue.

User-directed exports through the system share sheet are not sent to a developer-operated service. The user deliberately chooses the file, its location precision and the receiving destination.

## OpenStreetMap map-tile requests

Opening a map sends tile requests for the displayed area to OpenStreetMap. OSMF states that service logs can contain IP address, application/browser and device information, operating system, time and resources accessed. Because those logs can persist beyond the real-time request, a blanket **Data Not Collected** answer would be difficult to justify.

Conservative App Store Connect entries to consider:

| Data type | Purpose | Linked to user | Tracking |
| --- | --- | --- | --- |
| Precise Location | App Functionality | Yes — conservative because a high-zoom tile area may be logged with IP address | No |
| Product Interaction or Other Usage Data | App Functionality | Yes — conservative because accessed tiles can be logged with IP address | No |

Apple does not provide a single dedicated “IP address” data type; its guidance says to select the relevant type based on how an IP address is used. Confirm the final classification in App Store Connect or with qualified privacy advice.

## Permissions are not collection by themselves

Camera, photo-library and location permission use does not mean the corresponding information is collected when it remains only on the device. The permission-purpose strings should still match the actual features and the public privacy policy.

## Third-party SDK manifests

The current iOS CocoaPods for geolocation, image selection, package information and sharing include their own `PrivacyInfo.xcprivacy` resources. The final archived build should still be checked using Xcode’s privacy report before upload.
