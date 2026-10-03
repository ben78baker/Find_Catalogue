import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum FindShareCardPhotoStatus { available, none, unavailable }

class FindShareCardFact {
  const FindShareCardFact({required this.label, required this.value});

  final String label;
  final String value;
}

class FindShareCardData {
  const FindShareCardData({
    required this.logNumber,
    required this.title,
    required this.discoveryDate,
    required this.facts,
    required this.measurements,
    required this.weight,
    required this.observations,
    required this.heroPhotoPath,
    required this.photoStatus,
  });

  static const appName = 'Find Catalogue';
  static const privacyLabel = 'Findspot not shared';

  final String logNumber;
  final String title;
  final String? discoveryDate;
  final List<FindShareCardFact> facts;
  final String? measurements;
  final String? weight;
  final String? observations;
  final String? heroPhotoPath;
  final FindShareCardPhotoStatus photoStatus;

  FindShareCardData withUnavailablePhoto() => FindShareCardData(
    logNumber: logNumber,
    title: title,
    discoveryDate: discoveryDate,
    facts: facts,
    measurements: measurements,
    weight: weight,
    observations: observations,
    heroPhotoPath: null,
    photoStatus: FindShareCardPhotoStatus.unavailable,
  );
}

class FindShareCard extends StatelessWidget {
  const FindShareCard({
    super.key,
    required this.data,
    this.heroImage,
    this.brandingImage,
  });

  static const logicalSize = Size(360, 450);
  static const outputPixelRatio = 3.0;
  static const outputWidth = 1080;
  static const outputHeight = 1350;
  static const appIconAsset = 'assets/branding/find_catalogue_icon_1024.png';
  static const heroHeight = 160.0;
  static const fullPhotoInsetSize = Size(96, 72);

  static const _olive = Color(0xFF465E3B);
  static const _warmSurface = Color(0xFFF7F5EF);
  static const _outline = Color(0xFFD8D5CA);
  static const _onSurface = Color(0xFF25251F);
  static const _onSurfaceVariant = Color(0xFF64645B);
  static const _tonalSurface = Color(0xFFE2E9DE);

  final FindShareCardData data;
  final ui.Image? heroImage;
  final ui.Image? brandingImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: logicalSize,
      child: ColoredBox(
        color: _warmSurface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _outline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BrandHeader(brandingImage: brandingImage),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _HeroPhotograph(
                      image: heroImage,
                      photoStatus: data.photoStatus,
                    ),
                  ),
                  Expanded(child: _RecordSummary(data: data)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.brandingImage});

  final ui.Image? brandingImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: brandingImage == null
                  ? Image.asset(
                      FindShareCard.appIconAsset,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _BrandingFallback(),
                    )
                  : RawImage(
                      image: brandingImage,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 9),
            const Text(
              FindShareCardData.appName,
              style: TextStyle(
                color: FindShareCard._olive,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPhotograph extends StatelessWidget {
  const _HeroPhotograph({required this.image, required this.photoStatus});

  final ui.Image? image;
  final FindShareCardPhotoStatus photoStatus;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: FindShareCard.heroHeight,
        child: image == null
            ? _PhotoPlaceholder(photoStatus: photoStatus)
            : Stack(
                fit: StackFit.expand,
                children: [
                  RawImage(
                    key: const Key('find_share_card_hero_image'),
                    image: image,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.medium,
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      key: const Key('find_share_card_full_photo_inset'),
                      width: FindShareCard.fullPhotoInsetSize.width,
                      height: FindShareCard.fullPhotoInsetSize.height,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: ColoredBox(
                          color: Colors.white,
                          child: RawImage(
                            key: const Key('find_share_card_full_photo_image'),
                            image: image,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.medium,
                          ),
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

class _BrandingFallback extends StatelessWidget {
  const _BrandingFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: FindShareCard._tonalSurface,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(
          Icons.inventory_2_outlined,
          color: FindShareCard._olive,
          size: 18,
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.photoStatus});

  final FindShareCardPhotoStatus photoStatus;

  @override
  Widget build(BuildContext context) {
    final unavailable = photoStatus == FindShareCardPhotoStatus.unavailable;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8EDE4), Color(0xFFD5DFD0)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unavailable
                  ? Icons.broken_image_outlined
                  : Icons.photo_camera_back_outlined,
              color: FindShareCard._olive,
              size: 38,
            ),
            const SizedBox(height: 7),
            Text(
              unavailable
                  ? 'Photograph unavailable'
                  : 'No photograph available',
              style: const TextStyle(
                color: FindShareCard._olive,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordSummary extends StatelessWidget {
  const _RecordSummary({required this.data});

  final FindShareCardData data;

  @override
  Widget build(BuildContext context) {
    final measurementLine = [
      if (data.measurements != null) data.measurements!,
      if (data.weight != null) data.weight!,
    ].join('  •  ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.logNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FindShareCard._olive,
              fontSize: 9,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FindShareCard._onSurface,
              fontSize: 18,
              height: 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (data.discoveryDate != null) ...[
            const SizedBox(height: 5),
            _CompactLine(
              icon: Icons.calendar_today_outlined,
              text: 'Discovered ${data.discoveryDate}',
            ),
          ],
          if (measurementLine.isNotEmpty) ...[
            const SizedBox(height: 3),
            _CompactLine(
              icon: Icons.straighten_outlined,
              text: measurementLine,
            ),
          ],
          if (data.facts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: [for (final fact in data.facts) _FactPill(fact: fact)],
            ),
          ],
          const Spacer(),
          if (data.observations != null) ...[
            Text(
              data.observations!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: FindShareCard._onSurfaceVariant,
                fontSize: 10,
                height: 1.18,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
          ],
          const Row(
            children: [
              Icon(
                Icons.location_off_outlined,
                color: FindShareCard._olive,
                size: 13,
              ),
              SizedBox(width: 4),
              Text(
                FindShareCardData.privacyLabel,
                style: TextStyle(
                  color: FindShareCard._olive,
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactLine extends StatelessWidget {
  const _CompactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: FindShareCard._onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FindShareCard._onSurfaceVariant,
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill({required this.fact});

  final FindShareCardFact fact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: FindShareCard._tonalSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '${fact.label}: ${fact.value}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FindShareCard._olive,
              fontSize: 9,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
