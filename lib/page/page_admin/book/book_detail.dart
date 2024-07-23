import 'package:app_doc_sach/const/constant.dart';
import 'package:flutter/material.dart';

import '../../../const.dart';
import '../../../controller/book_controller.dart';
import '../../../model/book_model.dart';
import 'edit_book.dart';

class BookDetailAdmin extends StatefulWidget {
  const BookDetailAdmin({super.key, required this.book});
  final Book book;
  @override
  State<BookDetailAdmin> createState() => _StateBookDetail();
}

class _StateBookDetail extends State<BookDetailAdmin> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book; // Khởi tạo thông tin sách
    _refreshBookDetails();
  }

  Future<void> _deleteBook(BuildContext context) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn xóa sách này không?'),
          actions: <Widget>[
            TextButton(
              child: Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop(false); // Đóng dialog và trả về false
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop(true); // Đóng dialog và trả về true
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Gọi phương thức xóa sách nếu người dùng đã xác nhận
      bool success = await BookController.instance.deleteBook(_book.id.toString());
      if (success) {
        // Xử lý thành công (ví dụ: quay lại màn hình danh sách sách, cập nhật UI, ...)
        print('Đã xóa sách thành công');
        Navigator.of(context).pop(); // Quay lại màn hình trước đó sau khi xóa sách
      } else {
        // Xử lý thất bại (ví dụ: thông báo lỗi, ...)
        print('Xóa sách thất bại');
      }
    } else {
      // Người dùng huỷ bỏ xóa sách
      print('Huỷ bỏ xóa sách');
    }
  }

  Future<void> _editBook() async {
    // Chuyển đến trang chỉnh sửa sách
    final bool? result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditBookPage(book: _book),
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

    if (result == true) {
      // Làm mới thông tin sách sau khi chỉnh sửa thành công
      _refreshBookDetails();
    }
  }

  Future<void> _refreshBookDetails() async {
    // Lấy thông tin sách mới từ server hoặc bất kỳ nguồn nào
    Book updatedBook = await BookController.instance.getBookById(_book.id.toString());
    setState(() {
      _book = updatedBook; // Cập nhật trạng thái của sách
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.title ?? 'Chi tiết sách'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  baseUrl + _book.coverImage!.url,
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tiêu đề sách
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                ),
                children: [
                  const TextSpan(
                    text: 'Tên sách: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: _book.title ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ISBN
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text: 'ISBN: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(
                    text: _book.isbn ?? 'Không có ISBN',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tác giả
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Tác giả: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _book.authors!.isNotEmpty
                        ? _book.authors!.map((author) => author.authorName).join(', ')
                        : 'Không có tác giả',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ngôn ngữ
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Ngôn ngữ: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _book.language ?? 'Không có Ngôn ngữ',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Số trang
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Số trang: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _book.pages.toString() ?? 'Không có số lượng trang',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Trạng thái sách
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Trạng thái sách: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _book.status.toString() ?? 'Không có số lượng trang',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  _book.likes.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.visibility_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  _book.view.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Thể loại
            const Text(
              'Thể loại:',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Danh sách thể loại
            if (_book.categories!.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _book.categories!.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0), // Add some spacing between the chips
                      child: Chip(
                        label: Text(
                          category.nameCategory,
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              const Text(
                'Không có thể loại',
                style: TextStyle(
                  color: Colors.white70,
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
            Text(
              _book.description ?? 'Không có mô tả',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
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
                  onPressed: _editBook,
                  child:
                  const Row(
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
                  onPressed: () => _deleteBook(context),
                  child:
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 10), // Khoảng cách giữa icon và văn bản
                      Text('Xóa'), // Văn bản
                    ],
                  )

              ),

            ],
          ),
        ),
      ),

    );
  }
}
