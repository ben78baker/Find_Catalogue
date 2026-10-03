import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/sharing/find_export_workflow.dart';
import 'package:find_catalogue/services/sharing/findspot_export_precision.dart';
import 'package:find_catalogue/ui/sharing/find_export_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Export offers CSV and the retained PDF plus photos bundle', (
    tester,
  ) async {
    final result = await _openOptions(tester, [_record(1), _record(2)]);

    expect(find.text('Export 2 records'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('PDF + photos'), findsOneWidget);
    expect(find.text('1 CSV - 2 records'), findsOneWidget);
    expect(
      find.byKey(const Key('export_findspot_hidden_option')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('export_findspot_exact_option')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('export_format_pdfPhotos')),
    );
    await tester.tap(find.byKey(const Key('export_format_pdfPhotos')));
    await tester.pumpAndSettle();
    expect(find.text('1 PDF + photos ZIP - 2 records'), findsOneWidget);
    expect(find.textContaining('metadata removed'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('export_findspot_exact_option')),
    );
    await tester.tap(find.byKey(const Key('export_findspot_exact_option')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('may contain location metadata'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('prepare_and_export_button')),
    );
    await tester.tap(find.byKey(const Key('prepare_and_export_button')));
    await tester.pumpAndSettle();
    final options = (await result.future)!;
    expect(options.format, FindExportFormat.pdfPhotos);
    expect(options.findspotPrecision, FindspotExportPrecision.exact);
  });
}

Future<_PendingOptions> _openOptions(
  WidgetTester tester,
  List<FindRecord> records,
) async {
  Future<FindExportOptions?>? result;
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => result = showFindExportOptions(context, records),
            child: const Text('Open export options'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open export options'));
  await tester.pumpAndSettle();
  return _PendingOptions(result!);
}

class _PendingOptions {
  const _PendingOptions(this.future);

  final Future<FindExportOptions?> future;
}

FindRecord _record(int id) => FindRecord(
  id: id,
  logNumber: 'FO-${id.toString().padLeft(6, '0')}',
  method: FindRecordMethod.manual,
  createdAt: DateTime(2026, 8, 20),
  updatedAt: DateTime(2026, 8, 20),
  discoveredAt: null,
  discoveryDateSource: FieldSource.unknown,
  discoveryDateApproximate: false,
  location: null,
  preferredIdentification: 'Test find',
  material: '',
  confidence: IdentificationConfidence.unassessed,
  timelineFromYear: null,
  timelineToYear: null,
  lengthMm: null,
  widthMm: null,
  heightMm: null,
  diameterMm: null,
  thicknessMm: null,
  weightG: null,
  observations: '',
  researchNotes: '',
  sources: '',
  storageLocation: '',
  photos: const [],
);
