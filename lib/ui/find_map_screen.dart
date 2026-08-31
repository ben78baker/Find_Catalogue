import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../domain/find_record.dart';
import 'formatters.dart';

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _tileUserAgent = 'com.ingeneralapps.findCatalogue';
const _overviewCenter = LatLng(54.5, -3.5);

bool isMappableLocation(FindLocation? location) {
  if (location == null) return false;
  return location.latitude.isFinite &&
      location.longitude.isFinite &&
      location.latitude >= -90 &&
      location.latitude <= 90 &&
      location.longitude >= -180 &&
      location.longitude <= 180;
}

List<FindRecord> mappableRecords(Iterable<FindRecord> records) => records
    .where((record) => isMappableLocation(record.location))
    .toList(growable: false);

LatLng _point(FindLocation location) =>
    LatLng(location.latitude, location.longitude);

class FindMapScreen extends StatelessWidget {
  const FindMapScreen({
    super.key,
    required this.title,
    required this.records,
    this.onRecordSelected,
  });

  final String title;
  final List<FindRecord> records;
  final ValueChanged<FindRecord>? onRecordSelected;

  @override
  Widget build(BuildContext context) {
    final located = mappableRecords(records);
    assert(located.isNotEmpty, 'At least one located record is required.');
    final points = located.map((record) => _point(record.location!)).toList();
    final omitted = records.length - located.length;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: points.first,
              initialZoom: 17,
              initialCameraFit: points.length > 1
                  ? CameraFit.coordinates(
                      coordinates: points,
                      padding: const EdgeInsets.fromLTRB(48, 120, 48, 72),
                      maxZoom: 17,
                    )
                  : null,
              minZoom: 2,
              maxZoom: 19,
            ),
            children: [
              _tileLayer(),
              MarkerLayer(
                markers: [
                  for (final record in located)
                    Marker(
                      key: ValueKey('map_marker_${record.id}'),
                      point: _point(record.location!),
                      width: 52,
                      height: 56,
                      alignment: Alignment.bottomCenter,
                      child: Semantics(
                        button: true,
                        label: '${record.logNumber}, ${record.displayTitle}',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showRecord(context, record),
                          child: Icon(
                            Icons.location_on,
                            size: 46,
                            color: Theme.of(context).colorScheme.primary,
                            shadows: const [
                              Shadow(color: Colors.white, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: IgnorePointer(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Text(
                      '${located.length} ${located.length == 1 ? 'find' : 'finds'} mapped'
                      '${omitted == 0 ? '' : ' - $omitted without a usable location not shown'}. '
                      'The displayed area is requested from OpenStreetMap; record details stay on this device.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecord(BuildContext context, FindRecord record) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text('${record.logNumber} - ${record.displayTitle}'),
          subtitle: Text(
            '${formatCoordinate(record.location!.latitude)}, '
            '${formatCoordinate(record.location!.longitude)}',
          ),
          trailing: onRecordSelected == null
              ? null
              : const Icon(Icons.chevron_right),
          onTap: onRecordSelected == null
              ? null
              : () {
                  Navigator.pop(sheetContext);
                  onRecordSelected!(record);
                },
        ),
      ),
    );
  }
}

class FindLocationPickerScreen extends StatefulWidget {
  const FindLocationPickerScreen({super.key, this.initialLocation});

  final FindLocation? initialLocation;

  @override
  State<FindLocationPickerScreen> createState() =>
      _FindLocationPickerScreenState();
}

class _FindLocationPickerScreenState extends State<FindLocationPickerScreen> {
  final _mapController = MapController();
  late LatLng _selected;
  late bool _hasChosen;

  @override
  void initState() {
    super.initState();
    _hasChosen = isMappableLocation(widget.initialLocation);
    _selected = _hasChosen ? _point(widget.initialLocation!) : _overviewCenter;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  FindLocation get _result => FindLocation(
    latitude: _selected.latitude,
    longitude: _selected.longitude,
    horizontalAccuracy: null,
    source: FieldSource.manuallyEntered,
  );

  void _useLocation() {
    if (_hasChosen) Navigator.pop(context, _result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinpoint findspot'),
        actions: [
          TextButton(
            key: const Key('use_map_location_action'),
            onPressed: _hasChosen ? _useLocation : null,
            child: const Text('Use'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected,
              initialZoom: _hasChosen ? 17 : 5.5,
              minZoom: 2,
              maxZoom: 19,
              onTap: (_, point) {
                _mapController.move(point, _mapController.camera.zoom);
                setState(() {
                  _selected = point;
                  _hasChosen = true;
                });
              },
              onPositionChanged: (camera, hasGesture) {
                if (!hasGesture) return;
                setState(() {
                  _selected = camera.center;
                  _hasChosen = true;
                });
              },
            ),
            children: [
              _tileLayer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 116),
                child: SimpleAttributionWidget(
                  source: Text('OpenStreetMap contributors'),
                ),
              ),
            ],
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -23),
              child: IgnorePointer(
                child: Icon(
                  Icons.location_on,
                  size: 52,
                  color: Theme.of(context).colorScheme.primary,
                  shadows: const [Shadow(color: Colors.white, blurRadius: 5)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Card(
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Move the map or tap a point until the pin marks the findspot. '
                    'The displayed area is requested from OpenStreetMap.',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _hasChosen
                            ? '${formatCoordinate(_selected.latitude)}, ${formatCoordinate(_selected.longitude)}'
                            : 'Move or tap the map to choose a location',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        key: const Key('use_map_location_button'),
                        onPressed: _hasChosen ? _useLocation : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Use this location'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TileLayer _tileLayer() => TileLayer(
  urlTemplate: _tileUrl,
  userAgentPackageName: _tileUserAgent,
  maxNativeZoom: 19,
);
