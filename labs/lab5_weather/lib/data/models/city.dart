class City {
  const City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.region,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      region: json['admin1'] as String?,
    );
  }

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? region;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'admin1': region,
  };

  @override
  bool operator ==(Object other) => other is City && other.id == id;

  @override
  int get hashCode => id.hashCode;
}