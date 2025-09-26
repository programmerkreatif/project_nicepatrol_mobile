import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class LoggedinHelper {
  static const String baseUrl =
      // 'http://www.programmerkreatif.biz.id:81/patroli/web/api'; // Ganti dengan URL-mu
      'http://www.programmerkreatif.biz.id:7787/api'; // Ganti dengan URL-mu

  static Future<Map<String, dynamic>> checkStatusAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.'
      };
    }

    final url = Uri.parse('$baseUrl/auth/checkStatus');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final contentType = response.headers['content-type'] ?? '';

      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON. Kemungkinan error server atau endpoint salah. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] != null) {
        return {
          'success': true,
          'message': data['message'] ?? '',
          'status': {
            'clock_in': data['status']['clock_in'] ?? false,
            'clock_out': data['status']['clock_out'] ?? false,
          }
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mendapatkan status absensi.',
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
    required int branchId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.'
      };
    }

    final url = Uri.parse('$baseUrl/auth/getlocation');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'branch_id': branchId,
        }),
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message':
              'Response bukan JSON. Cek server atau endpoint. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? '',
          'distance': data['distance_in_meters'],
          'is_within_radius': data['is_within_radius'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memeriksa lokasi.',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // static Future<Map<String, dynamic>> clockIn({
  //   required String userId,
  //   required double latitude,
  //   required double longitude,
  //   required String notes,
  //   required File photoFile,
  //   required File documentFile,
  //   required DateTime dateClock,
  //   required String clockInTime, // format "HH:mm:ss"
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');

  //   if (token == null) {
  //     return {
  //       'success': false,
  //       'message': 'Token tidak ditemukan. Silakan login ulang.'
  //     };
  //   }

  //   final uri =
  //       Uri.parse('$baseUrl/auth/clockIn'); // Sesuaikan endpoint clockin-mu

  //   var request = http.MultipartRequest('POST', uri);
  //   request.headers['Authorization'] = 'Bearer $token';

  //   request.fields['user_id'] = userId.toString();
  //   request.fields['latitude'] = latitude.toString();
  //   request.fields['longitude'] = longitude.toString();
  //   // if (address != null) request.fields['address'] = address;
  //   request.fields['notes'] = notes;
  //   request.fields['date_clock'] =
  //       dateClock.toIso8601String().split('T').first; // yyyy-mm-dd
  //   request.fields['clock_in'] = clockInTime;

  //   request.files
  //       .add(await http.MultipartFile.fromPath('photo', photoFile.path));
  //   request.files
  //       .add(await http.MultipartFile.fromPath('document', documentFile.path));

  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     final contentType = response.headers['content-type'] ?? '';
  //     if (!contentType.contains('application/json')) {
  //       return {
  //         'success': false,
  //         'message': 'Response bukan JSON. Body:\n${response.body}',
  //       };
  //     }

  //     final data = jsonDecode(response.body);
  //     if (response.statusCode == 201) {
  //       return {
  //         'success': true,
  //         'message': data['message'] ?? 'Clock-in berhasil',
  //         'data': data['data'] ?? {},
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': data['message'] ?? 'Gagal clock-in',
  //         'errors': data['errors'] ?? {},
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Terjadi kesalahan: ${e.toString()}',
  //     };
  //   }
  // }

  // static Future<Map<String, dynamic>> clockOut({
  //   required String userId,
  //   required double latitude,
  //   required double longitude,
  //   required String notes,
  //   required File photoFile,
  //   required File documentFile,
  //   required DateTime dateClock,
  //   required String clockOutTime, // format "HH:mm:ss"
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');

  //   if (token == null) {
  //     return {
  //       'success': false,
  //       'message': 'Token tidak ditemukan. Silakan login ulang.'
  //     };
  //   }

  //   final uri =
  //       Uri.parse('$baseUrl/auth/clockOut'); // Sesuaikan endpoint clockout-mu

  //   var request = http.MultipartRequest('POST', uri);
  //   request.headers['Authorization'] = 'Bearer $token';

  //   request.fields['user_id'] = userId.toString();
  //   request.fields['latitude'] = latitude.toString();
  //   request.fields['longitude'] = longitude.toString();
  //   // if (address != null) request.fields['address'] = address;
  //   request.fields['notes'] = notes;
  //   request.fields['date_clock'] =
  //       dateClock.toIso8601String().split('T').first; // yyyy-mm-dd
  //   request.fields['clock_out'] = clockOutTime;

  //   request.files
  //       .add(await http.MultipartFile.fromPath('photo', photoFile.path));
  //   request.files
  //       .add(await http.MultipartFile.fromPath('document', documentFile.path));

  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     final contentType = response.headers['content-type'] ?? '';
  //     if (!contentType.contains('application/json')) {
  //       return {
  //         'success': false,
  //         'message': 'Response bukan JSON. Body:\n${response.body}',
  //       };
  //     }

  //     final data = jsonDecode(response.body);
  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'message': data['message'] ?? 'Clock-out berhasil',
  //         'data': data['data'] ?? {},
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': data['message'] ?? 'Gagal clock-out',
  //         'errors': data['errors'] ?? {},
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Terjadi kesalahan: ${e.toString()}',
  //     };
  //   }
  // }

  static Future<Map<String, dynamic>> clockIn({
    required String userId,
    required double latitude,
    required double longitude,
    required String notes,
    required File photoFile,
    File? documentFile,
    required DateTime dateClock,
    required String clockInTime,
    bool izin = false,
    bool lembur = false,
    String? source,
    String? reference,
    String? address,
    String? imageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.'
      };
    }

    final uri = Uri.parse('$baseUrl/auth/clockIn');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['user_id'] = userId;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['notes'] = notes;
    request.fields['date_clock'] = dateClock.toIso8601String().split('T').first;
    request.fields['clock_in'] = clockInTime;
    request.fields['lembur'] = lembur ? '1' : '0';
    request.fields['izin'] = izin ? '1' : '0';

    if (source != null) request.fields['source'] = source;
    if (reference != null) request.fields['reference'] = reference;
    if (address != null) request.fields['address'] = address;
    if (imageId != null) request.fields['image_id'] = imageId;

    if (await photoFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );
    }
    // request.files
    //     .add(await http.MultipartFile.fromPath('photo', photoFile.path));

    // Hanya tambahkan dokumen jika tersedia
    if (documentFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('document', documentFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message': 'Response bukan JSON. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Clock-in berhasil',
          'data': data['data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal clock-in',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> clockOut({
    required String userId,
    required double latitude,
    required double longitude,
    required String notes,
    required File photoFile,
    File? documentFile,
    required DateTime dateClock,
    required String clockOutTime,
    String? source,
    String? reference,
    String? address,
    String? imageId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.'
      };
    }

    final uri = Uri.parse('$baseUrl/auth/clockOut');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['user_id'] = userId;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['notes'] = notes;
    request.fields['date_clock'] = dateClock.toIso8601String().split('T').first;
    request.fields['clock_out'] = clockOutTime;

    if (source != null) request.fields['source'] = source;
    if (reference != null) request.fields['reference'] = reference;
    if (address != null) request.fields['address'] = address;
    if (imageId != null) request.fields['image_id'] = imageId;

    // request.files
    //     .add(await http.MultipartFile.fromPath('photo', photoFile.path));

    if (await photoFile.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );
    }

    // Hanya tambahkan dokumen jika tersedia
    if (documentFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('document', documentFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          'message': 'Response bukan JSON. Body:\n${response.body}',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Clock-out berhasil',
          'data': data['data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal clock-out',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
