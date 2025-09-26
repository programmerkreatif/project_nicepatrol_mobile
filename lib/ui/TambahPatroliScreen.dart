import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:patroli/ui/ActivityScreen.dart';
import 'package:patroli/ui/CheckpointScreen.dart';
import 'dart:convert';
import 'package:patroli/ui/HomePage.dart';
import 'package:patroli/ui/ProfileScreen.dart';
import 'package:patroli/ui/ScanPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahPatroliScreen extends StatefulWidget {
  @override
  State<TambahPatroliScreen> createState() => _TambahPatroliScreenState();
}

class _TambahPatroliScreenState extends State<TambahPatroliScreen> {
  final _deskripsiController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageListx = [];

  List<PatrolArea> _patrolAreas = [];
  int? _selectedAreaId;
  String? _status;
  String? _kondisi;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchPatrolAreas();
  }

  Future<void> _fetchPatrolAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(
        'http://www.programmerkreatif.biz.id:7787/api/auth/patrolareabybranch');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> areaList = data['data']['area'];
        setState(() {
          _patrolAreas =
              areaList.map((item) => PatrolArea.fromJson(item)).toList();
        });
      } else {
        print("Gagal fetch area: ${response.body}");
      }
    } catch (e) {
      print("Error fetching area: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_selectedAreaId == null || _status == null || _kondisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lengkapi semua field wajib!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://www.programmerkreatif.biz.id:7787/api/auth/self-report'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['location_name'] = _selectedAreaId.toString();
    request.fields['status'] = _status!;
    request.fields['condition'] = _kondisi!;
    request.fields['description'] = _deskripsiController.text;

    for (var image in _imageListx) {
      request.files
          .add(await http.MultipartFile.fromPath('photos[]', image.path));
    }

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Input patroli mandiri berhasil'),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        print("Response Error: ${responseBody.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim data.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Submit error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan.'),
        backgroundColor: Colors.red,
      ));
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Color(0XFF0071CE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: Row(
            children: [
              GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
              },
              child: Image.asset(
                'assets/mage_security-shield-fill.png',
                width: 24,
                height: 24,
                color: Colors.white, // jika ingin warnanya putih (hanya jika PNG transparan)
              ),
            ),
              SizedBox(width: 8),
              Text("Patrol", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
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
            _buildNavItem("assets/patrol_menu.png", "Patrol", 1),
            const SizedBox(width: 40),
            _buildNavItem("assets/bottombarx/mynaui_activity-square-solid.png",
                "Aktifitas", 3),
            _buildNavItem("assets/bottombarx/mingcute_user-4-fill.png", "Profil", 4),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRow(),
                SizedBox(height: 24),
                _buildDropdownLokasi(),
                SizedBox(height: 16),
                _buildDropdown(
                    "Status Lokasi *", _status, ["Aman", "Tidak Aman"], (val) {
                  setState(() => _status = val);
                }),
                SizedBox(height: 16),
                _buildDropdown("Kondisi Lokasi *", _kondisi, [
                  "Kebakaran",
                  "Aset Patroli Rusak",
                  "Aset Client Hilang",
                  "Orang Mencurigakan",
                  "Kabel Terbuka",
                  "Pencurian",
                  "Penggelapan",
                  "Sabotase",
                  "Pengrusakan",
                  "Demo",
                  "Konflik Sosial",
                  "Perkelahian",
                  "Pemerasan"
                ], (val) {
                  setState(() => _kondisi = val);
                }),
                SizedBox(height: 16),
                _buildTextField("Deskripsi", "Tambahkan deskripsi...",
                    _deskripsiController),
                SizedBox(height: 24),
                _buildAmbilFotoButton(),
                SizedBox(height: 12),
                _buildImagePreview(),
                SizedBox(height: 28),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Tambah Patroli",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.grey[700]),
            SizedBox(width: 6),
            Text(DateFormat("d MMM yyyy").format(DateTime.now()),
                style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration(),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownLokasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Nama Lokasi *"),
        DropdownButtonFormField<int>(
          value: _selectedAreaId,
          isExpanded: true,
          decoration: _inputDecoration(),
          items: _patrolAreas.map((area) {
            return DropdownMenuItem<int>(
              value: area.id,
              child: Text(area.name),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAreaId = val),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: _inputDecoration().copyWith(hintText: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFD6D6D6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFD6D6D6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFD6D6D6), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildAmbilFotoButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final XFile? photo =
              await _picker.pickImage(source: ImageSource.camera);
          if (photo != null) {
            setState(() => _imageListx.add(photo));
          }
        },
        icon: Icon(Icons.camera_alt_outlined),
        label: Text("Ambil Foto"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0XFFB0D3F0),
          foregroundColor: Colors.blue[800],
          padding: EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _imageListx.map((file) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(file.path),
                      width: 80, height: 80, fit: BoxFit.cover),
                ),
                Positioned(
                  top: -15,
                  right: -15,
                  child: IconButton(
                    icon: Icon(Icons.cancel, size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => setState(() => _imageListx.remove(file)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: TextStyle(color: Colors.blue)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            child: Text("Kirim", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

// Model PatrolArea
class PatrolArea {
  final int id;
  final String name;

  PatrolArea({required this.id, required this.name});

  factory PatrolArea.fromJson(Map<String, dynamic> json) {
    return PatrolArea(
      id: json['id'],
      name: json['name'],
    );
  }
}
