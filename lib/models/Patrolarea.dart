class Patrol {
  final String id;
  final String name;
  final String code;
  final String location_long_lat;

  Patrol({
    required this.id,
    required this.name,
    required this.code,
    required this.location_long_lat,
  });

  factory Patrol.fromJson(Map<String, dynamic> json) {
    return Patrol(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],
      location_long_lat: json['location_long_lat']
    );
  }
}