import 'dart:io';

import 'package:flutter/material.dart';

import '../data/find_repository.dart';
import '../domain/find_record.dart';
import '../services/find_record_service.dart';
import '../services/location_capture_service.dart';
import '../services/photo_capture_service.dart';
import 'find_map_screen.dart';
import 'formatters.dart';
import 'record_editor_screen.dart';
import 'share_records.dart';

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({
    super.key,
    required this.recordId,
    required this.repository,
    required this.recordService,
    required this.photoCaptureService,
    required this.locationCaptureService,
  });

  final int recordId;
  final FindRepository repository;
  final FindRecordService recordService;
  final PhotoCaptureService photoCaptureService;
  final LocationCaptureService locationCaptureService;

  Future<void> _edit(BuildContext context, FindRecord record) async {
    await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => RecordEditorScreen(
          method: record.method,
          existingRecord: record,
          recordService: recordService,
          photoCaptureService: photoCaptureService,
          locationCaptureService: locationCaptureService,
        ),
      ),
    );
  }

  void _viewOnMap(BuildContext context, FindRecord record) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            FindMapScreen(title: record.logNumber, records: [record]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FindRecord?>(
      stream: repository.watchById(recordId),
      builder: (context, snapshot) {
        final record = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(record?.logNumber ?? 'Find record'),
            actions: [
              if (record != null)
                IconButton(
                  key: const Key('share_record_button'),
                  tooltip: 'Share record',
                  onPressed: () => shareFindRecords(context, [record]),
                  icon: const Icon(Icons.ios_share),
                ),
              if (record != null)
                TextButton.icon(
                  key: const Key('edit_record_button'),
                  onPressed: () => _edit(context, record),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: _body(context, snapshot),
        );
      },
    );
  }

  Widget _body(BuildContext context, AsyncSnapshot<FindRecord?> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text('The record could not be loaded: ${snapshot.error}'),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final record = snapshot.data;
    if (record == null) return const Center(child: Text('Record not found.'));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
      children: [
        if (record.photos.isNotEmpty)
          SizedBox(
            height: 270,
            child: PageView.builder(
              itemCount: record.photos.length,
              controller: PageController(viewportFraction: 0.9),
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(record.photos[index].path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.broken_image_outlined, size: 44),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Chip(
                          avatar: const Icon(Icons.lock_outline, size: 16),
                          label: Text(enumLabel(record.photos[index].role)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
        Text(
          record.displayTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Chip(label: Text(enumLabel(record.confidence))),
            if (record.material.isNotEmpty) Chip(label: Text(record.material)),
            Chip(
              label: Text(
                record.method == FindRecordMethod.instant
                    ? 'Instant Find'
                    : 'Created later',
              ),
            ),
          ],
        ),
        _DetailSection(
          title: 'Identification',
          rows: [
            _DetailRow(
              'Timeline',
              formatTimelineRange(
                record.timelineFromYear,
                record.timelineToYear,
              ),
            ),
          ],
        ),
        _DetailSection(
          title: 'Discovery',
          rows: [
            _DetailRow(
              'Date',
              record.discoveredAt == null
                  ? 'Unknown'
                  : '${formatDateTime(record.discoveredAt!)}${record.discoveryDateApproximate ? ' (approximate)' : ''}',
            ),
            _DetailRow('Date source', enumLabel(record.discoveryDateSource)),
            if (record.location == null)
              const _DetailRow('Location', 'Unknown')
            else ...[
              _DetailRow(
                'Coordinates',
                '${formatCoordinate(record.location!.latitude)}, ${formatCoordinate(record.location!.longitude)}',
              ),
              _DetailRow(
                'Accuracy',
                record.location!.horizontalAccuracy == null
                    ? 'Not recorded'
                    : '±${record.location!.horizontalAccuracy!.toStringAsFixed(1)} m',
              ),
              _DetailRow('Location source', enumLabel(record.location!.source)),
            ],
          ],
        ),
        if (isMappableLocation(record.location))
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              key: const Key('view_record_map_button'),
              leading: const Icon(Icons.map_outlined),
              title: const Text('View on map'),
              subtitle: const Text('Show this private findspot'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _viewOnMap(context, record),
            ),
          ),
        _DetailSection(
          title: 'Measurements',
          rows: _measurementRows(record),
          emptyMessage: 'No measurements recorded.',
        ),
        _TextSection(title: 'Observations', text: record.observations),
        _TextSection(
          title: 'Research reasoning and notes',
          text: record.researchNotes,
        ),
        _TextSection(title: 'Sources and links', text: record.sources),
        _TextSection(title: 'Physical storage', text: record.storageLocation),
        _DetailSection(
          title: 'Record information',
          rows: [
            _DetailRow('Log number', record.logNumber),
            _DetailRow('Created', formatDateTime(record.createdAt)),
            _DetailRow('Last updated', formatDateTime(record.updatedAt)),
          ],
        ),
      ],
    );
  }

  List<_DetailRow> _measurementRows(FindRecord record) => [
    if (record.lengthMm != null) _DetailRow('Length', '${record.lengthMm} mm'),
    if (record.widthMm != null) _DetailRow('Width', '${record.widthMm} mm'),
    if (record.heightMm != null) _DetailRow('Height', '${record.heightMm} mm'),
    if (record.diameterMm != null)
      _DetailRow('Diameter', '${record.diameterMm} mm'),
    if (record.thicknessMm != null)
      _DetailRow('Thickness', '${record.thicknessMm} mm'),
    if (record.weightG != null) _DetailRow('Weight', '${record.weightG} g'),
  ];
}

class _DetailRow {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.rows,
    this.emptyMessage,
  });

  final String title;
  final List<_DetailRow> rows;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 9),
            if (rows.isEmpty)
              Text(emptyMessage ?? 'Not recorded')
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 112,
                        child: Text(
                          row.label,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: SelectableText(row.value)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 9),
            SelectableText(text),
          ],
        ),
      ),
    );
  }
}
