import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/page/page_admin/category/display_category.dart';
import 'package:app_doc_sach/page/page_admin/category/edit_category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../const.dart';

class MyDetails extends StatefulWidget {
  final CategoryModel categories;
  const MyDetails({required this.categories});

  @override
  _MyDetailsState createState() => _MyDetailsState();
}
//update
class _MyDetailsState extends State<MyDetails> {
  void deleteCategory() async {
    await http.delete(
      Uri.parse("$baseUrl/api/categories/${widget.categories.id}"),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const DisplayCategory()),
      (Route<dynamic> route) => false,
    );
  }

  void _editCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategory(categories: widget.categories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thể loại'),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // ID
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'ID: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.categories.id.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tên thể loại
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Tên thể loại: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.categories.nameCategory,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Mô tả
            const Text(
              'Mô tả:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả thể loại (nếu có)
            if (widget.categories.desCategory != null && widget.categories.desCategory!.isNotEmpty)
              Text(
                widget.categories.desCategory!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              )
            else
              const Text(
                'Không có mô tả',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: BottomAppBar(
          color: backgroundColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                  ),
                  onPressed: _editCategory,
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 10), // Khoảng cách giữa icon và văn bản
                      Text('Cập nhật'), // Văn bản
                    ],
                  )
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                ),
                onPressed: deleteCategory,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 10), // Khoảng cách giữa icon và văn bản
                    Text('Xóa'), // Văn bản
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
