import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/models/Lokasi.dart';
import 'package:patroli/request/LoggedinHelper.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/FormAbsenScreen.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:patroli/models/Area.dart';
import 'package:patroli/models/Patrolarea.dart';

class AbsenScreen extends StatefulWidget {
  final bool isClockIn;
  final bool isClockOut;
  final String shift_name;
  final String shift_text;

  const AbsenScreen({
    super.key,
    required this.isClockIn,
    required this.isClockOut,
    required this.shift_name,
    required this.shift_text,
  });

  @override
  _AbsenScreenState createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  bool overTime = false;
  bool backup = false;
  bool izin = false;
  double? _currentLatitude;
  double? _currentLongitude;
  String? address;
  String errorMessage = '';
  String inDistcance = '';
  String alwaysoke = '';
  File? _profileImage;
  String? selectedValue;
  Map<String, dynamic>? dashboardData;
  bool isLoadingDashboard = false;
  String? dashboardError;
  List<Area> areas = [];
  List<Lokasi> lokasi = [];
  List<Patrol> patrols = [];
  Lokasi? selectedArea;

  @override
  void initState() {
    super.initState();
    // getLatLong();
    // loadArea();
    loadDropdownLoc();
  }

  Future<void> loadDropdownLoc() async {
    final result = await Requesthelper.getdropdownlocation();

    if (result != null && result['success'] == true && result['data'] != null) {
      final data = result['data'];

      setState(() {
        if (data is List) {
          lokasi = data.map((item) => Lokasi.fromJson(item)).toList();
        } else {
          lokasi = []; // fallback
        }
      });
    } else {
      setState(() {
        dashboardError = result?['message'] ?? 'Gagal memuat data lokasi.';
      });
    }
  }

