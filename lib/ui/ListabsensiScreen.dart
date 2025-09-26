// Pastikan semua import tetap
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patroli/ui/DetailabsensiScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


// const String baseUrl = 'http://www.programmerkreatif.biz.id:81/patroli/web/api';
// const String basePhoto = 'http://www.programmerkreatif.biz.id:81/patroli/web/';


const String baseUrl =
    // 'http://www.programmerkreatif.biz.id:81/patroli/web/api'; // Ganti dengan URL-mu
    'http://www.programmerkreatif.biz.id:7787/api';

class Listabsensiscreen extends StatefulWidget {
  const Listabsensiscreen({super.key});

  @override
  State<Listabsensiscreen> createState() => _ListabsensiscreenState();
}

class _ListabsensiscreenState extends State<Listabsensiscreen> {
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic> summary = {};

  void _previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
    });
  }

  void updateSummary(Map<String, dynamic> newSummary) {
    setState(() {
      summary = newSummary;
    });
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Absensi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: _previousMonth,
                        child: const Icon(Icons.chevron_left)),
                    Text(monthYear,
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    GestureDetector(
                        onTap: _nextMonth,
                        child: const Icon(Icons.chevron_right)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryBox(
                      title: 'Hadir',
                      value: '${summary['hadir'] ?? 0}',
                      subtitle: summary['total_jam'] ?? '-',
                      color: const Color(0xFFDDF5DB),
                      textColor: const Color(0xFF4CAF50),
                    ),
                    _SummaryBox(
                      title: 'Pulang Cepat',
                      value: '${summary['keluar_awal'] ?? 0}',
                      subtitle:
                          '0 Jam 0 Menit', // Jika ada durasi total keluar awal, ganti dari API
                      color: const Color(0xFFFFF3CD),
                      textColor: const Color(0xFFFFA000),
                    ),
                    _SummaryBox(
                      title: 'Terlambat',
                      value: '${summary['terlambat'] ?? 0}',
                      subtitle:
                          '0 Jam 0 Menit', // Jika ada durasi keterlambatan, ganti dari API
                      color: const Color(0xFFF8D7DA),
                      textColor: const Color(0xFFD32F2F),
                    ),
                    _SummaryBox(
                      title: 'Cuti',
                      value: '${summary['cuti'] ?? 0}',
                      subtitle: 'Tersisa ${summary['sisa_cuti'] ?? 0} Hari',
                      color: const Color(0xFFE2E3E5),
                      textColor: const Color(0xFF6C757D),
                    ),
                  ],
                )
              ],
            ),
          ),
          _TableHeader(),
          Expanded(
            child: _AbsensiList(
              month: selectedDate.month,
              year: selectedDate.year,
              onSummaryUpdate: updateSummary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title, value, subtitle;
  final Color color, textColor;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(title,
                style: GoogleFonts.poppins(fontSize: 12, color: textColor)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 10, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.white,
      child: Row(
        children: [
          _headerCell('Hari'),
          _headerCell('Jam Masuk'),
          _headerCell('Jam Keluar'),
          _headerCell('Total Jam'),
          _headerCell('Keterangan'),
          _headerCell('Aksi'),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return Expanded(
      child: Text(text,
          textAlign: TextAlign.center,
          style:
              GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _AbsensiList extends StatefulWidget {
  final int month;
  final int year;
  final void Function(Map<String, dynamic>) onSummaryUpdate;

  const _AbsensiList({
    required this.month,
    required this.year,
    required this.onSummaryUpdate,
  });

  @override
  State<_AbsensiList> createState() => _AbsensiListState();
}

class _AbsensiListState extends State<_AbsensiList> {
  List<Map<String, dynamic>> absensiData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant _AbsensiList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.month != oldWidget.month || widget.year != oldWidget.year) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uri = Uri.parse(
          '$baseUrl/auth/listabsensi?month=${widget.month}&year=${widget.year}');

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            absensiData = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
          });
          widget.onSummaryUpdate(jsonData['summary'] ?? {});
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (absensiData.isEmpty) {
      return const Center(child: Text('Tidak ada data absensi.'));
    }

    return ListView.builder(
      itemCount: absensiData.length,
      itemBuilder: (context, index) {
        final item = absensiData[index];
        final String hari = '${item['tanggal']}\n${item['hari']}';
        final String masuk = item['masuk'] ?? '-';
        final String keluar = item['keluar'] ?? '-';
        final String total = item['total_jam'] ?? '-';
        final String keterangan = item['keterangan'] ?? '-';

        Color textColor;
        Color color;

        if (keterangan.toLowerCase().contains('cuti')) {
          textColor = Colors.orange;
          color = Colors.orange[50]!;
        } else if (keterangan.toLowerCase().contains('libur')) {
          textColor = Colors.red;
          color = Colors.red[50]!;
        } else if (keterangan.toLowerCase().contains('izin')) {
          textColor = Colors.blue;
          color = Colors.blue[50]!;
        } else {
          textColor = Colors.green;
          color = Colors.green[50]!;
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hari,
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
              _tableCell(masuk),
              _tableCell(keluar),
              _tableCell(total),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      keterangan,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                 onTap: () {
                    final id = item['id']?.toString();
                    if (id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailabsensiScreen(id: id),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Lihat Detail',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableCell(String value) {
    return Expanded(
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 11),
      ),
    );
  }
}
