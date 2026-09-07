import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../domain/find_record.dart';
import '../services/location_capture_service.dart';
import '../services/place_geocoding_service.dart';
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

double _zoomForVisibleWidth(
  BuildContext context,
  double latitude,
  double targetWidthMetres, {
  double minimum = 2,
  double maximum = 19,
}) {
  final width = MediaQuery.sizeOf(context).width.clamp(280.0, 1000.0);
  final cosine = math.cos(latitude * math.pi / 180).abs().clamp(0.05, 1.0);
  return (math.log(156543.03392 * cosine * width / targetWidthMetres) /
          math.ln2)
      .clamp(minimum, maximum);
}

class FindMapScreen extends StatefulWidget {
  const FindMapScreen({
    super.key,
    required this.title,
    required this.records,
    this.onRecordSelected,
    this.geocodingService,
    this.locationCaptureService,
  });

  final String title;
  final List<FindRecord> records;
  final ValueChanged<FindRecord>? onRecordSelected;
  final PlaceGeocodingService? geocodingService;
  final LocationCaptureService? locationCaptureService;

  @override
  State<FindMapScreen> createState() => _FindMapScreenState();
}

class _FindMapScreenState extends State<FindMapScreen> {
  final _mapController = MapController();
  LocationCaptureSession? _locationSession;
  StreamSubscription<LocationCaptureResult>? _locationSubscription;
  FindLocation? _currentLocation;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    if (mappableRecords(widget.records).isEmpty &&
        widget.locationCaptureService != null) {
      final session = widget.locationCaptureService!.startLocationCapture();
      _locationSession = session;
      _locationSubscription = session.updates.listen(_useCurrentLocation);
      unawaited(session.completed.then(_useCurrentLocation));
    }
  }

  @override
  void dispose() {
    unawaited(_locationSubscription?.cancel());
    unawaited(_locationSession?.cancel());
    super.dispose();
  }

  void _useCurrentLocation(LocationCaptureResult result) {
    if (!mounted ||
        _currentLocation != null ||
        !isMappableLocation(result.location)) {
      return;
    }
    _currentLocation = result.location;
    final point = _point(result.location!);
    if (_mapReady) {
      _mapController.move(
        point,
        _zoomForVisibleWidth(context, point.latitude, 12000),
      );
    }
    unawaited(_locationSession?.cancel());
  }

  void _showSearchResult(PlaceSearchResult result) {
    _mapController.move(
      LatLng(result.latitude!, result.longitude!),
      _zoomForVisibleWidth(context, result.latitude!, 3000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final located = mappableRecords(widget.records);
    final points = located.map((record) => _point(record.location!)).toList();
    final omitted = widget.records.length - located.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: points.isEmpty ? _overviewCenter : points.first,
              initialZoom: points.isEmpty ? 5.5 : 17,
              initialCameraFit: points.length > 1
                  ? CameraFit.coordinates(
                      coordinates: points,
                      padding: const EdgeInsets.fromLTRB(48, 120, 48, 72),
                      maxZoom: 17,
                    )
                  : null,
              minZoom: 2,
              maxZoom: 19,
              onMapReady: () {
                _mapReady = true;
                final location = _currentLocation;
                if (location != null) {
                  _mapController.move(
                    _point(location),
                    _zoomForVisibleWidth(context, location.latitude, 12000),
                  );
                }
              },
            ),
            children: [
              _tileLayer(),
              _CameraAnchoredMarkerLayer(
                markers: [
                  for (final record in located)
                    _CameraAnchoredMarker(
                      key: ValueKey('map_marker_${record.id}'),
                      point: _point(record.location!),
                      width: 52,
                      height: 56,
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
              child: Column(
                children: [
                  _PlaceSearchField(
                    geocodingService: widget.geocodingService,
                    onFound: _showSearchResult,
                  ),
                  const SizedBox(height: 6),
                  IgnorePointer(
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
                ],
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
          trailing: widget.onRecordSelected == null
              ? null
              : const Icon(Icons.chevron_right),
          onTap: widget.onRecordSelected == null
              ? null
              : () {
                  Navigator.pop(sheetContext);
                  widget.onRecordSelected!(record);
                },
        ),
      ),
    );
  }
}

class FindLocationPickerResult {
  const FindLocationPickerResult.confirmed(this.location) : skipped = false;
  const FindLocationPickerResult.skipped() : location = null, skipped = true;

  final FindLocation? location;
  final bool skipped;
}

class FindLocationPickerScreen extends StatefulWidget {
  const FindLocationPickerScreen({
    super.key,
    this.initialLocation,
    this.locationUpdates,
    this.allowSkip = false,
    this.confirmLabel = 'Use this location',
    this.locationMessage,
    this.locationCaptureService,
    this.geocodingService,
    this.useCloseLocationView = false,
  });

  final FindLocation? initialLocation;
  final Stream<LocationCaptureResult>? locationUpdates;
  final bool allowSkip;
  final String confirmLabel;
  final String? locationMessage;
  final LocationCaptureService? locationCaptureService;
  final PlaceGeocodingService? geocodingService;
  final bool useCloseLocationView;

  @override
  State<FindLocationPickerScreen> createState() =>
      _FindLocationPickerScreenState();
}

class _FindLocationPickerScreenState extends State<FindLocationPickerScreen> {
  final _mapController = MapController();
  late LatLng _selected;
  late bool _hasChosen;
  FindLocation? _proposedLocation;
  StreamSubscription<LocationCaptureResult>? _locationSubscription;
  LocationCaptureSession? _generalLocationSession;
  StreamSubscription<LocationCaptureResult>? _generalLocationSubscription;
  String? _locationMessage;
  bool _manuallyMoved = false;
  bool _mapReady = false;
  bool _hasCentredOnCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _hasChosen = isMappableLocation(widget.initialLocation);
    _selected = _hasChosen ? _point(widget.initialLocation!) : _overviewCenter;
    _proposedLocation = _hasChosen ? widget.initialLocation : null;
    _locationMessage = widget.locationMessage;
    _locationSubscription = widget.locationUpdates?.listen(_useImprovedFix);
    if (!_hasChosen &&
        widget.locationUpdates == null &&
        widget.locationCaptureService != null) {
      final session = widget.locationCaptureService!.startLocationCapture();
      _generalLocationSession = session;
      _generalLocationSubscription = session.updates.listen(
        _useCurrentLocationForOverview,
      );
      unawaited(session.completed.then(_useCurrentLocationForOverview));
    }
  }

  @override
  void dispose() {
    unawaited(_locationSubscription?.cancel());
    unawaited(_generalLocationSubscription?.cancel());
    unawaited(_generalLocationSession?.cancel());
    super.dispose();
  }

  FindLocation get _result {
    if (!_manuallyMoved && _proposedLocation != null) return _proposedLocation!;
    return FindLocation(
      latitude: _selected.latitude,
      longitude: _selected.longitude,
      horizontalAccuracy: null,
      source: FieldSource.manuallyEntered,
    );
  }

  void _useImprovedFix(LocationCaptureResult result) {
    if (!mounted || _manuallyMoved) return;
    final location = result.location;
    setState(() {
      _locationMessage = result.message ?? _locationMessage;
      if (!isMappableLocation(location)) return;
      _proposedLocation = location;
      _selected = _point(location!);
      _hasChosen = true;
    });
    if (_mapReady && location != null) {
      _mapController.move(
        _selected,
        _zoomForVisibleWidth(
          context,
          _selected.latitude,
          widget.useCloseLocationView ? 200 : 12000,
        ),
      );
    }
  }

  void _useCurrentLocationForOverview(LocationCaptureResult result) {
    if (!mounted ||
        _hasCentredOnCurrentLocation ||
        _manuallyMoved ||
        !isMappableLocation(result.location)) {
      return;
    }
    _hasCentredOnCurrentLocation = true;
    final point = _point(result.location!);
    if (_mapReady) {
      _mapController.move(
        point,
        _zoomForVisibleWidth(context, point.latitude, 12000),
      );
    } else {
      setState(() => _selected = point);
    }
    unawaited(_generalLocationSession?.cancel());
  }

  void _showSearchResult(PlaceSearchResult result) {
    _mapController.move(
      LatLng(result.latitude!, result.longitude!),
      _zoomForVisibleWidth(context, result.latitude!, 3000),
    );
  }

  void _useLocation() {
    if (_hasChosen) {
      Navigator.pop(context, FindLocationPickerResult.confirmed(_result));
    }
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
            child: Text(widget.allowSkip ? 'Confirm' : 'Use'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            key: const Key('location_picker_map'),
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected,
              initialZoom: _hasChosen
                  ? _zoomForVisibleWidth(context, _selected.latitude, 200)
                  : 5.5,
              minZoom: 2,
              maxZoom: 19,
              onMapReady: () {
                _mapReady = true;
                if (_hasCentredOnCurrentLocation) {
                  _mapController.move(
                    _selected,
                    _zoomForVisibleWidth(context, _selected.latitude, 12000),
                  );
                }
              },
              onTap: (_, point) {
                setState(() {
                  _selected = point;
                  _hasChosen = true;
                  _manuallyMoved = true;
                });
              },
            ),
            children: [
              _tileLayer(),
              if (_hasChosen)
                _CameraAnchoredMarkerLayer(
                  markers: [
                    _CameraAnchoredMarker(
                      key: const Key('location_picker_marker'),
                      point: _selected,
                      width: 52,
                      height: 56,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.location_on,
                          size: 52,
                          color: Theme.of(context).colorScheme.primary,
                          shadows: const [
                            Shadow(color: Colors.white, blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const Padding(
                padding: EdgeInsets.only(bottom: 116),
                child: SimpleAttributionWidget(
                  source: Text('OpenStreetMap contributors'),
                ),
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _PlaceSearchField(
                    geocodingService: widget.geocodingService,
                    onFound: _showSearchResult,
                  ),
                  const SizedBox(height: 6),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Confirm the proposed pin or tap the map to move it. You can then pan and zoom without changing the chosen findspot. '
                        'The displayed area is requested from OpenStreetMap.',
                      ),
                    ),
                  ),
                ],
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
                      if (!_manuallyMoved &&
                          _proposedLocation?.horizontalAccuracy != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'GPS accuracy ±${_proposedLocation!.horizontalAccuracy!.toStringAsFixed(1)} m',
                          key: const Key('location_picker_accuracy'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_locationMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _locationMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.allowSkip) ...[
                            Expanded(
                              child: OutlinedButton(
                                key: const Key('skip_map_location_button'),
                                onPressed: () => Navigator.pop(
                                  context,
                                  const FindLocationPickerResult.skipped(),
                                ),
                                child: const Text('Skip location'),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: FilledButton.icon(
                              key: const Key('use_map_location_button'),
                              onPressed: _hasChosen ? _useLocation : null,
                              icon: const Icon(Icons.check),
                              label: Text(widget.confirmLabel),
                            ),
                          ),
                        ],
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

class _PlaceSearchField extends StatefulWidget {
  const _PlaceSearchField({required this.onFound, this.geocodingService});

  final ValueChanged<PlaceSearchResult> onFound;
  final PlaceGeocodingService? geocodingService;

  @override
  State<_PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<_PlaceSearchField> {
  final _controller = TextEditingController();
  late final PlaceGeocodingService _geocodingService;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _geocodingService =
        widget.geocodingService ?? NominatimPlaceGeocodingService();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search([String? _]) async {
    if (_searching) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _searching = true);
    final result = await _geocodingService.search(_controller.text);
    if (!mounted) return;
    setState(() => _searching = false);
    if (result.found) {
      widget.onFound(result);
      final displayName = result.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(displayName)));
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'No matching place was found.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          key: const Key('map_place_search_field'),
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Search place, postcode or address',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    key: const Key('map_place_search_button'),
                    tooltip: 'Search map',
                    onPressed: _search,
                    icon: const Icon(Icons.arrow_forward),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CameraAnchoredMarkerLayer extends StatelessWidget {
  const _CameraAnchoredMarkerLayer({required this.markers});

  final List<_CameraAnchoredMarker> markers;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final marker in markers)
          _positionMarker(camera: camera, marker: marker),
      ],
    );
  }

  Widget _positionMarker({
    required MapCamera camera,
    required _CameraAnchoredMarker marker,
  }) {
    final screenPosition = camera.latLngToScreenOffset(marker.point);
    return Positioned(
      left: screenPosition.dx - (marker.width / 2),
      top: screenPosition.dy - marker.height,
      width: marker.width,
      height: marker.height,
      child: SizedBox(
        key: marker.key,
        width: marker.width,
        height: marker.height,
        child: marker.child,
      ),
    );
  }
}

class _CameraAnchoredMarker {
  const _CameraAnchoredMarker({
    required this.key,
    required this.point,
    required this.width,
    required this.height,
    required this.child,
  });

  final Key key;
  final LatLng point;
  final double width;
  final double height;
  final Widget child;
}

TileLayer _tileLayer() => TileLayer(
  urlTemplate: _tileUrl,
  userAgentPackageName: _tileUserAgent,
  maxNativeZoom: 19,
);
