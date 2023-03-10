class AsteroidModel {
  AsteroidModel(this.items);
  final Map<String, List<AsteroidItem>> items;

  factory AsteroidModel.fromJson(Map<String, dynamic> json) {
    final nearEarthObjects = json['near_earth_objects'] as Map<String, dynamic>;

    MapEntry<String, List<AsteroidItem>> makeEntry(String key, dynamic value) {
      final listValue = value as List<dynamic>;
      final asteroids = listValue.map((e) => AsteroidItem.fromJson(e)).toList();

      return MapEntry(key, asteroids);
    }

    return AsteroidModel(nearEarthObjects.map(makeEntry));
  }
}

class AsteroidItem {
  AsteroidItem({
    required this.name,
    required this.isHazardous,
    required this.minDiameterInMeters,
    required this.maxDiameterInMeters,
  });
  final String name;
  final bool isHazardous;
  final double minDiameterInMeters;
  final double maxDiameterInMeters;

  factory AsteroidItem.fromJson(Map<String, dynamic> json) {
    final estimatedDiameter = json['estimated_diameter']['meters'];

    return AsteroidItem(
      name: json['name'] ?? 'Unknown',
      isHazardous: json['is_potentially_hazardous_asteroid'] ?? false,
      minDiameterInMeters: estimatedDiameter['estimated_diameter_min'] ?? 0,
      maxDiameterInMeters: estimatedDiameter['estimated_diameter_max'] ?? 0,
    );
  }
}
