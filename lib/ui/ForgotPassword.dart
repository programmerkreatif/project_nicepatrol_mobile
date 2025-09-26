import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/OtpPasswordScreen.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  bool rememberMe = false;
  bool passwordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }


  Future<void> _handleSendOtp() async {
    final noWhatsapp = emailController.text.trim();

    if (noWhatsapp.isEmpty) {
      _showMessage('Nomor WhatsApp wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await Requesthelper.forgotPassword(noWhatsapp);



    if (result['success'] == true) {
      _showMessage(result['message'] ?? 'OTP berhasil dikirim');
      // Navigasi ke halaman OTP, kirim nomor WhatsApp kalau perlu
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPasswordScreen(noWhatsapp: noWhatsapp),
        ),
      );
    } else {
      _showMessage(result['message'] ?? 'Gagal mengirim OTP');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    // Kalau mau pakai toast ganti saja dengan:
    // Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <-- ini yang kamu cari

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gambar tanpa padding
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
              // const SizedBox(height: 45),

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
              Center(
                child: Column(
                  children: [
                    Text(
                      'Lupa Password',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            12), // beri jarak antara judul dan teks berikutnya
                    Text(
                      'Masukkan Nomor WhatsApp Anda untuk Mengatur Ulang\n Password Anda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Color(0XFF808080),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Form dengan padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No.WhatsApp *',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'Masukkan Nomor WhatsApp Anda',
                        hintStyle: GoogleFonts.manrope(),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleSendOtp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFF0071CE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Kirim',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
