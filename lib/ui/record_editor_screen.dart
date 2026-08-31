import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/find_record.dart';
import '../services/find_record_service.dart';
import '../services/location_capture_service.dart';
import '../services/photo_capture_service.dart';
import 'find_map_screen.dart';
import 'formatters.dart';

class RecordEditorScreen extends StatefulWidget {
  const RecordEditorScreen({
    super.key,
    required this.method,
    required this.recordService,
    required this.photoCaptureService,
    required this.locationCaptureService,
    this.existingRecord,
  });

  final FindRecordMethod method;
  final FindRecordService recordService;
  final PhotoCaptureService photoCaptureService;
  final LocationCaptureService locationCaptureService;
  final FindRecord? existingRecord;

  @override
  State<RecordEditorScreen> createState() => _RecordEditorScreenState();
}

class _RecordEditorScreenState extends State<RecordEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identification = TextEditingController();
  final _material = TextEditingController();
  final _timelineFrom = TextEditingController();
  final _timelineTo = TextEditingController();
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _diameter = TextEditingController();
  final _thickness = TextEditingController();
  final _weight = TextEditingController();
  final _observations = TextEditingController();
  final _research = TextEditingController();
  final _sources = TextEditingController();
  final _storage = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _accuracy = TextEditingController();

  final List<PhotoDraft> _photos = [];
  late IdentificationConfidence _confidence;
  late DateTime? _discoveredAt;
  late FieldSource _dateSource;
  late bool _dateApproximate;
  FindLocation? _location;
  String? _locationMessage;
  bool _capturingLocation = false;
  bool _saving = false;
  bool _showAdditionalFields = false;
  bool _instantCaptureStarted = false;

  bool get _editing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;
    _confidence = record?.confidence ?? IdentificationConfidence.unassessed;
    _discoveredAt =
        record?.discoveredAt ??
        (widget.method == FindRecordMethod.instant ? DateTime.now() : null);
    _dateSource =
        record?.discoveryDateSource ??
        (widget.method == FindRecordMethod.instant
            ? FieldSource.deviceCaptured
            : FieldSource.unknown);
    _dateApproximate = record?.discoveryDateApproximate ?? false;
    _location = record?.location;
    if (record != null) {
      _identification.text = record.preferredIdentification;
      _material.text = record.material;
      _timelineFrom.text = _integer(record.timelineFromYear);
      _timelineTo.text = _integer(record.timelineToYear);
      _length.text = _number(record.lengthMm);
      _width.text = _number(record.widthMm);
      _height.text = _number(record.heightMm);
      _diameter.text = _number(record.diameterMm);
      _thickness.text = _number(record.thicknessMm);
      _weight.text = _number(record.weightG);
      _observations.text = record.observations;
      _research.text = record.researchNotes;
      _sources.text = record.sources;
      _storage.text = record.storageLocation;
      _photos.addAll(record.photos.map(PhotoDraft.fromStored));
      _syncLocationFields(record.location);
      _showAdditionalFields =
          record.sources.isNotEmpty || record.storageLocation.isNotEmpty;
    }

    if (!_editing && widget.method == FindRecordMethod.instant) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startInstantFind());
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _identification,
      _material,
      _timelineFrom,
      _timelineTo,
      _length,
      _width,
      _height,
      _diameter,
      _thickness,
      _weight,
      _observations,
      _research,
      _sources,
      _storage,
      _latitude,
      _longitude,
      _accuracy,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startInstantFind() async {
    if (_instantCaptureStarted) return;
    _instantCaptureStarted = true;
    _captureLocation();
    final captured = await _addPhoto(camera: true, discovery: true);
    if (!captured && mounted) Navigator.of(context).pop();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _capturingLocation = true;
      _locationMessage = null;
    });
    final result = await widget.locationCaptureService.captureCurrentLocation();
    if (!mounted) return;
    setState(() {
      _capturingLocation = false;
      _location = result.location;
      _locationMessage = result.message;
      _syncLocationFields(result.location);
    });
  }

  void _syncLocationFields(FindLocation? location) {
    _latitude.text = location == null
        ? ''
        : formatCoordinate(location.latitude);
    _longitude.text = location == null
        ? ''
        : formatCoordinate(location.longitude);
    _accuracy.text = location?.horizontalAccuracy == null
        ? ''
        : location!.horizontalAccuracy!.toStringAsFixed(1);
  }

  Future<bool> _addPhoto({required bool camera, bool discovery = false}) async {
    final picked = camera
        ? await widget.photoCaptureService.takePhoto()
        : await widget.photoCaptureService.choosePhoto();
    if (picked == null || !mounted) return false;
    setState(() {
      _photos.add(
        PhotoDraft.fromPicked(
          picked,
          role: discovery || _photos.isEmpty
              ? FindPhotoRole.discovery
              : FindPhotoRole.detail,
          isOriginalEvidence: true,
          sortOrder: _photos.length,
        ),
      );
    });
    return true;
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _discoveredAt ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _discoveredAt = selected;
      _dateSource = FieldSource.manuallyEntered;
    });
  }

  Future<void> _pickLocationOnMap() async {
    final current = _manualLocation();
    final initial = isMappableLocation(current) ? current : null;
    final selected = await Navigator.of(context).push<FindLocation>(
      MaterialPageRoute(
        builder: (_) => FindLocationPickerScreen(initialLocation: initial),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _location = selected;
      _locationMessage = 'Location placed manually on the map.';
      _syncLocationFields(selected);
    });
  }

  FindLocation? _manualLocation() {
    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    if (latitude == null || longitude == null) return _location;
    return FindLocation(
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracy: double.tryParse(_accuracy.text.trim()),
      altitude: _location?.altitude,
      source:
          _location?.source == FieldSource.deviceCaptured &&
              _latitude.text == formatCoordinate(_location!.latitude) &&
              _longitude.text == formatCoordinate(_location!.longitude)
          ? FieldSource.deviceCaptured
          : FieldSource.manuallyEntered,
    );
  }

  FindDraft _draft() => FindDraft(
    method: widget.method,
    discoveredAt: _discoveredAt,
    discoveryDateSource: _dateSource,
    discoveryDateApproximate: _dateApproximate,
    location: _manualLocation(),
    preferredIdentification: _identification.text,
    material: _material.text,
    confidence: _confidence,
    timelineFromYear: _parseInteger(_timelineFrom),
    timelineToYear: _parseInteger(_timelineTo),
    lengthMm: _parse(_length),
    widthMm: _parse(_width),
    heightMm: _parse(_height),
    diameterMm: _parse(_diameter),
    thicknessMm: _parse(_thickness),
    weightG: _parse(_weight),
    observations: _observations.text,
    researchNotes: _research.text,
    sources: _sources.text,
    storageLocation: _storage.text,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photograph first.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final existing = widget.existingRecord;
      if (existing == null) {
        final created = await widget.recordService.create(_draft(), _photos);
        if (mounted) Navigator.of(context).pop(created.id);
      } else {
        await widget.recordService.update(existing.id, _draft(), _photos);
        if (mounted) Navigator.of(context).pop(existing.id);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The record could not be saved: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final manual = widget.method == FindRecordMethod.manual;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editing
              ? 'Edit ${widget.existingRecord!.logNumber}'
              : manual
              ? 'Create Find Record'
              : 'Instant Find',
        ),
        actions: [
          TextButton(
            key: const Key('save_record_button'),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            if (!_editing) _IntroBanner(method: widget.method),
            _Section(
              title: 'Photographs',
              subtitle:
                  'Original images are preserved. You can change their catalogue role later.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_photos.isEmpty)
                    const _EmptyPhotos()
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, index) => _PhotoDraftCard(
                          photo: _photos[index],
                          canRemove: _photos[index].id == null,
                          onRoleChanged: (role) =>
                              setState(() => _photos[index].role = role),
                          onRemove: () =>
                              setState(() => _photos.removeAt(index)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _addPhoto(camera: true),
                        icon: Icon(
                          widget.photoCaptureService.supportsCamera
                              ? Icons.camera_alt_outlined
                              : Icons.folder_open,
                        ),
                        label: Text(
                          widget.photoCaptureService.supportsCamera
                              ? 'Take photo'
                              : 'Choose photo',
                        ),
                      ),
                      if (widget.photoCaptureService.supportsCamera)
                        OutlinedButton.icon(
                          onPressed: () => _addPhoto(camera: false),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Photo library'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Discovery evidence',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _discoveredAt == null
                              ? 'Discovery date unknown'
                              : formatDateTime(_discoveredAt!),
                        ),
                      ),
                      if (manual)
                        TextButton.icon(
                          onPressed: _chooseDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            _discoveredAt == null ? 'Add date' : 'Change',
                          ),
                        ),
                    ],
                  ),
                  if (manual && _discoveredAt != null)
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Date is approximate'),
                            value: _dateApproximate,
                            onChanged: (value) => setState(
                              () => _dateApproximate = value ?? false,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _discoveredAt = null;
                            _dateSource = FieldSource.unknown;
                            _dateApproximate = false;
                          }),
                          child: const Text('Clear date'),
                        ),
                      ],
                    ),
                  const Divider(),
                  if (_capturingLocation)
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircularProgressIndicator(),
                      title: Text('Capturing location…'),
                    )
                  else ...[
                    if (_location != null)
                      Text(
                        'Location captured to ±${_location!.horizontalAccuracy?.toStringAsFixed(1) ?? '?'} m',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (_locationMessage != null)
                      Text(
                        _locationMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _captureLocation,
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            _location == null
                                ? 'Use current location'
                                : 'Refresh location',
                          ),
                        ),
                        if (manual)
                          OutlinedButton.icon(
                            key: const Key('pinpoint_location_button'),
                            onPressed: _pickLocationOnMap,
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: const Text('Pinpoint on map'),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          controller: _latitude,
                          label: 'Latitude',
                          signed: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NumberField(
                          controller: _longitude,
                          label: 'Longitude',
                          signed: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _NumberField(
                    controller: _accuracy,
                    label: 'Accuracy (metres, optional)',
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Basic details',
              child: Column(
                children: [
                  TextFormField(
                    controller: _identification,
                    decoration: const InputDecoration(
                      labelText: 'Preferred identification',
                      hintText: 'Leave blank if unidentified',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _material,
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      hintText: 'e.g. copper alloy, lead, iron',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<IdentificationConfidence>(
                    initialValue: _confidence,
                    decoration: const InputDecoration(
                      labelText: 'Identification confidence',
                    ),
                    items: IdentificationConfidence.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(enumLabel(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => _confidence =
                          value ?? IdentificationConfidence.unassessed,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _YearField(
                          controller: _timelineFrom,
                          label: 'Timeline from',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _YearField(
                          controller: _timelineTo,
                          label: 'Timeline to',
                          rangeValidator: () {
                            final from = _parseInteger(_timelineFrom);
                            final to = _parseInteger(_timelineTo);
                            return timelineRangeIsValid(from, to)
                                ? null
                                : 'Must be after From';
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Use negative years for BCE, e.g. -50.'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Size and weight',
              subtitle: 'Enter only the measurements that suit this object.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          controller: _length,
                          label: 'Length (mm)',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NumberField(
                          controller: _width,
                          label: 'Width (mm)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          controller: _diameter,
                          label: 'Diameter (mm)',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NumberField(
                          controller: _thickness,
                          label: 'Thickness (mm)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          controller: _height,
                          label: 'Height (mm)',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NumberField(
                          controller: _weight,
                          label: 'Weight (g)',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Notes and research',
              child: Column(
                children: [
                  TextFormField(
                    controller: _observations,
                    minLines: 3,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Observations',
                      hintText: 'What you can see, without interpretation',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _research,
                    minLines: 3,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Research reasoning and notes',
                      hintText:
                          'Possibilities, comparisons and why your view changed',
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                initiallyExpanded: _showAdditionalFields,
                onExpansionChanged: (value) => _showAdditionalFields = value,
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('More details'),
                subtitle: const Text('Optional fields for a fuller record'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  TextFormField(
                    controller: _sources,
                    minLines: 2,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Sources and links',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _storage,
                    decoration: const InputDecoration(
                      labelText: 'Physical storage location',
                      hintText: 'e.g. Finds box 2, tray B',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Text(_editing ? 'Save changes' : 'Create record'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  int? _parseInteger(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

  String _number(double? value) => value?.toString() ?? '';

  String _integer(int? value) => value?.toString() ?? '';
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.method});

  final FindRecordMethod method;

  @override
  Widget build(BuildContext context) {
    final instant = method == FindRecordMethod.instant;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(instant ? Icons.bolt : Icons.history),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instant
                  ? 'Time and location are being captured now. Add the essentials and save; research can come later.'
                  : 'Use an existing photo and add what is known. Unknown or approximate discovery information can be left blank.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyPhotos extends StatelessWidget {
  const _EmptyPhotos();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(Icons.add_a_photo_outlined, size: 34),
          SizedBox(height: 8),
          Text('A photograph starts every find record.'),
        ],
      ),
    );
  }
}

class _PhotoDraftCard extends StatelessWidget {
  const _PhotoDraftCard({
    required this.photo,
    required this.canRemove,
    required this.onRoleChanged,
    required this.onRemove,
  });

  final PhotoDraft photo;
  final bool canRemove;
  final ValueChanged<FindPhotoRole> onRoleChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(photo.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Colors.black12,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  if (canRemove)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          DropdownButton<FindPhotoRole>(
            value: photo.role,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: FindPhotoRole.values
                .map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(enumLabel(role)),
                  ),
                )
                .toList(),
            onChanged: (role) {
              if (role != null) onRoleChanged(role);
            },
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.signed = false,
  });

  final TextEditingController controller;
  final String label;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: signed,
      ),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty || double.tryParse(text) != null) return null;
        return 'Enter a number';
      },
    );
  }
}

class _YearField extends StatelessWidget {
  const _YearField({
    required this.controller,
    required this.label,
    this.rangeValidator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function()? rangeValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      decoration: InputDecoration(labelText: label, hintText: 'Year'),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isNotEmpty && int.tryParse(text) == null) {
          return 'Enter a whole year';
        }
        return rangeValidator?.call();
      },
    );
  }
}
