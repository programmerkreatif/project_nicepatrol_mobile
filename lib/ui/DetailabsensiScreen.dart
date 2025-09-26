import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



// const String baseUrl = 'http://www.programmerkreatif.biz.id:81/patroli/web/api';
// const String basePhoto = 'http://www.programmerkreatif.biz.id:81/patroli/web/';


const String baseUrl = 'http://www.programmerkreatif.biz.id:7787/api';
const String basePhoto = 'http://www.programmerkreatif.biz.id:7787';


class DetailabsensiScreen extends StatefulWidget {
  final String id;

  const DetailabsensiScreen({super.key, required this.id});

  @override
  State<DetailabsensiScreen> createState() => _DetailabsensiScreenState();
}

class _DetailabsensiScreenState extends State<DetailabsensiScreen> {
  Map<String, dynamic>? detailData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uri = Uri.parse('$baseUrl/auth/detalabsensi?id=${widget.id}');

      print('Fetching detail ID: ${widget.id}');

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      print('Response code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          setState(() {
            detailData = json['data'];
            isLoading = false;
          });
        } else {
          print('API success false');
          setState(() => isLoading = false);
        }
      } else {
        print('Request failed');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailData == null
              ? const Center(
                  child: Text("Gagal memuat data",
                      style: TextStyle(color: Colors.white)))
              : detailData!.isEmpty
                  ? const Center(
                      child: Text("Data tidak ditemukan",
                          style: TextStyle(color: Colors.white)))
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTanggal(detailData!['date_clock']),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.grey),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Total Jam : ${_formatJam(detailData!['total_work_hours'])}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      detailData!['status'] ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),

                              // Masuk
                              _AbsensiDetailItem(
                                title: 'Jam Masuk',
                                time: detailData!['clock_in'] ?? '-',
                                location:
                                    detailData!['address_clock_in'] ?? '-',
                                imageUrl:
                                    _getPhotoUrl(detailData!['files_clock_in']),
                              ),
                              const SizedBox(height: 16),

                              // Keluar
                              _AbsensiDetailItem(
                                title: 'Jam Keluar',
                                time: detailData!['clock_out'] ?? '-',
                                location:
                                    detailData!['address_clock_out'] ?? '-',
                                imageUrl: _getPhotoUrl(
                                    detailData!['files_clock_out']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  String _formatTanggal(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return '${_getNamaHari(dt.weekday)}, ${dt.day.toString().padLeft(2, '0')} ${_getNamaBulan(dt.month)} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _getNamaHari(int weekday) {
    const hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return hari[(weekday - 1) % 7];
  }

  String _getNamaBulan(int month) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return bulan[month - 1];
  }

  String _formatJam(String? jam) {
    if (jam == null || !jam.contains(':')) return '-';
    final parts = jam.split(':');
    return '${parts[0]} Jam ${parts[1]} Menit';
  }

String _getPhotoUrl(dynamic jsonStr) {
  if (jsonStr == null || jsonStr is! String) return '';
  try {
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    final path = decoded['photo'];
    if (path != null && path is String && path.isNotEmpty) {
      return '$basePhoto/storage/app/public/$path'.replaceAll('\\', '/');
    }
  } catch (e) {
    debugPrint('Failed to parse photo: $e');
  }
  return '';
}

}

class _AbsensiDetailItem extends StatelessWidget {
  final String title;
  final String time;
  final String location;
  final String imageUrl;

  const _AbsensiDetailItem({
    required this.title,
    required this.time,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: GoogleFonts.poppins(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(location,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 64),
          ],
        ),
      ],
    );
  }
}
