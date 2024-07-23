import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:app_doc_sach/controller/banner_controller.dart';
import 'package:app_doc_sach/model/banner_model.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/page/detail_book/detail_book.dart';
import 'package:app_doc_sach/provider/ui_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';
import '../../controller/book_controller.dart';
import '../../model/author_model.dart';
import '../../model/book_model.dart';
import '../../model/popular_book_model.dart';

class KhamPhaWidget extends StatefulWidget {
  const KhamPhaWidget({super.key});

  @override
  State<KhamPhaWidget> createState() => _KhamPhaWidgetState();
}

class _KhamPhaWidgetState extends State<KhamPhaWidget> {
  late Future<List<Banner_Model>> futureBanners;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final BannerController _bannerController = BannerController();
  final BookController _bookService = BookController();
  List<Book> _books = [];
  List<PopularBook> _popularBooks = [];
  bool _isLoading = true;

  Future<void> _fetchPopularBooks() async {
    final url = '$baseUrl/api/book-populars?populate=book.cover_image,book.authors,book.categories,book.chapters.files';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<PopularBook> popularBooks = [];
      var jsonData = jsonDecode(response.body);

      for (var item in jsonData['data']) {
        popularBooks.add(PopularBook.fromJson(item));
      }

      setState(() {
        _popularBooks = popularBooks;
      });
      print(_popularBooks);
    } else {
      throw Exception('Failed to load popular books');
    }
  }
  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      // Trộn danh sách sách
      books.shuffle();
      // Lấy 8 quyển sách đầu tiên sau khi trộn
      final randomBooks = books.take(10).toList();
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

  //Cập nhật view sách

  @override
  void initState() {
    super.initState();
    // Load sách lần đầu tiên khi initState được gọi
    futureBanners = _bannerController.fetchBanners();
    _loadBooks();
   _fetchPopularBooks();
    _loadBooksKinhDi_TrinhTham();
    _loadBooksTieuSu_HoiKy();
    _loadBooksTruyenNgan();
    _loadBooksHaihuoc();
    _loadBooksCoTichDanGian();
    _loadBooksTamlyGiaoduc();
    _loadBooksKhoaHocVienTuong_PhieuLuu();
  }
  // Function to select random 8 books
  List<Book> selectRandomBooks(List<Book> books, int count) {
    final random = Random();
    List<Book> randomBooks = List.from(books);
    randomBooks.shuffle(random);
    return randomBooks.take(count).toList();
  }

  List<Book> _booksKinhDi_TrinhTham = [];
  List<Book> _booksTieuSu_HoiKy = [];
  List<Book> _booksTruyenNgan = [];
  List<Book> _booksHaiHuoc = [];
  List<Book> _booksCoTichDanGian = [];
  List<Book> _booksTamlyGiaoDuc = [];
  List<Book> _booksKhoaHocVienTuong_PhieuLuu = [];
  // Load book Kinh dị - Trinh thám
  Future<void> _loadBooksKinhDi_TrinhTham() async {
    // Example categories
    List<String> categories = ['Kinh dị', 'Trinh thám'];
    loadBooksKhiDi_TrinhTham(categories);
  }
  // Function to load books initially
  Future<void> loadBooksKhiDi_TrinhTham(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      List<Book> randomBooks = selectRandomBooks(books, 10); // Select 8 random books
      setState(() {
        _booksKinhDi_TrinhTham = randomBooks;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
    }
  }

  // Load book Truyen ngan
  Future<void> _loadBooksTruyenNgan() async {
    // Example categories
    List<String> categories = ['Truyện ngắn', 'Tuyển tập'];
    loadBooksTruyenNgan(categories);
  }
  // Function to load books initially
  Future<void> loadBooksTruyenNgan(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      List<Book> randomBooks = selectRandomBooks(books, 10); // Select 8 random books
      setState(() {
        _booksTruyenNgan = randomBooks;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
    }
  }

  // Load book Hài hước
  Future<void> _loadBooksHaihuoc() async {
    // Example categories
    List<String> categories = ['Hài hước', 'Truyện cười'];
    loadBooksHaihuoc(categories);
  }
  // Function to load books initially
  Future<void> loadBooksHaihuoc(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      List<Book> randomBooks = selectRandomBooks(books, 10); // Select 8 random books
      setState(() {
        _booksHaiHuoc = randomBooks;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
    }
  }

  // Load book Co tich dan gia
  Future<void> _loadBooksCoTichDanGian() async {
    // Example categories
    List<String> categories = ['Cổ tích', 'Dân gian'];
    loadBooksCoTichDanGian(categories);
  }
  // Function to load books Co tich dan gia
  Future<void> loadBooksCoTichDanGian(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      List<Book> randomBooks = selectRandomBooks(books, 10); // Select 8 random books
      setState(() {
        _booksCoTichDanGian = randomBooks;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
      // Handle error as needed
    }
  }

  // Load book Tâm lý Giáo dục
  Future<void> _loadBooksTamlyGiaoduc() async {
    // Example categories
    List<String> categories = ['Tâm lý', 'Giáo dục'];
    loadBooksTamlyGiaoduc(categories);
  }
  // Function to load books Co tich dan gia
  Future<void> loadBooksTamlyGiaoduc(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      List<Book> randomBooks = selectRandomBooks(books, 10); // Select 8 random books
      setState(() {
        _booksTamlyGiaoDuc = randomBooks;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
      // Handle error as needed
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Load book Khoa học viễn tưởng - Phiêu lưu
  Future<void> _loadBooksKhoaHocVienTuong_PhieuLuu() async {
    // Example categories
    List<String> categories = ['Viễn tưởng', 'Phiêu lưu'];
    loadBooksKhoaHocVienTuong_PhieuLuu(categories);
  }
  // Function to load
  Future<void> loadBooksKhoaHocVienTuong_PhieuLuu(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      List<Book> randomBooks = selectRandomBooks(books, 10); // Select 8 random books
      setState(() {
        _booksKhoaHocVienTuong_PhieuLuu = randomBooks;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
      // Handle error as needed
    }
  }
  // Load book Tieu su - Hồi ký
  Future<void> _loadBooksTieuSu_HoiKy() async {
    // Example categories
    List<String> categories = ['Kinh dị', 'Trinh thám'];
    loadBooksKhiDi_TrinhTham(categories);
  }
  // Function to load books initially
  Future<void> loadBooksTieuSu_HoiKy(List<String> categories) async {
    try {
      List<Book> books = await getBooksByCategories(categories);
      setState(() {
        _booksTieuSu_HoiKy = books;
        // Ensure _bookColors list has the same length as books list
        _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
      });
    } catch (e) {
      print('Error loading books: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Lấn lên cả phần status bar
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Làm trong suốt status bar
          statusBarIconBrightness: Brightness.dark, // Màu sắc icon trên status bar
        ),
        child: Consumer<UiProvider>(
          builder: (BuildContext context, UiProvider value, Widget? child) {
            return Container(
              color: value.isDark
                  ? Colors.black12
                  : const Color.fromRGBO(232, 245, 233, 1.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                FutureBuilder<List<Banner_Model>>(
                future: futureBanners,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load banners'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('No banners available'));
                    } else {
                      final banners = snapshot.data!;
                      final imgList = banners.map((banner) => banner.imageBanner?.url ?? '').toList();

                      // In dữ liệu imgList ra console để kiểm tra
                      print('Image list: $imgList');

                      if (imgList.isEmpty) {
                        return const Center(child: Text('No banners available'));
                      }

                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 250,
                            child: CarouselSlider(
                              items: imgList
                                  .where((item) => item.isNotEmpty) // Lọc các URL trống
                                  .map((item) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
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
                                  child: CachedNetworkImage(
                                    imageUrl: baseUrl + item,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 500,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Center(child: Text('Error loading image')),
                                  ),
                                ),
                              ))
                                  .toList(),
                              options: CarouselOptions(
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                enlargeCenterPage: true,
                                aspectRatio: 2.0,
                                viewportFraction: 0.85,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                              ),
                              carouselController: _controller,
                            ),
                          ),
                          buildCarouseIndicator(imgList),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(
                      height:10,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    slide(_popularBooks),
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
                            fontSize: 16,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    gridview_category(_booksKinhDi_TrinhTham),
                    /*const SizedBox(
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
                    gridview_category(_booksTieuSu_HoiKy),*/
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    gridview_category(_booksTruyenNgan),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    gridview_category(_booksHaiHuoc),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : gridview_category(_booksCoTichDanGian),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                     gridview_category(_booksTamlyGiaoDuc),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    gridview_category(_booksKhoaHocVienTuong_PhieuLuu),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  buildCarouseIndicator(List<String> imgList) {
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


String getAuthorNames(List<Author> authors) {
  return authors.map((author) => author.authorName).join(', ');
}
String getCategoryNames(List<CategoryModel> categories) {
  return categories.map((category) => category.nameCategory).join(', ');
}

String getFirstCategoryName(List<CategoryModel> categories) {
  if (categories.isNotEmpty) {
    return categories.first.nameCategory;
  }
  return '';
}
Widget slide(List<PopularBook> books) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
    child: Container(
      height: 250,
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
                      incrementView(book.book!);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ProductDetailPage(book: book.book!),
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
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      height: 300,
                      width: 280,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 5, top: 8, right: 5, bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                baseUrl + book.book!.coverImage!.url,
                                height: 180,
                                width: 130,
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
                                      bottom: 10, left: 20, top: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.book!.title!,
                                        style: TextStyle(
                                          color: notifier.isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Tác giả: ${getAuthorNames(book.book?.authors ?? [])}',
                                        style: TextStyle(
                                          color: notifier.isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                          Text(
                                            'Thể loại: ${getCategoryNames(book.book?.categories ?? [])}',
                                            style: TextStyle(
                                              color: notifier.isDark ? Colors.white : Colors.black,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                  // Thêm phần likes và icon favorite
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            book.book!.likes.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          const Icon(Icons.favorite, color: Colors.redAccent),
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

// Tạo danh sách để lưu màu sắc đã được random cho mỗi cuốn sách
List<Color> _bookColors = [];
String getFirstAuthorName(List<Author> authors) {
  if (authors.isNotEmpty) {
    return authors.first.authorName;
  }
  return '';
}
Widget gridview_goiy(List<Book> books) {
  final bookController = BookController();

  // Đảm bảo rằng danh sách _bookColors có cùng số lượng phần tử với danh sách books
  if (_bookColors.length != books.length) {
    _bookColors = List<Color>.generate(books.length, (index) => getRandomColor());
  }
  return SizedBox(
    height: 485, // Set a fixed height
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.75,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 6,
        ),
        itemCount: books.length,
        itemBuilder: (BuildContext context, index) {
          final book = books[index];
          final bookColor = _bookColors[index];
          return GestureDetector(
            onTap: () async {
              try {
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
              } catch (e) {
                print('Error updating view count: $e');
                // Bạn có thể hiển thị một thông báo lỗi ở đây nếu muốn
              }
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
                              height: 180,
                              width: 130,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: bookColor.withOpacity(0.7), // Sử dụng màu với độ trong suốt để tăng độ rõ nét
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5), // Màu bóng đổ
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1), // Thay đổi vị trí bóng đổ
                                  ),
                                ],
                              ),
                              child: Text(
                                getFirstCategoryName(book.categories ?? []),
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
            ]),
          );
        },
      ),
    ),
  );
}

// Function to get books by categories
Future<List<Book>> getBooksByCategories(List<String> categoryNames) async {
  try {
    // Build a query string for category names
    String categoryFilter = categoryNames.map((name) => 'filters[categories][name][\$eq]=$name').join('&');

    final response = await http.get(Uri.parse('$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*&$categoryFilter'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('Raw JSON response: $jsonResponse');
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((json) {
        try {
          return Book.fromJson({
            'id': json['id'],
            ...json['attributes'] ?? {},
          });
        } catch (e, stackTrace) {
          print('Error parsing book: $e');
          print('Stack trace: $stackTrace');
          print('Problematic JSON: $json');
          return null;
        }
      }).whereType<Book>().toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error loading books: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}
Widget gridview_category(List<Book> books) {
  return SizedBox(
    height: 485, // Set a fixed height
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.75,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 6,
        ),
        itemCount: books.length,
        itemBuilder: (BuildContext context, index) {
          final book = books[index];
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
                              height: 180,
                              width: 130 ,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: bookColor.withOpacity(0.7), // Sử dụng màu với độ trong suốt để tăng độ rõ nét
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5), // Màu bóng đổ
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1), // Thay đổi vị trí bóng đổ
                                  ),
                                ],
                              ),
                              child: Text(
                                getFirstCategoryName(book.categories ?? []),
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
            ]),
          );
        },
      ),
    ),
  );
}
