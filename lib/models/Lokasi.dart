class Lokasi {
  final String id;
  final String name;
  final String latitude;
  final String longitude;

  Lokasi({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id'].toString(),
      name: json['nama_lokasi'],
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
    );
  }
}
