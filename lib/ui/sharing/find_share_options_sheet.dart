import 'package:flutter/material.dart';

import '../../domain/find_record.dart';
import '../../services/sharing/find_share_workflow.dart';
import '../../services/sharing/findspot_export_precision.dart';

Future<FindShareOptions?> showFindShareOptions(
  BuildContext context,
  List<FindRecord> records,
) => showModalBottomSheet<FindShareOptions>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => FindShareOptionsSheet(records: records),
);

class FindShareOptionsSheet extends StatefulWidget {
  const FindShareOptionsSheet({super.key, required this.records});

  final List<FindRecord> records;

  @override
  State<FindShareOptionsSheet> createState() => _FindShareOptionsSheetState();
}

class _FindShareOptionsSheetState extends State<FindShareOptionsSheet> {
  FindShareFormat _format = FindShareFormat.shareCard;
  bool _includeAllPhotos = false;
  FindspotExportPrecision _findspotPrecision = FindspotExportPrecision.hidden;

  int get _additionalPhotoCount =>
      FindShareWorkflow.additionalPhotoCount(widget.records);

  bool get _showPhotoOption =>
      _format == FindShareFormat.shareCard && _additionalPhotoCount > 0;

  bool get _showPrivacyChoice =>
      _format != FindShareFormat.shareCard || _includeAllPhotos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  'Share ${widget.records.length} '
                  'record${widget.records.length == 1 ? '' : 's'}',
                  key: const Key('share_options_record_count'),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose what to prepare and share.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Text('Format', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                RadioGroup<FindShareFormat>(
                  groupValue: _format,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _format = value;
                      if (_format != FindShareFormat.shareCard) {
                        _includeAllPhotos = false;
                      }
                    });
                  },
                  child: Column(
                    children: [
                      for (final format in FindShareFormat.values)
                        RadioListTile<FindShareFormat>(
                          key: Key('share_format_${format.name}'),
                          value: format,
                          contentPadding: EdgeInsets.zero,
                          secondary: Icon(_formatIcon(format)),
                          title: Text(_formatLabel(format)),
                          subtitle: Text(_formatDescription(format)),
                        ),
                    ],
                  ),
                ),
                if (_showPhotoOption) ...[
                  const Divider(height: 24),
                  SwitchListTile.adaptive(
                    key: const Key('include_all_photos_toggle'),
                    contentPadding: EdgeInsets.zero,
                    value: _includeAllPhotos,
                    onChanged: (value) =>
                        setState(() => _includeAllPhotos = value),
                    title: const Text('Include all photos'),
                    subtitle: Text(
                      'Attach the $_additionalPhotoCount additional '
                      'photo${_additionalPhotoCount == 1 ? '' : 's'}; '
                      'the first photo is already in each Share Card.',
                    ),
                  ),
                ],
                if (_showPrivacyChoice) ...[
                  const Divider(height: 24),
                  Text('Findspot privacy', style: theme.textTheme.titleSmall),
                  RadioGroup<FindspotExportPrecision>(
                    groupValue: _findspotPrecision,
                    onChanged: _selectPrecision,
                    child: Column(
                      children: [
                        RadioListTile<FindspotExportPrecision>(
                          key: const Key('findspot_hidden_option'),
                          value: FindspotExportPrecision.hidden,
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.location_off_outlined),
                          title: const Text('Hidden'),
                          subtitle: Text(
                            _format == FindShareFormat.shareCard
                                ? 'Additional photos are copied with embedded '
                                      'metadata removed.'
                                : _format == FindShareFormat.pdfPhotos
                                ? 'Exact coordinates are hidden and bundled '
                                      'photo copies have metadata removed.'
                                : 'Exact coordinates are not included.',
                          ),
                        ),
                        RadioListTile<FindspotExportPrecision>(
                          key: const Key('findspot_exact_option'),
                          value: FindspotExportPrecision.exact,
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.my_location),
                          title: const Text('Exact findspots'),
                          subtitle: Text(
                            _format == FindShareFormat.shareCard
                                ? 'Attach untouched photo copies only for a '
                                      'trusted recipient.'
                                : 'Include exact coordinates; use only with a '
                                      'trusted recipient.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_format == FindShareFormat.shareCard &&
                      _findspotPrecision == FindspotExportPrecision.exact)
                    Container(
                      key: const Key('exact_photo_warning'),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Original photographs may contain precise location '
                        'metadata.',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
                Container(
                  key: const Key('share_attachment_summary'),
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _attachmentSummary(),
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
                  key: const Key('prepare_and_share_button'),
                  onPressed: () => Navigator.pop(
                    context,
                    FindShareOptions(
                      format: _format,
                      includeAllPhotos:
                          _format == FindShareFormat.shareCard &&
                          _includeAllPhotos,
                      findspotPrecision: _showPrivacyChoice
                          ? _findspotPrecision
                          : FindspotExportPrecision.hidden,
                    ),
                  ),
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Prepare and Share'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectPrecision(FindspotExportPrecision? value) {
    if (value != null) setState(() => _findspotPrecision = value);
  }

  String _attachmentSummary() {
    if (_format == FindShareFormat.shareCard) {
      final cards = widget.records.length;
      final photos = _includeAllPhotos ? _additionalPhotoCount : 0;
      return '$cards Share Card${cards == 1 ? '' : 's'}'
          '${photos == 0 ? '' : ' + $photos photo${photos == 1 ? '' : 's'}'}';
    }
    return switch (_format) {
      FindShareFormat.pdf => '1 PDF',
      FindShareFormat.pdfPhotos => '1 PDF + photos ZIP',
      FindShareFormat.csv => '1 CSV',
      FindShareFormat.shareCard => throw StateError('Handled above'),
    };
  }

  String _formatLabel(FindShareFormat format) => switch (format) {
    FindShareFormat.shareCard => 'Share Card',
    FindShareFormat.pdf => 'PDF',
    FindShareFormat.pdfPhotos => 'PDF + photos',
    FindShareFormat.csv => 'CSV',
  };

  String _formatDescription(FindShareFormat format) => switch (format) {
    FindShareFormat.shareCard => 'Branded image for social media and messaging',
    FindShareFormat.pdf => 'Read-only record report',
    FindShareFormat.pdfPhotos =>
      'ZIP bundle with the report and saveable image files',
    FindShareFormat.csv => 'Editable spreadsheet file',
  };

  IconData _formatIcon(FindShareFormat format) => switch (format) {
    FindShareFormat.shareCard => Icons.image_outlined,
    FindShareFormat.pdf => Icons.picture_as_pdf_outlined,
    FindShareFormat.pdfPhotos => Icons.folder_zip_outlined,
    FindShareFormat.csv => Icons.table_view_outlined,
  };
}
