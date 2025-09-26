import 'package:flutter/material.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/Helper/HelperClass.dart';
import 'package:patroli/ui/ListabsensiScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profileku extends StatefulWidget {
  const Profileku({Key? key}) : super(key: key);

  @override
  State<Profileku> createState() => _ProfilekuState();
}

class _ProfilekuState extends State<Profileku> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }




  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final result = await Requesthelper.getProfileData();
    if (result['success']) {
      setState(() {
        profileData = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });


      print(result);

      print(result['message'] ?? 'Gagal memuat data');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal memuat data')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profileData == null) {
      return const Scaffold(
        body: Center(child: Text('Data tidak ditemukan')),
      );
    }


    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children:  [
              HeaderSection(data: profileData!['biodata']),
              if (profileData!['shift_terbaru'] != null)
                ShiftSection(data: profileData!['shift_terbaru']),
              // ShiftSection(data: profileData!['shift_terbaru']),
              AbsensiSection(data: profileData!['absensi_statistik']),
              BiodataSection(data: profileData!['biodata']),
              LogoutButton(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(),
    );
  }
}


class AbsensiSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const AbsensiSection({super.key, required this.data});

  Widget _buildCard(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Absensi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Listabsensiscreen()));
                },
                child: const Text('Lihat Semua', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCard('Hadir', data['hadir'] ?? 0, Colors.green, Icons.check_circle),
              _buildCard('Pulang Cepat', data['pulang_cepat'] ?? 0, Colors.orange, Icons.logout),
              _buildCard('Terlambat', data['terlambat'] ?? 0, Colors.red, Icons.schedule),
              _buildCard('Izin', data['izin'] ?? 0, Colors.grey, Icons.beach_access),
            ],
          ),
        ],
      ),
    );
  }
}

class BiodataSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const BiodataSection({super.key, required this.data});

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0XFF002848)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Biodata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _buildInfoItem('Durasi Kerja', data['durasi_kerja'] ?? '-'),
          _buildInfoItem('Lokasi', data['lokasi'] ?? '-'),
          _buildInfoItem('Telepon', data['telepon'] ?? '-'),
        ],
      ),
    );
  }
}




class ShiftSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const ShiftSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tanggal = data['tanggal'] ?? '-';
    final clockIn = data['clock_in'] ?? '-';
    final clockOut = data['clock_out'] ?? '-';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shift: $tanggal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildShiftButton(clockIn, isSelected: true),
              const SizedBox(width: 8),
              _buildShiftButton(clockOut, isSelected: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftButton(String label, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue[800] : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}


class HeaderSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const HeaderSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF007BFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Profil',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
              radius: 35, backgroundImage: AssetImage('assets/avatar.jpg')),
          const SizedBox(height: 12),
          Text(data['nama'] ?? '-',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Security',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text('4.8  •  Unit Usuan',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}




/* 
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF007BFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Profil',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
              radius: 35, backgroundImage: AssetImage('assets/avatar.jpg')),
          const SizedBox(height: 12),
          const Text('Jacob Jones',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Security',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text('4.8  •  Unit Usuan',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class ShiftSection extends StatelessWidget {
  const ShiftSection({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
    final dates = ['25', '26', '27', '28', '29', '30', '31'];
    final selectedIndex = 2; // Contoh: hari ke-3 (SEL)

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hari & Tanggal
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;

                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dates[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Tanggal aktif
          const Text('Selasa, 27 April 2025',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

          const SizedBox(height: 8),

          // Shift time options
          Row(
            children: [
              _buildShiftButton('12:00 - 16:00', isSelected: false),
              const SizedBox(width: 8),
              _buildShiftButton('16:00 - 18:00', isSelected: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftButton(String label, {bool isSelected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue[800] : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class AbsensiSection extends StatelessWidget {
  const AbsensiSection({super.key});

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Absensi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  // Aksi ketika diklik
                  print('Lihat Semua diklik');
                  // Misal ingin pindah halaman:
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => Listabsensiscreen()));
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card Grid
          Row(
            children: [
              _buildCard('Hadir', '10', Colors.green, Icons.check_circle),
              _buildCard('Keluar Awal', '0', Colors.orange, Icons.logout),
              _buildCard('Terlambat', '0', Colors.red, Icons.schedule),
              _buildCard('Cuti', '1', Colors.grey, Icons.beach_access),
            ],
          ),
        ],
      ),
    );
  }
}

class BiodataSection extends StatelessWidget {
  const BiodataSection({super.key});

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity, // ini kuncinya
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // Light blue
                    borderRadius:
                        BorderRadius.circular(10), // Rounded pill shape
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0XFF002848),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Biodata',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          // const SizedBox(height: 12),
          _buildInfoItem(Icons.badge, 'Durasi Kerja', '2 Tahun'),
          // const Divider(height: 24),
          _buildInfoItem(
              Icons.location_on, 'Lokasi', 'Fatmawati, Jakarta Selatan'),
          // const Divider(height: 24),
          _buildInfoItem(Icons.phone, 'Telepon', '+62 857-7651-1193'),
        ],
      ),
    );
  }
}
 */