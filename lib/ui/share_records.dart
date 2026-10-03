import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../domain/find_record.dart';
import '../services/sharing/find_share_workflow.dart';
import '../services/sharing/share_artifact.dart';
import 'formatters.dart';
import 'sharing/find_share_options_sheet.dart';

Future<void> shareFindRecords(
  BuildContext context,
  List<FindRecord> records, {
  bool chooseDateRange = false,
  FindShareWorkflow? shareWorkflow,
}) async {
  if (records.isEmpty) return;
  var selected = records;
  if (chooseDateRange) {
    final range = await _showPeriodPicker(context, records);
    if (range == null || !context.mounted) return;
    selected = recordsInShareDateRange(records, range);
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching records in that period.')),
      );
      return;
    }
  }

  final options = await showFindShareOptions(context, selected);
  if (options == null || !context.mounted) return;

  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null
      ? const Rect.fromLTWH(0, 0, 1, 1)
      : box.localToGlobal(Offset.zero) & box.size;
  final workflow = shareWorkflow ?? FindShareWorkflow();
  final progress = ValueNotifier(
    FindShareProgress(
      completedRecords: 0,
      totalRecords: selected.length,
      message: 'Preparing share files',
    ),
  );
  final cancellationToken = FindShareCancellationToken();
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  var progressDialogOpen = true;
  final progressDialog = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SharePreparationDialog(
      progress: progress,
      cancellationToken: cancellationToken,
      canCancel: options.format != FindShareFormat.csv && selected.length > 1,
    ),
  ).whenComplete(() => progressDialogOpen = false);
  await Future<void>.delayed(Duration.zero);

  List<ShareArtifact>? artifacts;
  Object? preparationError;
  var cancelled = false;
  try {
    artifacts = await workflow.prepare(
      selected,
      options: options,
      cancellationToken: cancellationToken,
      onProgress: (value) => progress.value = value,
    );
  } on FindSharePreparationCancelled {
    cancelled = true;
  } catch (error) {
    preparationError = error;
  } finally {
    if (progressDialogOpen && rootNavigator.mounted) rootNavigator.pop();
    await progressDialog;
    progress.dispose();
  }

  if (!context.mounted) return;
  if (cancelled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share preparation cancelled.')),
    );
    return;
  }
  if (preparationError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The records could not be shared: $preparationError'),
      ),
    );
    return;
  }

  try {
    await workflow.dispatch(
      artifacts!,
      records: selected,
      options: options,
      sharePositionOrigin: origin,
    );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The records could not be shared: $error')),
      );
    }
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

List<FindRecord> recordsInShareDateRange(
  List<FindRecord> records,
  DateTimeRange range,
) => records.where((record) {
  final date = _dateOnly(record.discoveredAt ?? record.createdAt);
  return !date.isBefore(range.start) && !date.isAfter(range.end);
}).toList();

class _SharePreparationDialog extends StatefulWidget {
  const _SharePreparationDialog({
    required this.progress,
    required this.cancellationToken,
    required this.canCancel,
  });

  final ValueListenable<FindShareProgress> progress;
  final FindShareCancellationToken cancellationToken;
  final bool canCancel;

  @override
  State<_SharePreparationDialog> createState() =>
      _SharePreparationDialogState();
}

class _SharePreparationDialogState extends State<_SharePreparationDialog> {
  var _cancelling = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('share_preparation_dialog'),
      title: const Text('Preparing share'),
      content: ValueListenableBuilder<FindShareProgress>(
        valueListenable: widget.progress,
        builder: (context, progress, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress.fraction),
            const SizedBox(height: 14),
            Text(
              _cancelling
                  ? 'Cancelling after the current record…'
                  : progress.message,
              key: const Key('share_preparation_message'),
            ),
            if (progress.totalRecords > 1) ...[
              const SizedBox(height: 6),
              Text(
                '${progress.completedRecords} of '
                '${progress.totalRecords} records prepared',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.canCancel)
          TextButton(
            key: const Key('cancel_share_preparation_button'),
            onPressed: _cancelling
                ? null
                : () {
                    widget.cancellationToken.cancel();
                    setState(() => _cancelling = true);
                  },
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}
