import 'dart:convert';

import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/model/author_model.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
class CategoryController extends GetxController{
  static CategoryController instance = Get.find();
  Rxn<CategoryModel> category = Rxn<CategoryModel>();
  late BuildContext context;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/categories')); // Thay thế bằng đường dẫn API thực của bạn

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['data']; // Giải mã phản hồi JSON
        List<CategoryModel> categoriesList = data.map((json) => CategoryModel.fromJson(json)).toList(); // Ánh xạ các đối tượng JSON thành đối tượng Author
        return categoriesList; // Trả về danh sách các tác giả
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e'); // Ném ra một ngoại lệ nếu có lỗi khi tải dữ liệu
    }
  }

  Future<List<CategoryModel>> getCategoriesBySearch(String textSearch) async {
    // Chuẩn hóa chuỗi tìm kiếm: chuyển về chữ thường và loại bỏ khoảng trắng
    final normalizedSearch = textSearch.toLowerCase().replaceAll(' ', '');

    // Xây dựng URL API với toán tử $containsi
    final String apiUrl = '$baseUrl/api/categories?populate=*&filters[name][\$containsi]=$textSearch';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['data']; // Giải mã phản hồi JSON
        return data.map((json) {
          try {
            return CategoryModel.fromJson(json);
          } catch (e) {
            print('Error parsing book: $e');
            return null;
          }
        }).whereType<CategoryModel>().toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching books by search: $e');
      rethrow;
    }
  }
}