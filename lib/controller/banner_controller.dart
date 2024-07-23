
import 'dart:convert';

import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/model/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class BannerController extends GetxController{
  static BannerController instance = Get.find();
  Rxn<Banner_Model> banner = Rxn<Banner_Model>();
  late BuildContext context;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
  Future<List<Banner_Model>> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/banners?populate=image_banner'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Raw JSON response: $jsonResponse'); // Thêm dòng này
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) {
          try {
            return Banner_Model.fromJson({
              'id': json['id'],
              ...json['attributes'] ?? {},
            });
          } catch (e, stackTrace) {
            print('Error parsing banner: $e');
            print('Stack trace: $stackTrace');
            print('Problematic JSON: $json');
            return null;
          }
        }).whereType<Banner_Model>().toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error loading banners: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }


}