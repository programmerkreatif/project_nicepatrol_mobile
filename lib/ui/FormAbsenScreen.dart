import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/ui/HomePage.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patroli/request/LoggedinHelper.dart';

class FormAbsenScreen extends StatefulWidget {
  final String inDistcance;
  final bool isClockIn;
  final bool isClockOut;
  final double latitude;
  final double longitude;
  final bool overTime;
  final bool backup;
  final bool izin;
  final File? photoFile;

  const FormAbsenScreen({
    Key? key,
    required this.inDistcance,
    required this.isClockIn,
    required this.isClockOut,
    required this.latitude,
    required this.longitude,
    required this.overTime,
    required this.backup,
    required this.izin,
    required this.photoFile,
  }) : super(key: key);

  @override
  _FormAbsenScreenState createState() => _FormAbsenScreenState();
}

class _FormAbsenScreenState extends State<FormAbsenScreen> {
  final _catatanController = TextEditingController();
  PlatformFile? _selectedDocument;
  bool _isLoading = false;

  bool get isOutsideRadius =>
      widget.inDistcance == "Lokasi Anda jauh dari radius kantor";

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedDocument = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    print(widget.inDistcance);
    final bool isOutsideRadius =
        widget.inDistcance == "Lokasi Anda jauh dari radius kantor";
    final bool isOvertime = widget.overTime;
    final bool isClockInDone = widget.isClockIn;
    final bool isClockOutDone = widget.isClockOut;

    // Validasi catatan hanya jika di luar jangkauan
    if ((isOutsideRadius && _catatanController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Catatan wajib diisi karena di luar radius kantor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User ID tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }
      final File? documentFile =
          _selectedDocument != null ? File(_selectedDocument!.path!) : null;
      // Validasi dokumen hanya jika lembur atau di luar jangkauan
      if ((isOutsideRadius) && documentFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dokumen pendukung wajib diupload')),
        );
        return;
      }

      final photoFile = widget.photoFile;
      if (photoFile == null) throw Exception('File foto tidak ditemukan.');

      print("Photo file path: ${photoFile.path}");
      print("Photo file exists: ${await photoFile.exists()}");
      print("Photo file length: ${await photoFile.length()} bytes");

      final dateClock = DateTime.now();
      final timeNow =
          "${dateClock.hour.toString().padLeft(2, '0')}:${dateClock.minute.toString().padLeft(2, '0')}:${dateClock.second.toString().padLeft(2, '0')}";

      Map<String, dynamic> result;

      // Logika status absen
      if (!isClockInDone && !isClockOutDone && !isOvertime) {
        // ⏰ Clock In
        result = await LoggedinHelper.clockIn(
          userId: userId,
          latitude: widget.latitude,
          longitude: widget.longitude,
          notes: isOutsideRadius ? _catatanController.text : '-',
          photoFile: photoFile,
          documentFile: (isOutsideRadius || isOvertime) && documentFile != null
              ? documentFile
              : null,
          dateClock: dateClock,
          clockInTime: timeNow,
          izin: widget.izin,
          lembur: false,
          source: 'mobile',
          reference: isOutsideRadius ? 'outside_radius' : 'inside_radius',
        );
      } else if (!isClockInDone && !isClockOutDone && isOvertime) {
        // ❌ Tidak boleh langsung lembur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Anda harus Clock In dan Clock Out terlebih dahulu sebelum lembur.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      } else if (isClockInDone && !isClockOutDone && !isOvertime) {
        // ⏳ Clock Out
        result = await LoggedinHelper.clockOut(
          userId: userId,
          latitude: widget.latitude,
          longitude: widget.longitude,
          notes: isOutsideRadius ? _catatanController.text : '-',
          photoFile: photoFile,
          documentFile: (isOutsideRadius || isOvertime) && documentFile != null
              ? documentFile
              : null,
          dateClock: dateClock,
          clockOutTime: timeNow,
          source: 'mobile',
          reference: isOutsideRadius ? 'outside_radius' : 'inside_radius',
        );
      } else if (isClockInDone && !isClockOutDone && isOvertime) {
        // ❌ Tidak boleh lembur sebelum clock out
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Anda harus Clock Out terlebih dahulu sebelum lembur.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      } else if (isClockInDone && isClockOutDone && isOvertime) {
        // ✅ Lembur
        result = await LoggedinHelper.clockIn(
          userId: userId,
          latitude: widget.latitude,
          longitude: widget.longitude,
          notes: isOutsideRadius ? _catatanController.text : '-',
          photoFile: photoFile,
          documentFile: (isOutsideRadius || isOvertime) && documentFile != null
              ? documentFile
              : null,
          dateClock: dateClock,
          clockInTime: timeNow,
          izin: widget.backup ? true : false,
          lembur: true,
          source: 'mobile',
          reference: isOutsideRadius ? 'outside_radius' : 'inside_radius',
        );
      } else {
        result = {
          'success': false,
          'message': 'Status absen tidak valid.',
        };
      }

      print('checking WTF');
      print(result);

      // Tampilkan respon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message'] + "XXX" ?? 'Tidak ada pesan dari server'),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutsideRadius =
        widget.inDistcance == "Lokasi Anda jauh dari radius kantor";
    final bool isOvertime = widget.overTime;
    final bool shouldShowNotesField = isOutsideRadius || isOvertime;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0071CE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          ),
        ),
        title: Text('Absen Masuk',
            style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOutsideRadius ? Color(0xFFFCEAEA) : Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (isOutsideRadius)
                    Icon(Icons.warning, color: Color(0xFFB92D2D)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.inDistcance,
                      style: GoogleFonts.manrope(
                          color: isOutsideRadius
                              ? Color(0xFFB92D2D)
                              : Color(0xFF38A52E)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Form Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shouldShowNotesField) ...[
                    Text("Catatan *",
                        style:
                            GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _catatanController,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        hintText: "Tulis Catatan untuk Supervisor Anda",
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Kehadiran Anda akan ditinjau oleh supervisor Anda karena lokasi Anda jauh dari radius kantor",
                      style: GoogleFonts.manrope(
                          fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(height: 16),
                  ],

                  // File Upload
                  Text("File Pendukung *",
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            readOnly: true,
                            decoration: _inputDecoration(
                              hintText: _selectedDocument != null
                                  ? _selectedDocument!.name
                                  : "Unggah File Pendukung",
                            ).copyWith(isDense: true),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          height: 48,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text("Pilih File",
                              style: GoogleFonts.manrope(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF0071CE),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Kirim',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
