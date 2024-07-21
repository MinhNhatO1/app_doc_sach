import 'dart:convert';
import 'dart:math';

import 'package:app_doc_sach/model/category_model.dart';
import 'package:flutter/material.dart';

import '../../const.dart';
import '../../controller/book_controller.dart';
import '../../model/author_model.dart';
import '../../model/book_model.dart';
import 'package:http/http.dart' as http;

import '../detail_book/detail_book.dart';
class ListBookAuthor extends StatefulWidget {
  final Author author;
  const ListBookAuthor({super.key,required this.author});

  @override
  State<ListBookAuthor> createState() => _ListBookCategoryState();
}

class _ListBookCategoryState extends State<ListBookAuthor> {
  final BookController _bookService = BookController();
  List<Book> _booksbyAuthor = [];
  bool _isLoading = true; // Loading state
  bool _showNotFound = false; // Flag to show "No books found" message
  @override
  void initState() {
    super.initState();
    _loadBooksByCategory();
  }

  Future<void> _loadBooksByCategory() async {
    setState(() {
      _isLoading = true; // Set loading state true
      _showNotFound = false; // Reset "No books found" message
    });

    try {
      List<Book> books = await _bookService.getBooksByAuthor(widget.author.authorName);

      // Simulate delay of 3 seconds before displaying results
      await Future.delayed(Duration(seconds: 2));
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
        _booksbyAuthor = books;
        _isLoading = false; // Set loading state false
        if (_booksbyAuthor.isEmpty) {
          _showNotFound = true; // Show "No books found" message if no books found
        }
      });
    } catch (e) {
      print('Failed to load books: $e');
      setState(() {
        _isLoading = false; // Set loading state false on error
        _showNotFound = true; // Show "No books found" message on error
      });
    }
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Đặt chiều cao của AppBar
        child: Padding(
          padding: EdgeInsets.only(top: 12),
          child: AppBar(
            titleSpacing: 5, // Đặt khoảng cách giữa title và leading về 10
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Tác giả: ${widget.author.authorName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              maxLines: 2, // Số dòng tối đa
              overflow: TextOverflow.ellipsis, // Xử lý khi văn bản quá dài
            ),
            // Các thuộc tính khác của AppBar
          ),
        ),
      ),
      body: gridview_bookcategory(),
    );
  }

  Widget gridview_bookcategory() {
    // Đảm bảo rằng danh sách _bookColors có cùng số lượng phần tử với danh sách books
    if (_bookColors.length != _booksbyAuthor.length) {
      _bookColors = List<Color>.generate(_booksbyAuthor.length, (index) => getRandomColor());
    }
    if (_isLoading) {
      return Transform.translate(
        offset: const Offset(0, -50),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_showNotFound) {
      return Transform.translate(
        offset: const Offset(0, -50),
        child: const Center(
          child: Text(
            'Không tìm thấy sách',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.only(left:  8,right: 8,bottom: 8,top: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 3,
        ),
        itemCount: _booksbyAuthor.length,
        itemBuilder: (context, index) {
          final book = _booksbyAuthor[index];
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
                          child: Container(
                            child: Text(
                              getFirstCategoryName(book.categories!),
                              maxLines: 1, // Giới hạn hiển thị trong 1 dòng
                              overflow: TextOverflow.ellipsis, // Hiển thị dấu ba chấm khi văn bản bị cắt bỏ
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
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
}
