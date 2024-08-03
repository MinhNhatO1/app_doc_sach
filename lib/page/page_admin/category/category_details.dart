import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/page/page_admin/category/display_category.dart';
import 'package:app_doc_sach/page/page_admin/category/edit_category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../../const.dart';

class MyDetails extends StatefulWidget {
  final CategoryModel categories;
  const MyDetails({required this.categories});

  @override
  _MyDetailsState createState() => _MyDetailsState();
}
//update
class _MyDetailsState extends State<MyDetails> {
  void deleteCategory() {
    showDeleteConfirmationDialog(
      context,
          () async {
        await http.delete(
          Uri.parse("$baseUrl/api/categories/${widget.categories.id}"),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const DisplayCategory()),
              (Route<dynamic> route) => false,
        );
      },
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
  void showDeleteConfirmationDialog(BuildContext context, Function onConfirm) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: Curves.easeInOut.transform(a1.value),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Color(0xFF2A2D3E),
              content: Container(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/delete_animation.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Xác nhận xóa',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bạn có chắc chắn muốn xóa thể loại này?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: Text('Hủy'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.grey[700],
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          child: Text('Xóa'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) => Container(),
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
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả thể loại (nếu có)
            if (widget.categories.desCategory != null && widget.categories.desCategory!.isNotEmpty)
              Text(
                textAlign: TextAlign.justify,
                widget.categories.desCategory!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
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
