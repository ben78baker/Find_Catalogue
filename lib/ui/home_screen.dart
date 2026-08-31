import 'package:flutter/material.dart';

import '../data/find_repository.dart';
import '../domain/find_record.dart';
import '../services/find_record_service.dart';
import '../services/location_capture_service.dart';
import '../services/photo_capture_service.dart';
import 'privacy_support_screen.dart';
import 'record_detail_screen.dart';
import 'record_editor_screen.dart';
import 'records_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
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

  Future<void> _openEditor(
    BuildContext context,
    FindRecordMethod method,
  ) async {
    final recordId = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => RecordEditorScreen(
          method: method,
          recordService: recordService,
          photoCaptureService: photoCaptureService,
          locationCaptureService: locationCaptureService,
        ),
      ),
    );
    if (recordId == null || !context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RecordDetailScreen(
          recordId: recordId,
          repository: repository,
          recordService: recordService,
          photoCaptureService: photoCaptureService,
          locationCaptureService: locationCaptureService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Catalogue'),
        actions: [
          IconButton(
            key: const Key('privacy_support_action'),
            tooltip: 'Privacy & support',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const PrivacySupportScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'A private record of what you find, where you found it, and what you learn later.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),
            _HomeActionCard(
              key: const Key('instant_find_action'),
              icon: Icons.camera_alt_outlined,
              title: 'Instant Find',
              description:
                  'Capture a discovery photo, time and current location while you are in the field.',
              emphasized: true,
              onTap: () => _openEditor(context, FindRecordMethod.instant),
            ),
            const SizedBox(height: 14),
            _HomeActionCard(
              key: const Key('create_find_action'),
              icon: Icons.add_circle_outline,
              title: 'Create Find Record',
              description:
                  'Catalogue an existing find and add its date and location manually.',
              onTap: () => _openEditor(context, FindRecordMethod.manual),
            ),
            const SizedBox(height: 14),
            _HomeActionCard(
              key: const Key('view_records_action'),
              icon: Icons.inventory_2_outlined,
              title: 'View Records',
              description: 'Browse, search and filter the complete catalogue.',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => RecordsScreen(
                    repository: repository,
                    recordService: recordService,
                    photoCaptureService: photoCaptureService,
                    locationCaptureService: locationCaptureService,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: emphasized ? colors.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: emphasized
                      ? colors.primary
                      : colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: emphasized
                      ? colors.onPrimary
                      : colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 5),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
