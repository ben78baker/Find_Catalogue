import 'package:flutter/material.dart';

import 'data/find_repository.dart';
import 'services/find_record_service.dart';
import 'services/location_capture_service.dart';
import 'services/photo_capture_service.dart';
import 'ui/home_screen.dart';

class FindCatalogueApp extends StatelessWidget {
  const FindCatalogueApp({
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
  Widget build(BuildContext context) {
    const seed = Color(0xFF465E3B);
    final colors = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF7F5EF),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find Catalogue',
      theme: ThemeData(
        colorScheme: colors,
        scaffoldBackgroundColor: colors.surface,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.surfaceContainerLowest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: HomeScreen(
        repository: repository,
        recordService: recordService,
        photoCaptureService: photoCaptureService,
        locationCaptureService: locationCaptureService,
      ),
    );
  }
}
