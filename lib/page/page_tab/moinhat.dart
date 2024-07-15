import 'dart:math';
import 'dart:convert';
import 'package:app_doc_sach/model/product_phobien.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../controller/book_controller.dart';
import '../../model/author_model.dart';
import '../../model/book_model.dart';
import '../../model/category_model.dart';
import '../../provider/ui_provider.dart';
import '../detail_book/detail_book.dart';
import 'package:http/http.dart' as http;
class MoiNhatWidget extends StatefulWidget {
  const MoiNhatWidget({super.key});

  @override
  State<MoiNhatWidget> createState() => _MoiNhatWidgetState();
}

class _MoiNhatWidgetState extends State<MoiNhatWidget> {
  final BookController _bookService = BookController();
  List<Book> _booksMoiNhat = [];

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooksByStatus('Mới nhất');

      // Sắp xếp sách theo thời gian tạo (mới nhất đến cũ nhất)
      books.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) {
          return 0; // Cả hai đều null thì coi như bằng nhau
        } else if (a.createdAt == null) {
          return 1; // `a` null thì `a` lớn hơn `b`
        } else if (b.createdAt == null) {
          return -1; // `b` null thì `b` lớn hơn `a`
        } else {
          return b.createdAt!.compareTo(a.createdAt!); // So sánh bình thường nếu cả hai không null
        }
      });

      setState(() {
        _booksMoiNhat = books;
      });
    } catch (e) {
      print('Error loading books: $e');
      if (!mounted) return; // Kiểm tra nếu widget vẫn còn trong cây widget
      // Hiển thị thông báo lỗi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải sách. Vui lòng thử lại sau.')),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    // Load sách lần đầu tiên khi initState được gọi
    _loadBooks();
  }

  List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.amberAccent,
    Colors.purple,
  ];

  Color getRandomColor() {
    final random = Random();
    return _colors[random.nextInt(_colors.length)];
  }
  List<Color> _bookColors = [];
  String getFirstCategoryName(List<CategoryModel> categories) {
    if (categories.isNotEmpty) {
      return categories.first.nameCategory;
    }
    return '';
  }

  String getFirstAuthorName(List<Author> authors) {
    if (authors.isNotEmpty) {
      return authors.first.authorName;
    }
    return '';
  }

  //Cập nhật view sách

  Future<Book> fetchBookById(String id) async {
    final url = Uri.parse('$baseUrl/api/books/$id?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final bookJson = jsonBody['data']; // Trích xuất phần dữ liệu của sách từ JSON

        final book = Book.fromJson({
          'id': bookJson['id'],
          ...bookJson['attributes'] ?? {},
        });
        return book;
      } else {
        throw Exception('Failed to load book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load book: $e');
    }
  }
  Future<void> incrementView(Book book) async {
    try {
      final updatedBook = await fetchBookById(book.id!);
      final updatedView = (updatedBook.view ?? 0) + 1;

      final url = Uri.parse('$baseUrl/api/books/${book.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': {
            'view': updatedView,
          }
        }),
      );

      if (response.statusCode == 200) {
        // Optional: Update local state or notify listeners
        print('View count updated successfully');
      } else {
        throw Exception('Failed to update view count');
      }
    } catch (e) {
      print('Error incrementing view count: $e');
      throw Exception('Failed to update view count');
    }
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
              child: gridview_moinhat()),
        );
      },
    );
  }

  Widget gridview_moinhat() {
    // Đảm bảo rằng danh sách _bookColors có cùng số lượng phần tử với danh sách books
    if (_bookColors.length != _booksMoiNhat.length) {
      _bookColors = List<Color>.generate(_booksMoiNhat.length, (index) => getRandomColor());
    }
    return GridView.builder(
      padding: const EdgeInsets.only(left:  8,right: 8,bottom: 8,top: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 3,
      ),
      itemCount: _booksMoiNhat.length,
      itemBuilder: (context, index) {
        final book = _booksMoiNhat[index];
        final bookColor = _bookColors[index];
        return GestureDetector(
          onTap: () {
            incrementView(book);
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ProductDetailPage(book: book),
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
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      baseUrl +
                          (book.coverImage?.url ?? ''),
                      fit: BoxFit.cover,
                      height: 180,
                      width: 130,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.book),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: bookColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        getFirstCategoryName(
                            book.categories ?? []),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    book.title ?? 'UnKnow',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getFirstAuthorName(book.authors ?? []),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
