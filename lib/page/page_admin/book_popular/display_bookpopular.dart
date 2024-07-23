import 'dart:async';
import 'dart:convert';

import 'package:app_doc_sach/model/popular_book_model.dart';
import 'package:app_doc_sach/page/page_admin/book_popular/create_bookpopular.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../const.dart';
import '../../../const/constant.dart';
import '../../../controller/book_controller.dart';
import '../../../model/book_model.dart';
import '../../../widgets/side_widget_menu.dart';
import '../book/book_detail.dart';
import '../book/slideleftroutes.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
class DisplayBookpopular extends StatefulWidget {
  const DisplayBookpopular({super.key});

  @override
  State<DisplayBookpopular> createState() => _DisplayBookpopularState();
}


class _DisplayBookpopularState extends State<DisplayBookpopular> {

  final BookController _bookService = BookController();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  Future<List<Book>>? _booksFuture;
  List<PopularBook> _popularBooks = [];
  late Timer? _timer; // Biến timer

  ScaffoldMessengerState? scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu trữ tham chiếu đến ScaffoldMessenger
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    // Load sách lần đầu tiên khi initState được gọi
    _fetchPopularBooks();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchPopularBooks();
    });
    _searchController.addListener(_onSearchChanged);
  }
  void showAlertSuccess(QuickAlertType quickalert){
    QuickAlert.show(context: context, type: quickalert).then((_) {
      // Đóng trang khi người dùng bấm nút "OK"
      Navigator.pop(context, true); // Truyền lại true để xác nhận cập nhật thành công
    });
  }

  Future<void> _fetchPopularBooks() async {
    final url = '$baseUrl/api/book-populars?populate=book.cover_image,book.authors,book.categories,book.chapters.files';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<PopularBook> popularBooks = [];
        var jsonData = jsonDecode(response.body);

        for (var item in jsonData['data']) {
          popularBooks.add(PopularBook.fromJson(item));
        }

        if (mounted) {
          setState(() {
            _popularBooks = popularBooks.reversed.toList();;
          });
        }
        print(_popularBooks);
      } else {
        throw Exception('Failed to load popular books');
      }
    } catch (e) {
      print('Error fetching popular books: $e');
    }
  }
  @override
  void dispose() {
    // Hủy timer khi widget bị huỷ
    _timer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    scaffoldMessenger = null;
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }
  Future<void> _deletePopularBook(int id) async {
    final url = '$baseUrl/api/book-populars/$id';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _popularBooks.removeWhere((book) => book.id == id);
        });
        Get.snackbar(
          'Thành công',
          'Sách đã được xóa khỏi danh sách phổ biến',
          colorText: Colors.white,
          backgroundColor: Colors.green.withOpacity(0.7), // Màu xanh
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 3),
          borderRadius: 10,
          animationDuration: Duration(milliseconds: 500),
        );

      } else {
        throw Exception('Không thể xóa sách');
      }
    } catch (e) {
      print('Error deleting popular book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi xóa sách')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(PopularBook popularBook) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc muốn xóa sách "${popularBook.book!.title}" khỏi danh sách sách phổ biến?',style: TextStyle(fontSize: 15),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy',style: TextStyle(fontSize: 16),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Đồng ý',style: TextStyle(fontSize: 16),),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePopularBook(popularBook.id!);
              },
            ),
          ],
        );
      },
    );
  }
  List<PopularBook> get filteredPopularBooks {
    return _searchController.text.isEmpty
        ? _popularBooks
        : _popularBooks
        .where((popularBook) => popularBook.book!.title!
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
        title: const Text('Quản lý sách phổ biến') ,
        elevation: 0.0, // Controls the shadow below the app bar
        backgroundColor: backgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: secondaryColor,
                backgroundColor:
                primaryColor, // Using the custom secondaryColor
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(SlideLeftRoute(page: const BookPopularCreate()));
                if (result == true) {
                  // Nếu có sách mới được thêm, refresh danh sách
                  _fetchPopularBooks();
                }
              },
              child: const Text('Thêm'),
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
              child: filteredPopularBooks.isEmpty
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
                itemCount: filteredPopularBooks.length,
                itemBuilder: (context, index) {
                  final popularBook = filteredPopularBooks[index];
                  final book = popularBook.book!;
                  return GestureDetector(
                    onLongPress: () {
                      _showDeleteConfirmationDialog(popularBook);
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
