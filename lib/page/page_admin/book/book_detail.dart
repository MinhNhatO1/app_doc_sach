import 'package:app_doc_sach/const/constant.dart';
import 'package:flutter/material.dart';

import '../../../const.dart';
import '../../../controller/book_controller.dart';
import '../../../model/book_model.dart';
import 'edit_book.dart';

class BookDetailAdmin extends StatefulWidget {
  const BookDetailAdmin ({super.key,required this.book});
  final Book book;
  @override
  State<BookDetailAdmin> createState() => _StateBookDetail();
}

class _StateBookDetail extends State<BookDetailAdmin> {
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
      bool success = await BookController.instance.deleteBook(widget.book.id.toString());
      if (success) {
        // Xử lý thành công (ví dụ: quay lại màn hình danh sách sách, cập nhật UI, ...)
        print('Đã xóa sách thành công');
      } else {
        // Xử lý thất bại (ví dụ: thông báo lỗi, ...)
        print('Xóa sách thất bại');
      }
    } else {
      // Người dùng huỷ bỏ xóa sách
      print('Huỷ bỏ xóa sách');
    }
  }

  void _editBook() {
    // Chuyển đến trang chỉnh sửa sách
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookPage(book: widget.book), // Cần có trang EditBookPage
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title ?? 'Chi tiết sách'),
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
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    baseUrl + widget.book.coverImage!.url,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Tiêu đề sách
            Row(
              children: [
                const Text(
                   'Tên sách: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                    ,
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  widget.book.title ?? 'Không có tiêu đề',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ISBN
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text: 'ISBN: ',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                  TextSpan(
                    text: widget.book.isbn ?? 'Không có ISBN',
                    style: TextStyle(
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
                    text: widget.book.authors!.isNotEmpty
                        ? widget.book.authors!.map((author) => author.authorName).join(', ')
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
                    text: widget.book.language ?? 'Không có Ngôn ngữ',
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
                    text: 'Số trang: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.book.pages.toString() ?? 'Không có so luong trang',
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
                const Icon(Icons.favorite,color: Colors.red,),
                const SizedBox(width: 10,),
                Text(
                  widget.book.likes.toString()
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.visibility_rounded,color: Colors.white,),
                const SizedBox(width: 10,),
                Text(
                    widget.book.view.toString()
                )
              ],
            ),
            const SizedBox(height: 16),
            // Thể loại
            const Text(
              'Thể loại:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Danh sách thể loại
            if (widget.book.categories!.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.book.categories!.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0), // Add some spacing between the chips
                      child: Chip(
                        label: Text(
                          category.nameCategory,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
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
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Mô tả:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả sách (nếu có)
            if (widget.book.description != null && widget.book.description!.isNotEmpty)
              Text(
                widget.book.description!,
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
