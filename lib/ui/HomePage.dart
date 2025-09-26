import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:patroli/models/Area.dart';
import 'package:patroli/models/Patrolarea.dart';
import 'package:patroli/request/LoggedinHelper.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/AbsenScreen.dart';
import 'package:patroli/ui/ActivityScreen.dart';
// import 'package:patroli/ui/Aktifitasscreen.dart';
import 'package:patroli/ui/CheckpointScreen.dart';
import 'package:patroli/ui/DetailareaScreen.dart';
import 'package:patroli/ui/Helper/PatrolCard.dart';
import 'package:patroli/ui/NotifikasiScreen.dart';
import 'package:patroli/ui/ProfileScreen.dart';
import 'package:patroli/ui/ScanPage.dart';
import 'package:patroli/ui/TambahPatroliScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int selectedAreaIndex = 0;
  String? userName;
  bool isClockIn = false;
  bool isClockOut = false;
  String errorMessage = '';

  Map<String, dynamic>? dashboardData;
  bool isLoadingDashboard = false;
  String? dashboardError;
  String? statusLabelAbsensi = "";
  List<Area> areas = [];
  List<Patrol> patrols = [];

  Future<void> loadArea() async {
    setState(() {
      // Menandakan bahwa pemuatan data sedang berlangsung
    });

    // Asumsikan Requesthelper.getarea() mengembalikan Future<Map<String, dynamic>>
    final result = await Requesthelper.getarea();

    print("checking XXXX"); // Debugging print, bisa dihapus setelah selesai

    if (result['success'] == true) {
      setState(() {
        // Periksa apakah data adalah list atau map
        if (result['data']['area'] is List) {
          // Jika data adalah list
          areas = (result['data']['area'] as List)
              .map((area) => Area.fromJson(area))
              .toList();
        } else if (result['data']['area'] is Map) {
          // Jika data adalah map, Anda mungkin hanya memiliki satu area
          areas = [
            Area.fromJson(result['data']['area'])
          ]; // Masukkan ke dalam list
        }

        print(areas);

        // Muat patrol untuk area pertama jika ada
        if (areas.isNotEmpty) {
          loadPatrolArea(areas[0].id);
        }

        // Debugging print
      });
    } else {
      setState(() {
        dashboardError = result['message']; // Menyimpan pesan kesalahan
      });
    }
  }

  Future<void> loadPatrolArea(String areaId) async {
    setState(() {
      // Menandakan bahwa pemuatan data sedang berlangsung
    });

    final result = await Requesthelper.getpatrolarea(areaId);

    print("checking"); // Debugging print, bisa dihapus setelah selesai

    if (result['success'] == true) {
      setState(() {
        // Periksa apakah data adalah list atau map
        if (result['data']['area'] is List) {
          // Jika data adalah list
          patrols = (result['data']['area'] as List)
              .map((area) => Patrol.fromJson(area))
              .toList();
        } else if (result['data']['area'] is Map) {
          // Jika data adalah map, Anda mungkin hanya memiliki satu area
          patrols = [
            Patrol.fromJson(result['data']['area'])
          ]; // Masukkan ke dalam list
        }

        print(patrols); // Debugging print
      });
    } else {
      setState(() {
        dashboardError = result['message']; // Menyimpan pesan kesalahan
      });
    }
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoadingDashboard = true;
      dashboardError = null;
    });
    final result = await Requesthelper.fetchDashboardData();

      print("RAW result: $result");
      print("success: ${result['success']} (${result['success'].runtimeType})");
  
    if (result['success'] == true) {
      setState(() {
        dashboardData = result['data'];
        isLoadingDashboard = false;

      });
      print("checking TRUE");


    } else {

      print("checking FALSE");

      setState(() {
        dashboardError = result['message'];
        isLoadingDashboard = false;
        statusLabelAbsensi = result['message'];
        // print(statusLabelAbsensi);
      });

    }
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
    _loadUserName();
    loadArea();
    checkStatus();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name');
    });
  }

  Future<void> checkStatus() async {
    final result = await LoggedinHelper.checkStatusAbsensi();

    print("checkStatusAbsensi");

    print(result);

    if (result['success']) {
      final status = result['status'];

      setState(() {
        isClockIn = status['clock_in'];
        isClockOut = status['clock_out'];
      });
    } else {
      setState(() {
        errorMessage = result['message'];
      });
      print('Gagal: ${result['message']}');
    }
  }

  // final List<String> areas = ['Area 1', 'Area 2', 'Area 3', 'Area 4'];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }

    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TambahPatroliScreen()));
    }

    if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ActivityScreen()));
    }

    if (index == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Profileku()));
    }
  }

  // Widget _buildNavItem(IconData icon, String label, int index) {
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
          // Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Color(0xFF0077C8),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFF0077C8),
              padding:
                  EdgeInsets.only(top: topPadding + 16, left: 16, right: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/tractor.png'),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hi, $userName!',
                                style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 14)),
                            Text('Security',
                                style: GoogleFonts.manrope(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const NotifikasiScreen()),
                            );
                          },
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Shift dan Absen
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/fluent_shifts-team-20-filled.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),

                          // 🟢 Tambahkan Flexible di sini agar teks tidak menyebabkan overflow
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dashboardData?['attendance_today'] !=
                                        null &&
                                    dashboardData?['attendance_today']
                                        .isNotEmpty) ...[
                                  Text(
                                    '${dashboardData?['attendance_today']['shift']?['name'] ?? '-'}',
                                    style: GoogleFonts.manrope(
                                        color: Colors.white, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${dashboardData?['attendance_today']['shift']?['start_time'] ?? '-'} - '
                                    '${dashboardData?['attendance_today']['shift']?['end_time'] ?? '-'}',
                                    style: GoogleFonts.manrope(
                                        color: Colors.white, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ] else
                                  Text(
                                    '${statusLabelAbsensi}',
                                    style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // 🟢 Absen Button
                          if (dashboardData?['attendance_today'] != null &&
                              dashboardData?['attendance_today'].isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AbsenScreen(
                                      isClockIn: isClockIn,
                                      isClockOut: isClockOut,
                                      shift_name:
                                          dashboardData?['attendance_today']
                                                  ['shift']?['name'] ??
                                              '-',
                                      shift_text:
                                          '${dashboardData?['attendance_today']['shift']?['start_time']} - '
                                          '${dashboardData?['attendance_today']['shift']?['end_time']}',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isClockIn == true
                                      ? const Color(0xFFC11A20)
                                      : const Color(0xFF38A52E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isClockIn == false
                                      ? 'Absen Masuk'
                                      : 'Absen Pulang',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 1,
                    ),
                    // Label Layanan — gunakan Transform untuk naikkan sedikit

                    Transform.translate(
                      offset:
                          Offset(0, 20), // Naikkan lebih jauh dari -2 jadi -6
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Layanan',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        _buildMenuItem(
                            'POB', "assets/home/solar_card-2-bold-duotone.png"),
                        _buildMenuItem('Buku Tamu',
                            "assets/home/solar_book-2-bold-duotone.png"),
                        _buildMenuItem('Tugas',
                            "assets/home/solar_clipboard-list-bold-duotone.png"),
                        _buildMenuItem('Call Center',
                            "assets/home/solar_call-chat-bold-duotone.png"),
                        _buildMenuItem('Kru Change',
                            "assets/home/solar_user-cross-rounded-bold-duotone.png"),
                        _buildMenuItem('Blacklist',
                            "assets/home/solar_bill-cross-bold-duotone.png"),
                        _buildMenuItem('HSSE',
                            "assets/home/solar_health-bold-duotone.png"),
                        _buildMenuItem('Otorisasi',
                            "assets/home/solar_shield-user-bold-duotone.png"),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/gis_location-man.png', // Ganti path sesuai dengan lokasi file PNG-mu
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cari Lokasi Patroli Area',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF002848),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ActivityScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:
                                    const BorderSide(color: Color(0xFF0071CE)),
                              ),
                              backgroundColor: const Color(0xFFE6F1FA),
                              foregroundColor: const Color(0xFF0071CE),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Cari Patroli',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BAGIAN PUTIH (Body Bawah)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 48,
                        width: 320,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          itemCount: areas.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedAreaIndex;
                            return OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedAreaIndex = index;
                                  loadPatrolArea(areas[index].id.toString());
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.blue.shade100
                                    : Colors.white,
                                side: BorderSide(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text(
                                areas[index].name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: patrols.map((patrol) {
                          return PatrolCard(
                            imageUrl:
                                'assets/tractor.png', // Use patrol's image URL
                            title: patrol.name,
                            distance: patrol
                                .location_long_lat, // Assuming `distance` is a property in your Patrol model
                            statusText:
                                "Active", // Assuming `statusText` is a property in your Patrol model
                            statusColor: Colors
                                .blue, // Assuming `statusColor` is a property in your Patrol model

                            onTap: () {
                              // Navigasi atau aksi lainnya
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DetailareaScreen(),
                                  ));
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
            'assets/bottombarx/Frame177.png', // ganti dengan path Anda
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: null,
        // shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem("assets/bottombarx/home.png", "Beranda", 0),
            _buildNavItem("assets/bottombarx/Vector.png", "Patrol", 1),
            const SizedBox(width: 40), // space for FAB
            _buildNavItem("assets/bottombarx/mynaui_activity-square-solid.png",
                "Aktifitas", 3),
            _buildNavItem(
                "assets/bottombarx/mingcute_user-4-fill.png", "Profil", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String assetPath) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0XFFD9EAF8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image.asset(
              assetPath,
              height: 24,
              width: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(String title, int value, int total, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value / total,
                color: color,
                backgroundColor: color.withOpacity(0.2),
                strokeWidth: 6,
              ),
            ),
            Text('$value/$total', style: GoogleFonts.manrope(fontSize: 12))
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: GoogleFonts.manrope(fontSize: 12))
      ],
    );
  }
}
