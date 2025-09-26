import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/ForgotPassword.dart';
import 'package:patroli/ui/HomePage.dart';
import 'package:patroli/ui/LoginPage.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String noWhatsapp;
  final String token;

  const ResetPasswordScreen(
      {super.key, required this.noWhatsapp, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool rememberMe = false;
  bool passwordVisible = false;
  final konfirmasiPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  bool isFormFilled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;

    konfirmasiPasswordController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    bool loggedIn = await Requesthelper.isLoggedIn();

    if (loggedIn) {
      // User sudah login, langsung ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  void handleUpdatePassword() async {
    setState(() {
      isLoading = true;
    });

    final password = passwordController.text;
    final konfirmasiPasswored = konfirmasiPasswordController.text;

    final result = await Requesthelper.resetPasswordData(
      noWhatsapp: widget.noWhatsapp,
      password: password,
      passwordConfirmation: konfirmasiPasswored,
      token: widget.token,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      String errorMessage = result['message'] ?? 'Login gagal';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Color(0XFF55EFC4),
        ),
      );

      // Login sukses, arahkan ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      String errorMessage = result['message'] ?? 'Login gagal';

      // Jika ada error validasi banyak, gabungkan jadi string
      if (result.containsKey('errors') && result['errors'] is List) {
        errorMessage = (result['errors'] as List).join('\n');
      }

      print(errorMessage);
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateButtonState() {
    setState(() {
      print("checking");
      isFormFilled = konfirmasiPasswordController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 16),
              //   child: Image.asset(
              //     'assets/bglogin.png',
              //     width: double.infinity,
              //     height: 250,
              //     fit: BoxFit
              //         .cover, // <-- ubah dari BoxFit.cover ke BoxFit.contain
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
                      'Update Password',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            12), // beri jarak antara judul dan teks berikutnya
                    Text(
                      'Masukan password baru anda untuk bisa masuk ke akun anda kembali',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Color(0XFF808080),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Form dengan padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email *',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                        ),
                        hintText: 'Masukkan Password Anda',
                        hintStyle: GoogleFonts.manrope(),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => passwordVisible = !passwordVisible);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: konfirmasiPasswordController,
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock_outline,
                        ),
                        hintText: 'Masukkan Konfirmasi Password Anda',
                        hintStyle: GoogleFonts.manrope(),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => passwordVisible = !passwordVisible);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          handleUpdatePassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormFilled
                              ? const Color(0XFF0071CE)
                              : const Color(0xFFABABAB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Update Password',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
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
