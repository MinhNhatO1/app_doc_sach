import 'dart:convert';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/page/listbook_category/lisistbook_category.dart';
import 'package:app_doc_sach/provider/ui_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../const.dart';

class DanhMucWidget extends StatefulWidget {
  const DanhMucWidget({super.key});

  @override
  State<DanhMucWidget> createState() => _DanhMucWidgetState();
}

class _DanhMucWidgetState extends State<DanhMucWidget> {
  List<CategoryModel> listCategory = [];
  bool isLoading = true;

  Future<void> fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/categories?pagination[pageSize]=100');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categoriesData = data['data'];

        setState(() {
          listCategory = categoriesData.map<CategoryModel>((json) {
            return CategoryModel.fromJson(json);
          }).toList();
          isLoading = false;
        });

        print('Fetched categories:');
        for (var category in listCategory) {
          print(category);
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UiProvider>(
      builder: (BuildContext context, UiProvider value, Widget? child) {
        return Scaffold(
          body: Container(
            color: value.isDark
                ? Colors.black12
                : const Color.fromRGBO(232, 245, 233, 1.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
              children: [
                Expanded(
                  child: gridview_danhmuc(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget gridview_danhmuc() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0), // Margin top 10 and bottom 30
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: listCategory.length,
        itemBuilder: (context, index) {
          final category = listCategory[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ListBookCategory(category: category),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 300), // Thời gian chuyển đổi
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category.nameCategory,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
