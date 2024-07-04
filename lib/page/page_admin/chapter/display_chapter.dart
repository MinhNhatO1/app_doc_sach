import 'dart:async';

import 'package:app_doc_sach/page/page_admin/chapter/chapter_detail.dart';
import 'package:app_doc_sach/page/page_admin/chapter/create_chapter.dart';
import 'package:flutter/material.dart';

import '../../../const.dart';
import '../../../const/constant.dart';
import '../../../controller/book_controller.dart';
import '../../../model/book_model.dart';
import '../../../widgets/side_widget_menu.dart';

class DisplayChapter extends StatefulWidget {
  const DisplayChapter({super.key});

  @override
  State<DisplayChapter> createState() => _DisplayChapterState();
}

class _DisplayChapterState extends State<DisplayChapter> {
  final BookController _bookService = BookController();
  List<Book> _books = [];
  Timer? _timer;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Book>> _booksFuture;
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
  @override
  void initState() {
    super.initState();
    _booksFuture = _loadBooks();
    // Thiết lập timer để tải lại sách mỗi 5 giây
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      _loadBooks();
    });
    _searchController.addListener(_onSearchChanged);

  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  Future<List<Book>> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      if (!mounted) return []; // Check if the widget is still in the widget tree
      setState(() {
        _books = books;
      });
      return books;
    } catch (e) {
      print('Error loading books: $e');
      if (!mounted) return []; // Check if the widget is still in the widget tree
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải sách. Vui lòng thử lại sau.')),
      );
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chương sách',style: TextStyle(fontSize: 20),),
        elevation: 0.0, // Controls the shadow below the app bar
        backgroundColor: backgroundColor,
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
              child:
              filteredBooks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(), // Thêm biểu tượng xoay tròn
                    SizedBox(height: 16),
                    Text(
                      'Đang tải...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetail(book: book),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 255,
                      margin: const EdgeInsets.symmetric(vertical: 3),
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
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title ?? 'Không có tiêu đề',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 14,
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
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Tác giả:  ',
                                            ),
                                            TextSpan(
                                              text: book.authors!.isNotEmpty
                                                  ? book.authors!.map((author) => author.authorName).join(', ')
                                                  : 'Không có tác giả',
                                              style: TextStyle(
                                                color: Colors.grey.shade300,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Text(
                                        'Danh sách chương:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      book.chapters!.isNotEmpty
                                          ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: book.chapters!.map((category) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 10.0),
                                              child: Chip(
                                                label: Text(
                                                  category.nameChapter,
                                                  style: const TextStyle(fontSize: 10, color: Colors.white),
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
