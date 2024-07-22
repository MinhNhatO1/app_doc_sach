import 'dart:async';
import 'dart:convert';
import 'package:app_doc_sach/const.dart';
import 'package:flutter/material.dart';
import '../../controller/book_controller.dart';
import '../../model/book_model.dart';
import 'package:http/http.dart' as http;

import '../detail_book/detail_book.dart';

class TimKiemSach extends StatefulWidget {
  const TimKiemSach({super.key, required this.textSearch,required this.onPopularSearchSelected,required this.popularSearches});
  final String? textSearch;
  final List<String> popularSearches;
  final Function(String) onPopularSearchSelected;
  @override
  State<TimKiemSach> createState() => _TimKiemSachState();
}

class _TimKiemSachState extends State<TimKiemSach> {
  List<Book> listProduct = [];
  final BookController _bookService = BookController();
  bool isLoading = false;
  List<String> popularSearches = [
    "Ngày hoa lưu ngược gió",
    "Đắc Nhân Tâm",
    "Muôn kiếp nhân sinh",
    "Ghi chép pháp y",
    "Tâm lý",
    "Thôi miên bằng ngôn từ",
    "hóa",
    "Đắc Nhân Tâm",
    "Nguyên tắc",
    "toán",
    "thao túng tâm lý",
    "Tâm lý học tội phạm",
  ];

  Future<List<Book>> _getBooks(String textSearch) async {
    await Future.delayed(const Duration(seconds: 1)); // Đợi 1 giây
    try {
      return await _bookService.getBooksBySearch(textSearch);
    } catch (e) {
      print('Error loading books: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.textSearch != null && widget.textSearch!.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      // Kích hoạt tìm kiếm
      _getBooks(widget.textSearch!);
    }
  }

  Timer? _debounce;

  void onSearchTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (text.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        // Kích hoạt tìm kiếm
        _getBooks(text);
      } else {
        if (mounted) {
          setState(() {
            listProduct.clear();
          });
        }
      }
    });
  }
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
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.textSearch != null && widget.textSearch!.isNotEmpty)
                FutureBuilder<List<Book>>(
                  future: _getBooks(widget.textSearch!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height - 250,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildNoResultsFound();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildNoResultsFound();
                    }
                    return _buildProductList(snapshot.data!);
                  },
                )
              else
                searchDefault(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchList(List<String> items) {
    return Container(
      width: double.infinity,
      height: 200,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 2.0,
          children: items.map((item) {
            return GestureDetector(
              onTap: () {
                widget.onPopularSearchSelected(item);
              },
              child: Chip(
                label: Text(
                  item,
                  style: const TextStyle(fontSize: 13),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget searchDefault() {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              _buildSectionTitle('Tìm kiếm nổi bật'),
              Align(
                  alignment: Alignment.centerLeft,
                  child: _buildSearchList(widget.popularSearches)),
              const SizedBox(
                height: 200,
              )
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildProductList(List<Book> products) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            incrementView(product);
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ProductDetailPage(book: product),
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
                transitionDuration: const Duration(milliseconds: 300), // Thời gian chuyển đổi
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left:10,right: 10,top: 10),
            child: Container(
              width: double.infinity,
              height: 220, // Adjust height if needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          baseUrl + product.coverImage!.url ?? '',
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 180,
                              color: Colors.grey,
                              child: const Icon(Icons.error),
                            );
                          },
                        ),),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title!,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                             Text(
                               product.authors?.map((author) => author.authorName).join(', ') ?? 'Không có tác giả',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: product.categories?.map((category) => Padding(
                                  padding: const EdgeInsets.only(right: 4), // Khoảng cách giữa các chip
                                  child: Chip(
                                    label: Text(
                                      category.nameCategory,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: const BorderSide(color: Colors.green, width: 2),
                                    ),
                                  ),
                                )).toList() ?? [const Chip(label: Text('Không có danh mục'))],
                              ),
                            ),
                            const Spacer(), // Added a Spacer to push the price and favorite icon to the bottom
                             Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .end, // Align the row to the right
                              children: [
                                Text(
                                  product.likes.toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget searchResults(String text) {
    return isLoading
        ? Container(
        height: MediaQuery.of(context).size.height - 250, // Adjust the height as needed
        width: double.infinity,
        child: const Center(child: CircularProgressIndicator()))
        : Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
      child: listProduct.isEmpty
          ? _buildNoResultsFound()
          : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: _buildProductList(listProduct),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Container(
      height: MediaQuery.of(context).size.height - 250, // Adjust the height as needed
      width: double.infinity,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Không tìm thấy sách nào.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

}
