import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/request/RequestHelper.dart';
import 'package:patroli/ui/ForgotPassword.dart';
import 'package:patroli/ui/HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  bool passwordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isFormFilled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;

    emailController.addListener(_updateButtonState);
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


  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final result = await Requesthelper.login(email, password);

    print(result);

    setState(() {
      isLoading = true;
    });

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0XFF0071CE),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );


    await Future.delayed(const Duration(seconds: 2)); // jeda 2 detik



    if (result['success']) {
      // Login sukses, arahkan ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {

        // Tutup loading dialog
      Navigator.of(context, rootNavigator: true).pop();


      String errorMessage = result['message'] ?? 'Login gagal';

      // Jika ada error validasi banyak, gabungkan jadi string
      if (result.containsKey('errors') && result['errors'] is List) {
        errorMessage = (result['errors'] as List).join('\n');
      }


      
      setState(() {
        isLoading = false;
      });




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
      isFormFilled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
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
                child: Text(
                  'Masuk',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'Masukkan Email Anda',
                        hintStyle: GoogleFonts.manrope(),
                        border: InputBorder.none,
                        // border: const OutlineInputBorder(
                        //   borderRadius: BorderRadius.zero
                        //   // borderRadius: BorderRadius.all(Radius.circular(10)),
                        // ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password *',
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
                    Row(
                      children: [
                        // Checkbox(
                        //   value: rememberMe,
                        //   onChanged: (value) {
                        //     setState(() => rememberMe = value ?? false);
                        //   },
                        // ),

                        Checkbox(
                          value: rememberMe,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // sesuaikan radius-nya
                          ),
                          onChanged: (value) {
                            setState(() => rememberMe = value ?? false);
                          },
                        ),

                        Text(
                          'Ingatkan Saya',
                          style: GoogleFonts.manrope(),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Forgotpassword()),
                            );
                          },
                          child: Text(
                            'Lupa Password?',
                            style: GoogleFonts.manrope(
                              color: Color(0XFF0071CE),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          handleLogin();
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
                          'Login',
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
