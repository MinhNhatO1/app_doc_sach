import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/author_model.dart';
import 'package:app_doc_sach/page/page_admin/author/display_author.dart';
import 'package:app_doc_sach/page/page_admin/author/edit_author.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';  // Import the intl package

class AuthorDetails extends StatefulWidget {
  final Author authors;
  const AuthorDetails({required this.authors});

  @override
  _AuthorDetailState createState() => _AuthorDetailState();
}
//update
class _AuthorDetailState extends State<AuthorDetails> {
  void _deleteAuthor() async {
    await http.delete(
      Uri.parse("$baseUrl/api/authors/${widget.authors.id}"),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const DisplayAuthor()),
      (Route<dynamic> route) => false,
    );
  }

  void _editAuthor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAuthor(authors: widget.authors),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedBirthDate = DateFormat('dd-MM-yyyy').format(widget.authors.birthDate!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.authors.authorName ?? 'Chi tiết tác giả'),
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
            // Author Name
            Row(
              children: [
                const Text(
                  'Tên tác giả: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.authors.authorName ?? 'Không có tên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Birth Date
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text: 'Ngày sinh: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(
                    text: formattedBirthDate,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Born
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Nơi sinh: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.authors.born ?? 'Không có nơi sinh',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Telephone
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Số điện thoại: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.authors.telphone ?? 'Không có số điện thoại',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nationality
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Quốc tịch: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.authors.nationality ?? 'Không có quốc tịch',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            const Text(
              'Tiểu sử:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.authors.bio != null && widget.authors.bio!.isNotEmpty)
              Text(
                widget.authors.bio!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              )
            else
              const Text(
                'Không có tiểu sử',
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
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                ),
                onPressed: _editAuthor,
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 10), // Khoảng cách giữa icon và văn bản
                    Text('Cập nhật'), // Văn bản
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                ),
                onPressed: _deleteAuthor,
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
