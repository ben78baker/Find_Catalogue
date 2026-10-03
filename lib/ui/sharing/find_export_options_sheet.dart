import 'package:flutter/material.dart';

import '../../domain/find_record.dart';
import '../../services/sharing/find_export_workflow.dart';
import '../../services/sharing/findspot_export_precision.dart';

Future<FindExportOptions?> showFindExportOptions(
  BuildContext context,
  List<FindRecord> records,
) => showModalBottomSheet<FindExportOptions>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => FindExportOptionsSheet(records: records),
);

class FindExportOptionsSheet extends StatefulWidget {
  const FindExportOptionsSheet({super.key, required this.records});

  final List<FindRecord> records;

  @override
  State<FindExportOptionsSheet> createState() => _FindExportOptionsSheetState();
}

class _FindExportOptionsSheetState extends State<FindExportOptionsSheet> {
  FindExportFormat _format = FindExportFormat.csv;
  FindspotExportPrecision _findspotPrecision = FindspotExportPrecision.hidden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordCount = widget.records.length;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Export $recordCount record${recordCount == 1 ? '' : 's'}',
                  key: const Key('export_options_record_count'),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a format for archiving or moving catalogue data.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Text('Format', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                RadioGroup<FindExportFormat>(
                  groupValue: _format,
                  onChanged: (value) {
                    if (value != null) setState(() => _format = value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<FindExportFormat>(
                        key: const Key('export_format_csv'),
                        value: FindExportFormat.csv,
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.table_view_outlined),
                        title: const Text('CSV'),
                        subtitle: const Text(
                          'Structured record data for spreadsheets and other software',
                        ),
                      ),
                      RadioListTile<FindExportFormat>(
                        key: const Key('export_format_pdfPhotos'),
                        value: FindExportFormat.pdfPhotos,
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.folder_zip_outlined),
                        title: const Text('PDF + photos'),
                        subtitle: const Text(
                          'ZIP archive with a report and separately accessible photographs',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Text('Findspot privacy', style: theme.textTheme.titleSmall),
                RadioGroup<FindspotExportPrecision>(
                  groupValue: _findspotPrecision,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _findspotPrecision = value);
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<FindspotExportPrecision>(
                        key: const Key('export_findspot_hidden_option'),
                        value: FindspotExportPrecision.hidden,
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.location_off_outlined),
                        title: const Text('Hidden'),
                        subtitle: Text(
                          _format == FindExportFormat.pdfPhotos
                              ? 'Exact coordinates are hidden and photo copies have metadata removed.'
                              : 'Exact coordinates are not included.',
                        ),
                      ),
                      RadioListTile<FindspotExportPrecision>(
                        key: const Key('export_findspot_exact_option'),
                        value: FindspotExportPrecision.exact,
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.my_location),
                        title: const Text('Exact findspots'),
                        subtitle: Text(
                          _format == FindExportFormat.pdfPhotos
                              ? 'Includes exact coordinates and original photographs, which may contain location metadata.'
                              : 'Include exact coordinates; keep the export secure.',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  key: const Key('export_attachment_summary'),
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _format == FindExportFormat.csv
                              ? '1 CSV - $recordCount record${recordCount == 1 ? '' : 's'}'
                              : '1 PDF + photos ZIP - $recordCount record${recordCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  key: const Key('prepare_and_export_button'),
                  onPressed: () => Navigator.pop(
                    context,
                    FindExportOptions(
                      format: _format,
                      findspotPrecision: _findspotPrecision,
                    ),
                  ),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Prepare and Export'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
