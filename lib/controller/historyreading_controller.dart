import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../const.dart';
import '../model/readinghistory_model.dart';
import 'package:http/http.dart' as http;
class ReadingHistoryController extends GetxController{
  static ReadingHistoryController instance = Get.find();
  Rxn<ReadingHistory> hitoryreading = Rxn<ReadingHistory>();
  late BuildContext context;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<void> getAllReadingHistories(String userId, RxList<ReadingHistory> histories, RxBool isLoading) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/reading-histories?/api/reading-histories?filters[profile][id]=$userId&populate[book][populate][chapters][populate]=files&populate[profile]=*&populate[chapter][populate]=files'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        histories.value = (data['data'] as List).map((item) => ReadingHistory.fromJson(item)).toList();
        isLoading.value = false;
      } else {
        throw Exception('Failed to load reading histories');
      }
    } catch (e) {
      print('Error in getAllReadingHistories: $e');
      isLoading.value = false;
    }
  }


  Future<void> updateReadingHistory(ReadingHistory history) async {
    if (history.id != null) {
      await http.put(
        Uri.parse('$baseUrl/reading-histories/${history.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'data': history.toJson()}),
      );
    } else {
      await http.post(
        Uri.parse('$baseUrl/reading-histories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'data': history.toJson()}),
      );
    }
  }
}