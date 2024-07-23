import 'package:app_doc_sach/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_doc_sach/model/vip_model.dart';
import 'package:app_doc_sach/model/user_model.dart';

import '../const.dart';
import '../page/login_register/service/auth_service.dart';
import '../service/local_service/local_auth_service.dart';
import '../service/remote_auth_service.dart';

class VipService extends GetxController {
  static VipService instance = Get.find();
  Rxn<Vip> vip = Rxn<Vip>();
  late BuildContext context;
  @override
  void onInit()  async {
    // TODO: implement onInit
    super.onInit();

  }

  Future<Vip?> checkVipStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vips?filters[profile][id]=$userId&populate=*'),
        headers: {
          'Content-Type': 'application/json',
          // Thêm header xác thực nếu cần
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        if (data.isNotEmpty) {
          final vipData = data[0]['attributes'];
          vipData['id'] = data[0]['id']; // Thêm id vào attributes
          return Vip.fromJson(vipData);
        }
      }
      return null; // Trả về null nếu không tìm thấy VIP hoặc có lỗi
    } catch (e) {
      print('Error checking VIP status: $e');
      return null;
    }
  }

  bool isVipActive(Vip? vip) {
    if (vip == null) return false;
    final now = DateTime.now();
    return vip.status && vip.dayEnd.isAfter(now);
  }
  static Future<void> extendVip(String userid, String duration) async {
    final DateTime now = DateTime.now();
    final Duration extensionDuration = _getDurationFromString(duration);

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/vips?filters[profile][id]=$userid'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> vips = responseData['data'] as List<dynamic>;

        if (vips.isNotEmpty) {
          // Update existing VIP
          final Map<String, dynamic> vipData = vips.first['attributes'] as Map<String, dynamic>;
          print('VIP Data: $vipData');
          final int vipId = int.tryParse(vips.first['id'].toString()) ?? 0;
          if (vipId == 0) {
            throw Exception('Invalid VIP ID');
          }
          final Vip existingVip = Vip.fromJson(vipData);
          await updateVip(vipId, existingVip, extensionDuration);
        } else {
          // Create new VIP
          await createVip(userid, now, extensionDuration);
        }
      } else {
        throw Exception('Failed to check existing VIP');
      }
    } catch (e) {
      print('Error extending VIP: $e');
      throw e;
    }
  }


  static Future<Vip?> getVipByUserId(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/vips?filters[profile][id]=$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> vips = responseData['data'] as List<dynamic>;

        if (vips.isNotEmpty) {
          final Map<String, dynamic> vipData = vips.first['attributes'] as Map<String, dynamic>;
          return Vip.fromJson(vipData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting VIP info: $e');
      return null;
    }
  }

  static Future<void> updateVip(int vipId, Vip existingVip, Duration extensionDuration) async {
    final now = DateTime.now();
    DateTime newStartDate;
    DateTime newEndDate;

    if (!existingVip.status || existingVip.dayEnd.isBefore(now)) {
      // If status is false or VIP has expired, reset start date and calculate new end date
      newStartDate = now;
      newEndDate = now.add(extensionDuration);
    } else {
      // If VIP is still active, set new start date to today and calculate remaining days
      newStartDate = now;
      Duration remainingDuration = existingVip.dayEnd.difference(now);
      newEndDate = now.add(remainingDuration + extensionDuration);
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/vips/$vipId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'data': {
          'dayStart': newStartDate.toIso8601String(),
          'dayEnd': newEndDate.toIso8601String(),
          'status': true,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update VIP');
    }
  }
/*
  Future<void> updateVipStatusMain(int vipId, bool status) async {
    try {
      await updateVipStatus(vipId, status);
      // Refresh VIP data after updating status
      await fetchVipData();
    } catch (e) {
      print('Error updating VIP status: $e');
    }
  }*/

  static Future<void> checkAndUpdateVipStatus(String userId) async {
    final vip = await getVipByUserId(userId);
    if (vip != null) {
      final now = DateTime.now();
      if (now.isAfter(vip.dayEnd) && vip.status) {
        await updateVipStatus(vip.id, false);
      }
    }
  }
  static Future<void> updateVipStatus(int vipId, bool status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/vips/$vipId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'data': {
          'status': status,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update VIP status');
    }
  }
  static Future<void> createVip(String userid, DateTime startDate, Duration duration) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/vips'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': {
            'profile': userid,
            'dayStart': startDate.toIso8601String(),
            'dayEnd': startDate.add(duration).toIso8601String(),
            'status': true,
          }
        }),
      );

      print('Create VIP response status: ${response.statusCode}');
      print('Create VIP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('VIP created successfully');
      } else {
        throw Exception('Failed to create VIP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createVip: $e');
      throw e;
    }
  }

  static Duration _getDurationFromString(String duration) {
    switch (duration) {
      case '1 TUẦN':
        return const Duration(days: 7);
      case '1 THÁNG':
        return const Duration(days: 30);
      case '6 THÁNG':
        return const Duration(days: 180);
      case '1 NĂM':
        return const Duration(days: 365);
      default:
        throw ArgumentError('Invalid duration');
    }
  }
}