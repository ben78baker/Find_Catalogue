import 'package:flutter/material.dart';

import '../domain/find_record.dart';
import '../services/sharing/find_export_workflow.dart';
import '../services/sharing/share_artifact.dart';
import 'sharing/find_export_options_sheet.dart';

Future<void> exportFindRecords(
  BuildContext context,
  List<FindRecord> records, {
  FindExportWorkflow? exportWorkflow,
}) async {
  if (records.isEmpty) return;
  final options = await showFindExportOptions(context, records);
  if (options == null || !context.mounted) return;

  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null
      ? const Rect.fromLTWH(0, 0, 1, 1)
      : box.localToGlobal(Offset.zero) & box.size;
  final workflow = exportWorkflow ?? FindExportWorkflow();
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  var progressDialogOpen = true;
  final progressDialog = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      key: Key('export_preparation_dialog'),
      title: Text('Preparing export'),
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 18),
          Expanded(child: Text('Preparing catalogue files...')),
        ],
      ),
    ),
  ).whenComplete(() => progressDialogOpen = false);
  await Future<void>.delayed(Duration.zero);

  Object? preparationError;
  ShareArtifact? artifact;
  try {
    artifact = await workflow.prepare(records, options: options);
  } catch (error) {
    preparationError = error;
  } finally {
    if (progressDialogOpen && rootNavigator.mounted) rootNavigator.pop();
    await progressDialog;
  }

  if (!context.mounted) return;
  if (preparationError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The records could not be exported: $preparationError'),
      ),
    );
    return;
  }
  try {
    await workflow.dispatch(
      artifact!,
      records: records,
      options: options,
      sharePositionOrigin: origin,
    );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The records could not be exported: $error')),
      );
    }
  }
}
