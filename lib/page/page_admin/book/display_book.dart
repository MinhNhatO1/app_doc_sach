import 'dart:async';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/controller/book_controller.dart';
import 'package:app_doc_sach/data/book_details.dart';
import 'package:app_doc_sach/page/page_admin/book/book_detail.dart';
import 'package:app_doc_sach/page/page_admin/book/create_book.dart';
import 'package:app_doc_sach/page/page_admin/book/slideleftroutes.dart';
import 'package:flutter/material.dart';
import '../../../const/constant.dart';
import '../../../model/book_model.dart';
import '../../../widgets/side_widget_menu.dart';

class DisplayBook extends StatefulWidget {
  const DisplayBook({super.key});

  @override
  State<DisplayBook> createState() => _DisplayBookState();
}

class _DisplayBookState extends State<DisplayBook> {

  final BookController _bookService = BookController();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  Future<List<Book>>? _booksFuture;
  late Timer? _timer; // Biến timer

  final BookDetails bookDetails = BookDetails();

  @override
  void initState() {
    super.initState();
    // Load sách lần đầu tiên khi initState được gọi
    _loadBooks();

    // Cài đặt timer để tự động load lại sách sau mỗi 3 giây
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadBooks();
    });
    _searchController.addListener(_onSearchChanged);
  }

 @override
  void dispose() {
    // Hủy timer khi widget bị huỷ
    _timer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      if (!mounted) return; // Kiểm tra nếu widget vẫn còn trong cây widget

      setState(() {
        // Sắp xếp sách từ dưới lên (theo thứ tự ngược lại)
        _books = books.reversed.toList();
      });
    } catch (e) {
      print('Error loading books: $e');
      if (!mounted) return; // Kiểm tra nếu widget vẫn còn trong cây widget

      // Hiển thị thông báo lỗi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải sách. Vui lòng thử lại sau.')),
      );
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Book> get filteredBooks {
    return _searchController.text.isEmpty
        ? _books
        : _books
        .where((book) => book.title!
        .toLowerCase()
        .contains(_searchController.text.toLowerCase()))
        .toList();
  }
  Widget _buildListCategory(List<String> categories) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(8.0), // Để tăng khoảng cách giữa các phần tử và viền container
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0, // Khoảng cách giữa các Chip
          runSpacing: 8.0, // Khoảng cách giữa các hàng
          children: categories.map((category) {
            return Chip(
              label: Text(
                category,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.green),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sách') ,
        elevation: 0.0, // Controls the shadow below the app bar
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(SlideLeftRoute(page: const BookCreate()));
              },
              child: const Text('Tạo mới'),
            ),
          )
        ],
      ),

      drawer: const SideWidgetMenu(),
      body: Padding(
        padding: const EdgeInsets.only( right: 13, left: 13, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sách',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: filteredBooks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Không tìm thấy kết quả',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thử tìm kiếm với từ khóa khác',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  :  ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => BookDetailAdmin(book: book),
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
                      width: double.infinity,
                      height: 280,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: book.coverImage != ''
                                    ? Image.network(
                                  baseUrl + book.coverImage!.url,
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                                    : const Icon(Icons.book, size: 80, color: Colors.grey),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title ?? 'Không có tiêu đề',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'ISBN:  ',
                                            ),
                                            TextSpan(
                                              text: book.isbn,
                                              style: TextStyle(
                                                color: Colors.grey.shade300,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(children: [
                                        RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Tác giả:  ',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              book.authors!.isNotEmpty
                                                  ? book.authors!.map((author) => author.authorName).join(', ')
                                                  : 'Không có tác giả',
                                              style: TextStyle(
                                                color: Colors.grey.shade300,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis, // Nếu bạn muốn hiển thị dấu ba chấm khi nội dung quá dài
                                              softWrap: false, // Ngăn việc ngắt dòng
                                            )
                                          
                                          ),
                                        )

                                      ],),
                                      const SizedBox(height: 15),
                                      const Text(
                                        'Thể loại:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      book.categories!.isNotEmpty
                                          ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: book.categories!.map((category) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 10.0),
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
                                          : const Text(
                                        'Không có thể loại',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const Spacer(),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.visibility_rounded, color: Colors.white),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${book.view}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 30),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '${book.likes}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
