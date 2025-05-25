import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  final dateTime = DateTime.parse(isoDate);
  final formatter = DateFormat('MMM d, y'); // e.g. May 25, 2025
  return formatter.format(dateTime);
}
String formatDuration(double seconds) {
  final int totalSeconds = seconds.floor();
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int secs = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

String getCompactShortAddress(Map<String, dynamic> placeDetail) {
  final components = placeDetail['address_components'] as List;

  String? get(String type) {
    final comp = components.firstWhere(
      (c) => (c['types'] as List).contains(type),
      orElse: () => null,
    );
    return comp?['short_name'];
  }

  final district = get("sublocality") ?? get("sublocality_level_1");
  final city =
      get("locality") ??
      get("administrative_area_level_2") ??
      get("administrative_area_level_1");
  final country = get("country");
  return [district, city, country].where((e) => e != null).join(', ');
}
