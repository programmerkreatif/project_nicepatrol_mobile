import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/ResetpasswordScreen.dart';

class OtpPasswordScreen extends StatefulWidget {
  final String noWhatsapp;

  const OtpPasswordScreen({super.key, required this.noWhatsapp});

  @override
  State<OtpPasswordScreen> createState() => _OtpPasswordScreenState();
}

class _OtpPasswordScreenState extends State<OtpPasswordScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Cek apakah semua input terisi
    final isComplete =
        _controllers.every((controller) => controller.text.isNotEmpty);

    if (isComplete) {
      _submitOtp();
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _submitOtp() async {
    if (_otpCode.length < 6) {
      setState(() => _errorMessage = 'Kode OTP harus 6 digit');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await Requesthelper.verifyOtp(widget.noWhatsapp, _otpCode);
    setState(() => _isLoading = false);
    if (result['success']) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              noWhatsapp: widget.noWhatsapp,
              token: result['token'],
            ),
          ),
        );
    } else {
      setState(() => _errorMessage = result['message'] ?? 'OTP salah');
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await Requesthelper.forgotPassword(widget.noWhatsapp);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kode OTP telah dikirim ulang')),
      );

      // Kosongkan field OTP sebelumnya
      for (final controller in _controllers) {
        controller.clear();
      }

      FocusScope.of(context).requestFocus(_focusNodes[0]); // fokus ke pertama
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Gagal mengirim ulang OTP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gambar dan Logo
              // Padding(
              //   padding: const EdgeInsets.only(
              //       top: 16, bottom: 16), // hanya padding vertikal
              //   child: Image.asset(
              //     'assets/bglogin.png',
              //     width: double.infinity,
              //     height: 250,
              //     fit: BoxFit.cover, // agar gambar memenuhi area lebar
              //   ),
              // ),

              // const SizedBox(height: 16),

                     Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.asset(
                  'assets/bglogin.png',
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.fill, // <-- ubah dari BoxFit.cover ke BoxFit.contain
                ),
              ),
              const SizedBox(height: 14),

              // Judul
              Text(
                'Kode OTP',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Deskripsi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Silakan Masukkan Kode 6 Digit yang Telah Dikirim ke Nomor WhatsApp Anda',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isError = _errorMessage != null;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 48,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        color: isError ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isError ? Colors.red : Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isError ? Colors.red : Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isError ? Colors.red : Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => _onChanged(value, index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // Kode salah
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Tidak mendapatkan kode?
              Text(
                'Tidak mendapatkan kode OTP?',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () {
                  _resendOtp();
                },
                child: Text(
                  'Kirim Ulang',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
