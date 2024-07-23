import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../const.dart';
import '../../../model/book_model.dart';

class BookPopularCreate extends StatefulWidget {
  const BookPopularCreate({super.key});

  @override
  State<BookPopularCreate> createState() => _BookPopularCreateState();
}

class _BookPopularCreateState extends State<BookPopularCreate> {
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _fetchBooks() async {
    final url = '$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<Book> books = [];
        var jsonData = jsonDecode(response.body);
        for (var item in jsonData['data']) {
          books.add(Book.fromJson({
            'id': item['id'],
            ...item['attributes'] ?? {},
          }));
        }
        setState(() {
          _books = books;
          _filteredBooks = books;
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) =>
      book.title!.toLowerCase().contains(query) ||
          book.isbn!.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _addToPopularBooks(Book book) async {
    // Kiểm tra xem sách đã tồn tại trong danh sách phổ biến chưa
    bool isAlreadyPopular = await _isBookAlreadyPopular(book.id!);
    if (isAlreadyPopular) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sách đã có trong danh sách phổ biến, không thể thêm')),
      );
      return;
    }

    final url = '$baseUrl/api/book-populars';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {
            'book': book.id,
          }
        }),
      );
      if (response.statusCode == 200) {

        Get.snackbar(
          'Thành công',
          'Sách đã được thêm vào danh sách phổ biến',
          colorText: Colors.white,
          backgroundColor: Colors.green.withOpacity(0.7), // Màu xanh
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 3),
          borderRadius: 10,
          animationDuration: Duration(milliseconds: 500),
        );
        Navigator.of(context).pop(true); // Trả về true để báo hiệu cần refresh
      } else {
        throw Exception('Không thể thêm sách vào danh sách phổ biến');
      }
    } catch (e) {
      print('Error adding book to popular list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi thêm sách')),
      );
    }
  }


  Future<bool> _isBookAlreadyPopular(String bookId) async {
    final url = '$baseUrl/api/book-populars?filters[book][id]=$bookId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData['data'].length > 0;
      } else {
        throw Exception('Không thể kiểm tra trạng thái sách phổ biến');
      }
    } catch (e) {
      print('Error checking if book is already popular: $e');
      return false;
    }
  }
  Future<void> _showConfirmationDialog(Book book) async {
    bool isAlreadyPopular = await _isBookAlreadyPopular(book.id!);
    if (isAlreadyPopular) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sách đã có trong danh sách phổ biến, không thể thêm')),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận thêm sách',style: TextStyle(fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc muốn thêm sách "${book.title}" vào danh sách sách phổ biến?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Đồng ý'),
              onPressed: () {
                Navigator.of(context).pop();
                _addToPopularBooks(book);
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm sách vào danh sách phổ biến'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm sách',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                return GestureDetector(
                  onTap: () => _showConfirmationDialog(book),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 13.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: book.coverImage != null
                                ? Image.network(
                              baseUrl + book.coverImage!.url,
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 120,
                              height: 180,
                              child: Icon(
                                Icons.book,
                                size: 60,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: SizedBox(
                              height: 180,  // Match the image height
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    maxLines: 2,
                                    book.title ?? 'Không có tiêu đề',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    maxLines: 2,
                                    book.authors?.map((a) => a.authorName).join(', ') ?? 'Không có tác giả',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:  Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          ),
        ],
      ),
    );
  }
}