  Future<void> loadArea() async {
    setState(() {
      // Menandakan bahwa pemuatan data sedang berlangsung
    });

    // Asumsikan Requesthelper.getarea() mengembalikan Future<Map<String, dynamic>>
    final result = await Requesthelper.getarea();
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
      });
    } else {
      setState(() {
        dashboardError = result['message']; // Menyimpan pesan kesalahan
      });
    }
  }

  Future<void> checkStatus(lat, lng, branchId) async {
    final result = await LoggedinHelper.checkLocationStatus(
      latitude: lat,
      longitude: lng,
      branchId: int.tryParse(branchId ?? '0') ?? 0,
    );
    if (result['success']) {
      final status = result['status'];
      setState(() {
        inDistcance = result['is_within_radius'] == 'false'
            ? "Lokasi Anda jauh dari radius kantor"
            : 'Lokasi dalam jangkauan kantor';
      });
    } else {
      setState(() {
        errorMessage = result['message'];
      });
      print('Gagal: ${result['message']}');
    }
  }

  Future<void> getLatLong(String areaId) async {
    Location location = Location();
    inDistcance = "";

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    print('Latitude: ${locationData.latitude}');
    print('Longitude: ${locationData.longitude}');

    final result = await getAddressFromLatLong(
        locationData.latitude!.toDouble(), locationData.longitude!.toDouble());
    final prefs = await SharedPreferences.getInstance();

    final dataMsg = await Requesthelper.checkLocationStatus(
        latitude: locationData.latitude!.toDouble(),
        longitude: locationData.longitude!.toDouble(),
        areaId: areaId);

    if (dataMsg['success']) {
      final status = dataMsg['status'];
      setState(() {
        inDistcance = dataMsg['is_within_radius'] == 'false'
            ? "Lokasi Anda jauh dari radius kantor"
            : 'Lokasi dalam jangkauan kantor';
      });
    } else {
      setState(() {
        errorMessage = dataMsg['message'];
      });
      print('Gagal: ${dataMsg['message']}');
    }

    print("checking data + " + areaId);
    print(dataMsg);

    // await checkStatus(locationData.latitude!.toDouble(),
    //     locationData.longitude!.toDouble(), prefs.getString('user_branch_id'));

    setState(() {
      address = result ?? "Alamat tidak ditemukan";
      _currentLatitude = locationData.latitude!.toDouble();
      _currentLongitude = locationData.longitude!.toDouble();
    });
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String dayName =
        DateFormat('EEEE', 'id_ID').format(now); // Hari (Senin, Selasa, dll)
    String formattedDate =
        DateFormat('d MMMM yyyy', 'id_ID').format(now); // 27 Mei 2025
    String formattedTime = DateFormat('HH:mm').format(now); // 14:52

    return '$dayName, $formattedDate, $formattedTime WIB';
  }

  Future<String?> getAddressFromLatLong(double lat, double lon) async {
    final url = Uri.parse(
      'https://maps.adonara.co.id/reverse?lat=$lat&lon=$lon&format=json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['display_name'] != null) {
        return data['display_name'] as String;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Absen',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.offline_bolt, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: pickImageFromCamera,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  shape: BoxShape.circle,
                  image: _profileImage != null
                      ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
          ),

          SizedBox(height: 100), // Sesuaikan spacing

          // Bottom card
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16), // margin kiri kanan 16
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: Colors.grey[600], size: 16),
                        SizedBox(width: 8),
                        Text(
                          widget.shift_name,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Text(
                          widget.shift_text,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      getFormattedDate(),
                      style: GoogleFonts.manrope(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Checkbox row
                    Row(
                      children: [
                        _buildCheckboxLabel('Over time', overTime, (val) {
                          setState(() => overTime = val);
                        }),
                        SizedBox(width: 24),
                        _buildCheckboxLabel('Backup', backup, (val) {
                          setState(() => backup = val);
                        }),

                         SizedBox(width: 24),
                        _buildCheckboxLabel('Izin', izin, (val) {
                          setState(() => izin = val);
                        }),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Location info - Posisi Saya
                    _locationInfo(
                      icon: Icons.location_on_outlined,
                      title: 'Posisi Saya',
                      // address: 'RW 1, Kecamatan Kulim, Pekanbaru, Riau 28286',
                      address: address ?? 'Memuat alamat...',
                    ),
                    SizedBox(height: 6),

                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0), // Padding di dalam kontainer
                      decoration: BoxDecoration(
                        color: Colors.white, // Warna latar belakang
                        borderRadius:
                            BorderRadius.circular(12), // Border radius
                        boxShadow: [
                          // Opsi bayangan jika diinginkan
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButton<Lokasi>(
                        isExpanded: true,
                        value: selectedArea,
                        hint: Text('Pilih lokasi absensi anda'),
                        items: lokasi.map((lokasi) {
                          return DropdownMenuItem<Lokasi>(
                            value: lokasi,
                            child: Text(lokasi.name ?? ''),
                          );
                        }).toList(),
                        onChanged: (Lokasi? newArea) {
                          setState(() {
                            selectedArea = newArea;
                            if (newArea != null) {
                              getLatLong(newArea.id.toString());
                              inDistcance =
                                  ''; // ⬅️ Reset dulu supaya tombol sembunyi

                              print('Selected Area ID: ${newArea.id}');
                              print('Selected Area Name: ${newArea.name}');
                            }
                          });
                        },
                        dropdownColor: Colors.white,
                        iconEnabledColor: Colors.black,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Warning box
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            inDistcance == "Lokasi Anda jauh dari radius kantor"
                                ? Color(0xFFFCEAEA)
                                : Color(0XFFFFFFFF), // merah muda transparan
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        inDistcance,
                        style: GoogleFonts.manrope(
                          color: inDistcance ==
                                  "Lokasi Anda jauh dari radius kantor"
                              ? Color(0xFFB92D2D)
                              : Color(0XFF38a52e),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Button Absen Masuk
                    if (address != "memuat alamat")
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormAbsenScreen(
                                  inDistcance: inDistcance,
                                  isClockIn: widget.isClockIn,
                                  isClockOut: widget.isClockOut,
                                  latitude: _currentLatitude ?? 0.0,
                                  longitude: _currentLongitude ?? 0.0,
                                  overTime: overTime,
                                  backup: backup,
                                  izin: izin,
                                  photoFile: _profileImage, // kirim foto
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Absensi',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2372F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxLabel(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        // Custom iOS style toggle checkbox
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 28,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: value ? Color(0xFF2372F0) : Colors.grey[300],
            ),
            child: AnimatedAlign(
              duration: Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _locationInfo({
    required IconData icon,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFFB92D2D), size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              Text(
                address,
                style: GoogleFonts.manrope(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
