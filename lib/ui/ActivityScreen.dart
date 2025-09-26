import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:patroli/ui/ScanPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patroli/ui/CheckpointScreen.dart';
import 'package:patroli/ui/HomePage.dart';
import 'package:patroli/ui/ProfileScreen.dart';
import 'package:patroli/ui/RoundactivityScreen.dart';
import 'package:patroli/ui/TambahPatroliScreen.dart';

class Assignment {
  final int id;
  final String type;
  final String dateOps;
  final PatrolArea patrolArea;

  Assignment({
    required this.id,
    required this.type,
    required this.dateOps,
    required this.patrolArea,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      type: json['type'],
      dateOps: json['date_ops'],
      patrolArea: PatrolArea.fromJson(json['patrol_area']),
    );
  }
}

class PatrolArea {
  final int id;
  final String name;
  final String code;
  final String imgLocation;

  PatrolArea({
    required this.id,
    required this.name,
    required this.code,
    required this.imgLocation,
  });

  factory PatrolArea.fromJson(Map<String, dynamic> json) {
    return PatrolArea(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      imgLocation: json['img_location'],
    );
  }
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int selectedTab = 0;
  int _currentIndex = 3;
  DateTime selectedDate = DateTime.now();

  List<Assignment> assignments = [];
  bool isLoading = true;
  String? token;

  int areaChecked = 0;
  int totalArea = 0;
  int roundsToday = 0;
  int totalRounds = 0;
  int assetsChecked = 0;
  int totalAssets = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TambahPatroliScreen()));
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityScreen()));
    }
    if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Profileku()));
    }
  }

  Widget _buildNavItem(String assetPath, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            height: 24,
            width: 24,
            fit: BoxFit.contain,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('http://www.programmerkreatif.biz.id:7787/api/auth/listaktifitas?filter=${selectedTab == 0 ? 'Reguler' : 'Mandiri'}&date=${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data']['assignment'];
        final summary = jsonData['data']['summary'];

        setState(() {
          assignments = data.map((item) => Assignment.fromJson(item)).toList();
          areaChecked = summary['area_checked'];
          totalArea = summary['total_area'];
          roundsToday = summary['rounds_today'];
          totalRounds = summary['total_rounds'];
          assetsChecked = summary['assets_checked'];
          totalAssets = summary['total_assets'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanPage()),
          );
        },
        child: SizedBox(
          width: 80,
          height: 80,
          child: Image.asset(
            'assets/bottombarx/Frame177.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem("assets/home_unselected.png", "Beranda", 0),
            _buildNavItem("assets/bottombarx/Vector.png", "Patrol", 1),
            const SizedBox(width: 40),
            _buildNavItem("assets/activity_menu.png", "Aktifitas", 3),
            _buildNavItem("assets/bottombarx/mingcute_user-4-fill.png", "Profil", 4),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.only(top: 65, left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                Image.asset(
                  'assets/activity_menu.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aktivitas',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedTab = 0);
                        _loadData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedTab == 0 ? const Color(0xFFEAF2FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Patrol',
                          style: GoogleFonts.manrope(
                            color: selectedTab == 0 ? const Color(0xFF007AFF) : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedTab = 1);
                        _loadData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedTab == 1 ? const Color(0xFFEAF2FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Patroli Mandiri',
                          style: GoogleFonts.manrope(
                            color: selectedTab == 1 ? const Color(0xFF007AFF) : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Aktivitas - ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                    style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Ganti Tanggal', style: GoogleFonts.manrope(fontSize: 12)),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Row(
          //     children: [
          //     _buildSummaryBox('assets/ph_map-pin-area.png', "$areaChecked/$totalArea", "Area"),
          //       const SizedBox(width: 8),
          //       _buildSummaryBox('assets/rounds.png', "$roundsToday/$totalRounds", "Rounds"),
          //       const SizedBox(width: 8),
          //       _buildSummaryBox('assets/carbon_asset.png', "$assetsChecked/$totalAssets", "Assets"),
          //     ],
          //   ),
          // ),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: LayoutBuilder(
    builder: (context, constraints) {
      double spacing = 8;
      double totalSpacing = spacing * 2;
      double itemWidth = (constraints.maxWidth - totalSpacing) / 3;

      return Wrap(
        spacing: spacing,
        runSpacing: 8,
        children: [
          SizedBox(
            width: itemWidth,
            child: _buildSummaryBox('assets/ph_map-pin-area.png', "$areaChecked/$totalArea", "Area"),
          ),
          SizedBox(
            width: itemWidth,
            child: _buildSummaryBox('assets/rounds.png', "$roundsToday/$totalRounds", "Rounds"),
          ),
          SizedBox(
            width: itemWidth,
            child: _buildSummaryBox('assets/carbon_asset.png', "$assetsChecked/$totalAssets", "Assets"),
          ),
        ],
      );
    },
  ),
),


          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : assignments.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data ${selectedTab == 0 ? 'Reguler' : 'Mandiri'}',
                          style: GoogleFonts.manrope(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: assignments.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final item = assignments[index];
                          return _patrolTile(
                            item.patrolArea.name,
                            'Belum Cek',
                            Colors.red,
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => RoundactivityScreen()),
                              // );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoundactivityScreen(patrolAreaId: item.patrolArea.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

// Widget _buildSummaryBox(String assetPath, String value, String label) {
//   return Expanded(
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEAF2FF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Image.asset(assetPath, height: 24, width: 24),
//           const SizedBox(width: 8),
//           Text.rich(
//             TextSpan(
//               children: [
//                 TextSpan(
//                   text: "$value ",
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//                 TextSpan(
//                   text: label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }



Widget _buildSummaryBox(String assetPath, String value, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF2FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(assetPath, height: 16, width: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$value ",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _patrolTile(String title, String status, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: _statusTag(status, color),
          title: Text(title, style: GoogleFonts.manrope()),
          trailing: const Icon(Icons.keyboard_arrow_down),
        ),
      ),
    );
  }

  Widget _statusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
