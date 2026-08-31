String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${_two(local.day)} ${_month(local.month)} ${local.year}';
}

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${formatDate(local)}, ${_two(local.hour)}:${_two(local.minute)}';
}

String formatCoordinate(double value) => value.toStringAsFixed(6);

String formatCatalogueYear(int year) {
  if (year < 0) return '${year.abs()} BCE';
  return '$year CE';
}

String formatTimelineRange(int? fromYear, int? toYear) {
  if (fromYear != null && toYear != null) {
    return '${formatCatalogueYear(fromYear)} – ${formatCatalogueYear(toYear)}';
  }
  if (fromYear != null) return 'From ${formatCatalogueYear(fromYear)}';
  if (toYear != null) return 'To ${formatCatalogueYear(toYear)}';
  return 'Not recorded';
}

String enumLabel(Enum value) {
  final words = value.name.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  return words[0].toUpperCase() + words.substring(1);
}

String _two(int value) => value.toString().padLeft(2, '0');

String _month(int value) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][value - 1];
