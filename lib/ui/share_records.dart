import 'package:flutter/material.dart';

import '../domain/find_record.dart';
import '../services/record_export_service.dart';
import 'formatters.dart';

Future<void> shareFindRecords(
  BuildContext context,
  List<FindRecord> records, {
  bool chooseDateRange = false,
}) async {
  if (records.isEmpty) return;
  var selected = records;
  if (chooseDateRange) {
    final range = await _showPeriodPicker(context, records);
    if (range == null || !context.mounted) return;
    selected = records.where((record) {
      final date = _dateOnly(record.discoveredAt ?? record.createdAt);
      return !date.isBefore(range.start) && !date.isAfter(range.end);
    }).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching records in that period.')),
      );
      return;
    }
  }

  final format = await _showFormatPicker(context, selected.length);
  if (format == null || !context.mounted) return;
  final precision = await _showFindspotPicker(context);
  if (precision == null || !context.mounted) return;

  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null
      ? const Rect.fromLTWH(0, 0, 1, 1)
      : box.localToGlobal(Offset.zero) & box.size;
  try {
    await RecordExportService().share(
      selected,
      format: format,
      findspotPrecision: precision,
      sharePositionOrigin: origin,
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('The records could not be shared: $error')),
    );
  }
}

Future<DateTimeRange?> _showPeriodPicker(
  BuildContext context,
  List<FindRecord> records,
) {
  final dates =
      records
          .map((record) => _dateOnly(record.discoveredAt ?? record.createdAt))
          .toList()
        ..sort();
  final initial = DateTimeRange(start: dates.first, end: dates.last);
  return showModalBottomSheet<DateTimeRange>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      var from = initial.start;
      var to = initial.end;
      return StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Share matching records',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${records.length} records match the current search and filters.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, initial),
                  icon: const Icon(Icons.select_all),
                  label: const Text('Share all matching records'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DateChoice(
                        label: 'From',
                        date: from,
                        onChanged: (value) => setModalState(() => from = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateChoice(
                        label: 'To',
                        date: to,
                        onChanged: (value) => setModalState(() => to = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final start = from.isBefore(to) ? from : to;
                        final end = from.isBefore(to) ? to : from;
                        Navigator.pop(
                          context,
                          DateTimeRange(start: start, end: end),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<RecordExportFormat?> _showFormatPicker(
  BuildContext context,
  int count,
) => showModalBottomSheet<RecordExportFormat>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Share $count record${count == 1 ? '' : 's'}'),
            subtitle: const Text('Choose a file format'),
          ),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: const Text('CSV (editable)'),
            onTap: () => Navigator.pop(context, RecordExportFormat.csv),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('PDF (read-only)'),
            onTap: () => Navigator.pop(context, RecordExportFormat.pdf),
          ),
          ListTile(
            leading: const Icon(Icons.folder_zip_outlined),
            title: const Text('PDF + photos'),
            subtitle: const Text(
              'ZIP bundle with the report and saveable image files',
            ),
            onTap: () => Navigator.pop(context, RecordExportFormat.pdfBundle),
          ),
        ],
      ),
    ),
  ),
);

Future<FindspotExportPrecision?> _showFindspotPicker(BuildContext context) =>
    showModalBottomSheet<FindspotExportPrecision>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Findspot privacy'),
                subtitle: Text(
                  'Choose what location detail this file contains.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.location_off_outlined),
                title: const Text('Hide exact locations'),
                subtitle: const Text(
                  'Recommended; photo bundles also remove image metadata',
                ),
                onTap: () =>
                    Navigator.pop(context, FindspotExportPrecision.hidden),
              ),
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('Include exact coordinates'),
                subtitle: const Text('Use only with a trusted recipient'),
                onTap: () =>
                    Navigator.pop(context, FindspotExportPrecision.exact),
              ),
            ],
          ),
        ),
      ),
    );

class _DateChoice extends StatelessWidget {
  const _DateChoice({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (selected != null) onChanged(_dateOnly(selected));
      },
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text('$label\n${formatDate(date)}', textAlign: TextAlign.center),
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
