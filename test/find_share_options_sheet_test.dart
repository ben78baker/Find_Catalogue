import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/sharing/find_share_workflow.dart';
import 'package:find_catalogue/services/sharing/findspot_export_precision.dart';
import 'package:find_catalogue/ui/share_records.dart';
import 'package:find_catalogue/ui/sharing/find_share_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('date-range sharing preserves matching record order', () {
    final records = [
      _record(1, discoveredAt: DateTime(2026, 8, 10)),
      _record(2, discoveredAt: DateTime(2026, 8, 20)),
      _record(3, discoveredAt: DateTime(2026, 8, 30)),
    ];

    final selected = recordsInShareDateRange(
      records,
      DateTimeRange(start: DateTime(2026, 8, 15), end: DateTime(2026, 8, 30)),
    );

    expect(selected.map((record) => record.id), [2, 3]);
  });

  testWidgets('Share Card is the default and all Stage 3 formats are shown', (
    tester,
  ) async {
    final result = await _openOptions(tester, [_record(1, photoCount: 1)]);

    expect(find.text('Share 1 record'), findsOneWidget);
    expect(find.text('Share Card'), findsOneWidget);
    expect(
      find.text('Branded image for social media and messaging'),
      findsOneWidget,
    );
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('PDF + photos'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.byKey(const Key('include_all_photos_toggle')), findsNothing);
    expect(find.byKey(const Key('findspot_hidden_option')), findsNothing);
    expect(find.text('1 Share Card'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('prepare_and_share_button')),
    );
    await tester.tap(find.byKey(const Key('prepare_and_share_button')));
    await tester.pumpAndSettle();

    final options = (await result.future)!;
    expect(options.format, FindShareFormat.shareCard);
    expect(options.includeAllPhotos, isFalse);
    expect(options.findspotPrecision, FindspotExportPrecision.hidden);
  });

  testWidgets('additional photos reveal the photo and privacy choices', (
    tester,
  ) async {
    final result = await _openOptions(tester, [_record(1, photoCount: 4)]);

    expect(find.byKey(const Key('include_all_photos_toggle')), findsOneWidget);
    expect(find.byKey(const Key('findspot_hidden_option')), findsNothing);
    await tester.tap(find.byKey(const Key('include_all_photos_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('1 Share Card + 3 photos'), findsOneWidget);
    expect(find.byKey(const Key('findspot_hidden_option')), findsOneWidget);
    expect(find.byKey(const Key('findspot_exact_option')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('findspot_exact_option')));
    await tester.tap(find.byKey(const Key('findspot_exact_option')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('exact_photo_warning')), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('prepare_and_share_button')),
    );
    await tester.tap(find.byKey(const Key('prepare_and_share_button')));
    await tester.pumpAndSettle();
    final options = (await result.future)!;

    expect(options.format, FindShareFormat.shareCard);
    expect(options.includeAllPhotos, isTrue);
    expect(options.findspotPrecision, FindspotExportPrecision.exact);
  });

  testWidgets('legacy formats retain privacy choices and record count', (
    tester,
  ) async {
    final result = await _openOptions(tester, [
      for (var id = 1; id <= 5; id++) _record(id, photoCount: 2),
    ]);

    expect(find.text('Share 5 records'), findsOneWidget);
    expect(find.text('5 Share Cards'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('include_all_photos_toggle')),
    );
    await tester.tap(find.byKey(const Key('include_all_photos_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('5 Share Cards + 5 photos'), findsOneWidget);

    for (final format in const [
      FindShareFormat.pdf,
      FindShareFormat.csv,
      FindShareFormat.pdfPhotos,
    ]) {
      await tester.ensureVisible(
        find.byKey(Key('share_format_${format.name}')),
      );
      await tester.tap(find.byKey(Key('share_format_${format.name}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('findspot_hidden_option')), findsOneWidget);
      expect(find.byKey(const Key('findspot_exact_option')), findsOneWidget);
    }

    expect(find.byKey(const Key('include_all_photos_toggle')), findsNothing);
    expect(find.text('1 PDF + photos ZIP'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('prepare_and_share_button')),
    );
    await tester.tap(find.byKey(const Key('prepare_and_share_button')));
    await tester.pumpAndSettle();
    final options = (await result.future)!;

    expect(options.format, FindShareFormat.pdfPhotos);
    expect(options.includeAllPhotos, isFalse);
    expect(options.findspotPrecision, FindspotExportPrecision.hidden);
  });
}

Future<_PendingOptions> _openOptions(
  WidgetTester tester,
  List<FindRecord> records,
) async {
  Future<FindShareOptions?>? result;
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => result = showFindShareOptions(context, records),
            child: const Text('Open share options'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open share options'));
  await tester.pumpAndSettle();
  return _PendingOptions(result!);
}

class _PendingOptions {
  const _PendingOptions(this.future);

  final Future<FindShareOptions?> future;
}

FindRecord _record(int id, {int photoCount = 0, DateTime? discoveredAt}) {
  final now = DateTime(2026, 8, 30, 12);
  return FindRecord(
    id: id,
    logNumber: 'FO-${id.toString().padLeft(6, '0')}',
    method: FindRecordMethod.manual,
    createdAt: now,
    updatedAt: now,
    discoveredAt: discoveredAt ?? DateTime(2026, 8, 20),
    discoveryDateSource: FieldSource.manuallyEntered,
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
    photos: [
      for (var index = 0; index < photoCount; index++)
        FindPhoto(
          id: index + 1,
          path: '/photos/$id-${index + 1}.jpg',
          role: FindPhotoRole.values[index % FindPhotoRole.values.length],
          source: FindPhotoSource.camera,
          createdAt: DateTime(2026, 8, 20),
          isOriginalEvidence: index == 0,
          sortOrder: index,
        ),
    ],
  );
}
