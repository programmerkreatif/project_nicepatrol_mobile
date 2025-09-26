import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoundactivityScreen extends StatefulWidget {
  final int patrolAreaId;

  const RoundactivityScreen({super.key, required this.patrolAreaId});

  @override
  State<RoundactivityScreen> createState() => _RoundactivityScreenState();
}

class _RoundactivityScreenState extends State<RoundactivityScreen> {
  late Future<List<RoundActivity>> _futureActivities;

  @override
  void initState() {
    super.initState();
    _futureActivities = fetchActivities(widget.patrolAreaId);
  }

  Future<List<RoundActivity>> fetchActivities(int patrolAreaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(
        'http://www.programmerkreatif.biz.id:7787/api/auth/detailaktifitas?patrol_area_id=$patrolAreaId');


    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['data'];
      return list.map((json) => RoundActivity.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data aktivitas');
    }
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        title: Text('Rounds Log', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: FutureBuilder<List<RoundActivity>>(
        future: _futureActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final activities = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Image.asset('assets/map.png', fit: BoxFit.cover),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Rounds Logs (Detail Pengecekan)',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              ...activities.map((item) => _roundItem(
                    status: item.status,
                    statusColor: _parseColor(item.statusColor),
                    time: item.time,
                    location: item.location,
                    isSafe: item.isSafe,
                    assetName: item.assetName,
                    condition: item.condition,
                    description: item.description,
imageUrls: item.photos,


                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _roundItem({
    required String status,
    required Color statusColor,
    String? time,
    required String location,
    bool? isSafe,
    String? assetName,
    String? condition,
    String? description,
    List<String> imageUrls = const [],
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 20),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            Container(width: 2, height: 100, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Lokasi & Waktu
           Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(
        'Lokasi: $location',
        style: GoogleFonts.poppins(fontSize: 12),
        softWrap: true,
        overflow: TextOverflow.visible, // biar bisa ke bawah
      ),
    ),
    if (time != null)
      Text(
        time,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
      ),
  ],
),

                if (isSafe != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isSafe ? 'Aman' : 'Tidak Aman',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSafe ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                if (assetName != null || condition != null || description != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kondisi Aset',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        if (assetName != null)
                          Text('Nama Aset: $assetName', style: GoogleFonts.poppins(fontSize: 13)),
                        if (condition != null)
                          Text('Kondisi: $condition', style: GoogleFonts.poppins(fontSize: 13)),
                        if (description != null) ...[
                          const SizedBox(height: 6),
                          Text('Deskripsi:',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          Text(description!, style: GoogleFonts.poppins(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
        if (imageUrls.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Wrap(
      spacing: 8,
      children: imageUrls.map((url) {
        print('🔍 Loading image: $url'); // Debug URL
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Failed to load: $url'); // Debug error
              return const Icon(Icons.broken_image, size: 60);
            },
          ),
        );
      }).toList(),
    ),
  )


              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class RoundActivity {
  final String status;
  final String statusColor;
  final String? time;
  final String location;
  final bool? isSafe;
  final String? assetName;
  final String? condition;
  final String? description;
  final List<String> photos;

  RoundActivity({
    required this.status,
    required this.statusColor,
    this.time,
    required this.location,
    this.isSafe,
    this.assetName,
    this.condition,
    this.description,
    required this.photos,
  });

  factory RoundActivity.fromJson(Map<String, dynamic> json) {
    return RoundActivity(
      status: json['status'] ?? '',
      statusColor: json['status_color'] ?? 'grey',
      time: json['time']?.isEmpty == true ? null : json['time'],
      location: json['location'] ?? '',
      isSafe: json['is_safe'],
      assetName: json['asset_name'],
      condition: json['condition'],
      description: json['description'],
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}
