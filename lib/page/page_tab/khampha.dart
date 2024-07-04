import 'dart:ui';

import 'package:app_doc_sach/page/detail_book/detail_book.dart';
import 'package:app_doc_sach/provider/ui_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../controller/book_controller.dart';
import '../../model/book_model.dart';
import '../../model/product_phobien.dart';

class KhamPhaWidget extends StatefulWidget {
  const KhamPhaWidget({super.key});

  @override
  State<KhamPhaWidget> createState() => _KhamPhaWidgetState();
}

class _KhamPhaWidgetState extends State<KhamPhaWidget> {
  final List<String> imgList = [
    'https://bizweb.dktcdn.net/thumb/grande/100/468/779/themes/883715/assets/slider_3.jpg?1674889023980',
    'https://bizweb.dktcdn.net/thumb/large/100/222/758/articles/fb-tap-noi-tap-doc-1-01-01.jpg?v=1610358102210',
    'https://bizweb.dktcdn.net/100/222/758/themes/549028/assets/slider-img3.jpg?1708567836625'
  ];
  int _current = 0;
  final CarouselController _controller = CarouselController();

  final BookController _bookService = BookController();
  List<Book> _books = [];
  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      // Trộn danh sách sách
      books.shuffle();
      // Lấy 8 quyển sách đầu tiên sau khi trộn
      final randomBooks = books.take(8).toList();
      setState(() {

        _books = randomBooks;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UiProvider>(
        builder: (BuildContext context, UiProvider value, Widget? child) {
          return Container(
            color: value.isDark
                ? Colors.black12
                : const Color.fromRGBO(232, 245, 233, 1.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CarouselSlider(
                        items: imgList
                            .map((item) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      item,
                                      fit: BoxFit.cover,
                                      width: 1000,
                                    ),
                                  ),
                                ))
                            .toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          enlargeCenterPage: true,
                          aspectRatio: 2.0,
                          height: 180,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        ),
                        carouselController: _controller,
                      ),
                      buildCarouseIndicator(),
                      const SizedBox(
                        height: 5,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sách phổ biến',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      slide(_books),
                      const SizedBox(
                        height: 1,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gợi ý cho bạn',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Kinh dị - Trinh thám',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tiểu sử - Hồi ký - Danh nhân',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Truyện ngắn - Tuyển tập',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Truyện cười - Hài hước',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Cổ tích - Dân gian',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tâm lý - Giáo dục',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Khoa học viễn tưởng - Phiêu lưu',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      gridview_goiy(_books),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  buildCarouseIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: imgList.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _controller.animateToPage(entry.key),
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(_current == entry.key ? 0.9 : 0.4)),
          ),
        );
      }).toList(),
    );
  }
}


Widget slide(List<Book> books) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
    child: Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          autoPlay: true,
        ),
        items: books.map((book) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: [
                  // Lớp mờ trong suốt
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black
                                .withOpacity(0.3), // Giảm độ đậm của màu đen
                            offset: Offset(0, 4), // Tăng khoảng cách bóng đổ
                            blurRadius: 20), // Tăng độ mờ của bóng đổ
                      ], // Giảm độ đậm của màu trắng
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Nội dung
                  GestureDetector(
                    onTap: () {
                     /* Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: product),
                        ),
                      );*/
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      height: 200,
                      width: 280,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 5, top: 8, right: 5, bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                baseUrl + book.coverImage!.url,
                                height: 160,
                                width: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Consumer<UiProvider>(
                              builder: (context, UiProvider notifier, child) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 3, left: 20, right: 20, top: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title!,
                                        style: TextStyle(
                                          color: notifier.isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Thể loại: ${book.categories}',
                                        style: TextStyle(
                                          color: notifier.isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Row(
                                        children: [
                                          Icon(Icons.favorite),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            '10',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    ),
  );
}

Widget gridview_goiy(List<Book> books) {
  return SizedBox(
    height: 465, // Set a fixed height
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.95,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 5.0,
        ),
        itemCount: books.length,
        itemBuilder: (BuildContext context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailPage(product: product),
                ),
              );*/
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              baseUrl + book.coverImage!.url,
                              fit: BoxFit.cover,
                              height: 160,
                              width: 120,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                               /* book.categories*/'',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    book.title!,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tac Gia',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    ),
  );
}
