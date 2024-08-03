import 'dart:async'; // Thêm thư viện này để sử dụng Timer
import 'package:app_doc_sach/controller/book_controller.dart';
import 'package:app_doc_sach/model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const.dart';

class TopFavoriteBooksScreen extends StatefulWidget {
  const TopFavoriteBooksScreen({super.key});

  @override
  _TopFavoriteBooksScreenState createState() => _TopFavoriteBooksScreenState();
}

class _TopFavoriteBooksScreenState extends State<TopFavoriteBooksScreen> {
  late Future<List<Book>> _futureBooks;
  final BookController _bookService = BookController();
  List<Book> _books = [];
  Timer? _timer; // Thêm biến Timer

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _futureBooks = _bookService.getBooks();

    // Khởi tạo Timer để tự động tải lại dữ liệu sau mỗi 10 giây
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadBooks();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer khi widget bị hủy
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2)); // Hiển thị vòng xoay trong 2 giây
      setState(() {
        _books = books;
        _futureBooks = Future.value(_books); // Cập nhật Future với danh sách sách mới
      });
    } catch (e) {
      print('Error loading books: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot load books. Please try again later.')),
      );
    }
  }

  List<Book> _getTopBooks(List<Book> books) {
    books.sort((a, b) => (b.likes ?? 0).compareTo(a.likes ?? 0));
    return books.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top 10 Sách được yêu thích',
                style: GoogleFonts.aBeeZee(
                  textStyle: Theme.of(context).textTheme.headlineMedium,
                  fontWeight: FontWeight.bold,
                  fontSize: 26
                ),
              ),
              const SizedBox(height: 10,),
              FutureBuilder<List<Book>>(
                future: _futureBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No books available');
                  } else {
                    final topBooks = _getTopBooks(snapshot.data!);
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topBooks.length,
                      itemBuilder: (context, index) {
                        final book = topBooks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          title: Text(book.title ?? 'No title'),
                          subtitle: Text('Likes: ${book.likes ?? 0}'),
                          trailing: book.coverImage != null && book.coverImage!.url.isNotEmpty
                              ? Image.network(
                            baseUrl + book.coverImage!.url,
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.book),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
