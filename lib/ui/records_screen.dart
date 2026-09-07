import 'dart:io';

import 'package:flutter/material.dart';

import '../data/find_repository.dart';
import '../domain/find_record.dart';
import '../services/find_record_service.dart';
import '../services/location_capture_service.dart';
import '../services/photo_capture_service.dart';
import 'find_map_screen.dart';
import 'formatters.dart';
import 'record_detail_screen.dart';
import 'share_records.dart';

enum _RecordSort { discoveryNewest, discoveryOldest, logNumber }

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({
    super.key,
    required this.repository,
    required this.recordService,
    required this.photoCaptureService,
    required this.locationCaptureService,
  });

  final FindRepository repository;
  final FindRecordService recordService;
  final PhotoCaptureService photoCaptureService;
  final LocationCaptureService locationCaptureService;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _search = TextEditingController();
  FindRecordMethod? _method;
  IdentificationConfidence? _confidence;
  bool _locationOnly = false;
  _RecordSort _sort = _RecordSort.discoveryNewest;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FindRecord> _apply(List<FindRecord> records) {
    final query = _search.text.trim().toLowerCase();
    final filtered = records.where((record) {
      if (query.isNotEmpty && !record.searchableText.contains(query)) {
        return false;
      }
      if (_method != null && record.method != _method) return false;
      if (_confidence != null && record.confidence != _confidence) return false;
      if (_locationOnly && record.location == null) return false;
      return true;
    }).toList();

    switch (_sort) {
      case _RecordSort.discoveryNewest:
        filtered.sort((a, b) => _recordDate(b).compareTo(_recordDate(a)));
      case _RecordSort.discoveryOldest:
        filtered.sort((a, b) => _recordDate(a).compareTo(_recordDate(b)));
      case _RecordSort.logNumber:
        filtered.sort((a, b) => a.logNumber.compareTo(b.logNumber));
    }
    return filtered;
  }

  DateTime _recordDate(FindRecord record) =>
      record.discoveredAt ?? record.createdAt;

  int get _filterCount =>
      (_method == null ? 0 : 1) +
      (_confidence == null ? 0 : 1) +
      (_locationOnly ? 1 : 0);

  Future<void> _showFilters() async {
    var method = _method;
    var confidence = _confidence;
    var locationOnly = _locationOnly;
    final result =
        await showModalBottomSheet<
          (FindRecordMethod?, IdentificationConfidence?, bool)
        >(
          context: context,
          isScrollControlled: true,
          builder: (context) => StatefulBuilder(
            builder: (context, setModalState) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Filter records',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setModalState(() {
                            method = null;
                            confidence = null;
                            locationOnly = false;
                          }),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FindRecordMethod?>(
                      initialValue: method,
                      decoration: const InputDecoration(
                        labelText: 'Record method',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Any method'),
                        ),
                        DropdownMenuItem(
                          value: FindRecordMethod.instant,
                          child: Text('Instant Find'),
                        ),
                        DropdownMenuItem(
                          value: FindRecordMethod.manual,
                          child: Text('Created later'),
                        ),
                      ],
                      onChanged: (value) => setModalState(() => method = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<IdentificationConfidence?>(
                      initialValue: confidence,
                      decoration: const InputDecoration(
                        labelText: 'Confidence',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Any confidence'),
                        ),
                        ...IdentificationConfidence.values.map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(enumLabel(value)),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => confidence = value),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Only records with a location'),
                      value: locationOnly,
                      onChanged: (value) =>
                          setModalState(() => locationOnly = value),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, (
                        method,
                        confidence,
                        locationOnly,
                      )),
                      child: const Text('Apply filters'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    if (result == null || !mounted) return;
    setState(() {
      _method = result.$1;
      _confidence = result.$2;
      _locationOnly = result.$3;
    });
  }

  void _open(FindRecord record) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RecordDetailScreen(
          recordId: record.id,
          repository: widget.repository,
          recordService: widget.recordService,
          photoCaptureService: widget.photoCaptureService,
          locationCaptureService: widget.locationCaptureService,
        ),
      ),
    );
  }

  void _openMap(List<FindRecord> records) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FindMapScreen(
          title: 'Finds map',
          records: records,
          onRecordSelected: _open,
          locationCaptureService: widget.locationCaptureService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        actions: [
          PopupMenuButton<_RecordSort>(
            initialValue: _sort,
            tooltip: 'Sort records',
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _RecordSort.discoveryNewest,
                child: Text('Newest first'),
              ),
              PopupMenuItem(
                value: _RecordSort.discoveryOldest,
                child: Text('Oldest first'),
              ),
              PopupMenuItem(
                value: _RecordSort.logNumber,
                child: Text('Log number'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<FindRecord>>(
        stream: widget.repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Records could not be loaded: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = _apply(snapshot.data!);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('record_search_field'),
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search every field',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => setState(_search.clear),
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Badge(
                      isLabelVisible: _filterCount > 0,
                      label: Text('$_filterCount'),
                      child: IconButton.filledTonal(
                        tooltip: 'Filter records',
                        onPressed: _showFilters,
                        icon: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? _EmptyRecords(
                        hasCatalogueRecords: snapshot.data!.isNotEmpty,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                        itemCount: records.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) => _RecordTile(
                          record: records[index],
                          onTap: () => _open(records[index]),
                          onShare: () =>
                              shareFindRecords(context, [records[index]]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<List<FindRecord>>(
        stream: widget.repository.watchAll(),
        builder: (context, snapshot) {
          final records = snapshot.hasData
              ? _apply(snapshot.data!)
              : <FindRecord>[];
          final mapped = mappableRecords(records);
          return SafeArea(
            top: false,
            child: BottomAppBar(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    key: const Key('map_record_list_button'),
                    onPressed: mapped.isEmpty ? null : () => _openMap(records),
                    icon: const Icon(Icons.map_outlined),
                    label: Text('Map (${mapped.length})'),
                  ),
                  TextButton.icon(
                    key: const Key('share_record_list_button'),
                    onPressed: records.isEmpty
                        ? null
                        : () => shareFindRecords(
                            context,
                            records,
                            chooseDateRange: true,
                          ),
                    icon: const Icon(Icons.ios_share),
                    label: Text(
                      _search.text.trim().isEmpty && _filterCount == 0
                          ? 'Share records'
                          : 'Share ${records.length} matching',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.onTap,
    required this.onShare,
  });

  final FindRecord record;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final photo = record.primaryPhoto;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 76,
                  child: photo == null
                      ? const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.image_not_supported_outlined),
                        )
                      : Image.file(
                          File(photo.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: Colors.black12,
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.logNumber,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [
                        formatDate(record.discoveredAt ?? record.createdAt),
                        if (record.material.isNotEmpty) record.material,
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Share ${record.logNumber}',
                onPressed: onShare,
                icon: const Icon(Icons.ios_share, size: 20),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords({required this.hasCatalogueRecords});

  final bool hasCatalogueRecords;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasCatalogueRecords
                  ? Icons.search_off
                  : Icons.inventory_2_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              hasCatalogueRecords
                  ? 'No records match that search.'
                  : 'No find records yet.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
