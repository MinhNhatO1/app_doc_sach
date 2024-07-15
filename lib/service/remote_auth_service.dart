import 'dart:convert';

import 'package:app_doc_sach/const.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'local_service/local_auth_service.dart';

class RemoteAuthService {
  var client = http.Client();
  final LocalAuthService _localAuthService = LocalAuthService();
  Future<dynamic> signUp({
    required String email,
    required String password,
}) async {
    var body = {
      "username": email,
      "email": email,
      "password": password,
      'role_user': "client",
      'type': "email",
    };
    var response = await client.post(
      Uri.parse('$baseUrl/api/auth/local/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return response;
  }

  Future<dynamic> createProfile({
    required String token,
    required String fullName,
  }) async {
    var body = {
      "fullName": fullName
    };
    var response = await client.post(
      Uri.parse('$baseUrl/api/profile/me'),
      headers: {"Content-Type": "application/json",
      "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<dynamic> createProfileGoogle({
    required String token,
    required String fullName,
    String? photoUrl, // Thêm thông tin ảnh từ Google vào đây
  }) async {
    var body = {
      "fullName": fullName,
      "image": photoUrl, // Thêm avatar từ Google vào body request
    };
    var response = await client.post(
      Uri.parse('$baseUrl/api/profile/me'),
      headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );
    return response;
  }
  Future<dynamic> signIn({
    required String email,
    required String password,
  }) async {
    var body = {
      "identifier" : email,
      "password": password
    };
    var response = await client.post(
      Uri.parse('$baseUrl/api/auth/local'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return response;
  }

  Future<dynamic> getProfile({
    required String token
  }) async {
    var response = await client.get(
      Uri.parse('$baseUrl/api/profile/me'),
      headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    return response;
  }

  Future<dynamic> getUserByEmail({
    required String email,required String token,
  }) async {
    var response = await client.get(
      Uri.parse('$baseUrl/api/profile/me?email=$email'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return response;
  }

  Future<dynamic> getUserIdByEmail(String email, String token) async {
    try {
      var response = await client.get(
        Uri.parse('$baseUrl/api/profile/me?email=$email'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var profileId = responseBody['id']; // Lấy trực tiếp giá trị id từ responseBody
        return profileId.toString(); // Chuyển đổi thành chuỗi nếu cần thiết
      } else {
        print("Failed to fetch user by email: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
    return null;
  }


  Future<dynamic> updateProfile({
    required String token,
    required String userId,
    required String fullName,
    required String phone,
    required String address,
   required DateTime age,
    required String gender,
  }) async {
      var body = {
        "data": {
          "fullName": fullName,
          "phone": phone,
          "address": address,
         "age": DateFormat('yyyy-MM-dd').format(age), // Định dạng ngày tháng khi gửi dữ liệu
          "gender": gender,
        }
      };

      // Gửi yêu cầu PUT để cập nhật hồ sơ
      var response = await client.put(
        Uri.parse('$baseUrl/api/profiles/$userId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      return response;
  }
/*
  Future<http.Response> updateProfileGoogle({
    required String token,
    required String fullName,

  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/me'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'avatar': avatar,
        }),
      );
      return response;
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }*/
}

