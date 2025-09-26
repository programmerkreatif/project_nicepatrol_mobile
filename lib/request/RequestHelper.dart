import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Requesthelper {
  static const String baseUrl =
      // 'http://www.programmerkreatif.biz.id:81/patroli/web/api'; // Ganti dengan URL-mu
      'http://www.programmerkreatif.biz.id:7787/api'; // Ganti dengan URL-mu

  static Future<Map<String, dynamic>> forgotPassword(String noWhatsapp) async {
    final url = Uri.parse(
        '$baseUrl/auth/forgot-password'); // Pastikan endpoint sesuai route-mu

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'no_whatsapp': noWhatsapp}),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'OTP sent successfully') {
        return {
          'success': true,
          'message': 'OTP berhasil dikirim ke nomor WhatsApp: $noWhatsapp',
          'data': data,
        };
      }

      if (response.statusCode == 404 ||
          (data['status'] == false && data['message'] != null)) {
        // Nomor whatsapp tidak ditemukan
        return {
          'success': false,
          'message': data['message'] ?? 'Nomor WhatsApp tidak ditemukan',
        };
      }

      // Jika gagal kirim OTP
      if (response.statusCode == 500) {
        return {
          'success': false,
          'message': data['status'] ?? 'Gagal mengirim OTP',
          'error': data['error'] ?? 'Error tidak diketahui',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan yang tidak diketahui.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String noWhatsapp, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'no_whatsapp': noWhatsapp,
          'otp': otp,
        }),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        return {
          'success': true,
          'message': 'OTP valid, login berhasil',
          'token': data['token'],
          'user': data['user'],
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid OTP',
        };
      }

      if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP not found or expired',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan yang tidak diketahui.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPasswordData({
    required String noWhatsapp,
    required String password,
    required String passwordConfirmation,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'no_whatsapp': noWhatsapp,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'token': token,
        }),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      // Status bisa berupa string sukses seperti Password::PASSWORD_RESET atau pesan error
      if (response.statusCode == 200 && data['status'] == 'passwords.reset') {
        return {
          'success': true,
          'message': 'Password berhasil direset',
        };
      }

      return {
        'success': false,
        'message': data['status'] ?? 'Gagal reset password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        // Response bukan JSON, kemungkinan error server
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_email', email);
        await prefs.setString('user_id', data['user']['id'].toString());
        await prefs.setString('user_name', data['user']['name'].toString());
        await prefs.setString(
            'user_branch_id', data['user']['employee']['branch_id'].toString());
        return {'success': true, 'data': data};
      }

      if (response.statusCode == 422 && data['errors'] != null) {
        final errorMessages = <String>[];

        data['errors'].forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((e) => e.toString()));
          } else {
            errorMessages.add(value.toString());
          }
        });

        return {
          'success': false,
          'message': data['message'] ?? 'Validasi gagal',
          'errors': errorMessages
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Login gagal. Email atau password salah.'
        };
      }

      // Untuk status lain, return pesan dari server
      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan yang tidak diketahui.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> getdropdownlocation() async {
    final url = Uri.parse('$baseUrl/auth/dropdownlocation');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      print("check get data");
      print(data);

      if (response.statusCode == 200) {
        // sesuaikan: sukses API Anda
        return {
          'success': true,
          'data': data['data'],
        };
      }

      // kalau tidak sukses atau status != true
      return {
        'success': false,
        'message': 'Gagal memuat data dashboard',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getarea() async {
    final url = Uri.parse('$baseUrl/auth/getarea');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // sesuaikan: sukses API Anda
        return {
          'success': true,
          'data': data['data'],
        };
      }

      // kalau tidak sukses atau status != true
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat data dashboard',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getpatrolarea(String areaId) async {
    final url = Uri.parse('$baseUrl/auth/patrolarea?area_id=' + areaId);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // sesuaikan: sukses API Anda
        return {
          'success': true,
          'data': data['data'],
        };
      }

      // kalau tidak sukses atau status != true
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat data dashboard',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardData() async {
    final url = Uri.parse('$baseUrl/auth/owndata');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.'
        };
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON, kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // sesuaikan: sukses API Anda
        return {
          'success': true,
          'data': data['data'],
        };
      }

      // kalau tidak sukses atau status != true
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat data dashboard',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> checkLocationStatus({
    required double latitude,
    required double longitude,
    String? areaId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/getlocation');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Ambil token login user

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Harap login ulang.',
        };
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'area_id': areaId,
          'branch_id': null, // Bisa dihapus jika tidak perlu
        }),
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message': 'Response bukan JSON. Server error atau endpoint salah.',
          'raw_response': response.body,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'distance': data['distance_in_meters'],
          'is_within_radius': data['is_within_radius'].toString(),
          'message': data['message'],
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Validasi gagal',
          'errors': data['errors'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Exception: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchNotifications({String? filter}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan.',
        'data': [],
      };
    }

    final uri = Uri.parse('$baseUrl/auth/noifikasi${filter != null ? '?filter=$filter' : ''}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message': 'Format response bukan JSON',
          'data': [],
          'count': [],

        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal ambil data',
        'data': [],
        'count': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Exception: $e',
        'data': [],
        'count': [],

      };
    }
  }
 
  static Future<Map<String, dynamic>> getProfileData() async {
    final url = Uri.parse('$baseUrl/auth/getprofiledata');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message': 'Response bukan JSON. Cek endpoint atau server.',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat data profil.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchAbsensi(int month, int year) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse('$baseUrl/api/auth/listabsensi?month=$month&year=$year');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success'] == true) {
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil data absensi');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_branch_id');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
