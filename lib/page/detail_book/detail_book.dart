import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // Import for ImageFilter
import 'package:app_doc_sach/controller/favorite_controller.dart';
import 'package:app_doc_sach/model/book_model.dart';
import 'package:app_doc_sach/page/page_tab_taikhoanwidget/gia_han_goi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_doc_sach/model/product_phobien.dart';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/page/tab_detail_book/binhluan.dart';
import 'package:app_doc_sach/view/pdf_view/pdf_view.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';
import '../../controller/auth_controller.dart';
import '../../model/author_model.dart';
import '../../model/chapter_model.dart';
import '../../model/popular_book_model.dart';
import '../../service/local_service/local_auth_service.dart';
import '../../service/remote_auth_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../login_register/chon_dangnhap.dart';
class ProductDetailPage extends StatefulWidget {
  final Book book;

  const ProductDetailPage({super.key, required this.book});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final favoriteService = Get.find<FavoriteService>();
  final authService = Get.find<AuthController>();
  late Future<Book> _futureBook;
  final LocalAuthService _localAuthService = LocalAuthService();
  late bool isFavorite = false;
  late ValueNotifier<Book> _bookNotifier;
  Future<Book> fetchBookById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/books/$id?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Book.fromJson({
        'id': json['data']['id'],
        ...json['data']['attributes'] ?? {},
      });
    } else {
      throw Exception('Failed to load book');
    }
  }
  void _toggleFavorite() async {
    if (authService.user.value == null) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng đăng nhập để thêm sách vào danh sách yêu thích',
        colorText: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.7),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 3),
        borderRadius: 10,
      );
      return;
    }

    await _localAuthService.init();
    String? token = _localAuthService.getToken();
    if (token == null) {
      print('Token is not available');
      return;
    }

    String userEmail = authService.user.value!.email!;
    var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
    if (userId == null) {
      print('User not found for email: $userEmail');
      return;
    }
    await favoriteService.toggleFavorite(userId,userEmail,token, widget.book);
    Book updatedBook = await fetchBookById(widget.book.id!);
    setState(() {
      isFavorite = !isFavorite;
      /*_futureBook = Future.value(updatedBook);*/
    });
  }
  @override
  void initState() {
    super.initState();
    _futureBook = fetchBookById(widget.book.id!);
    _initFavoriteStatus();
    _bookNotifier = ValueNotifier(widget.book);
  }
  void _initFavoriteStatus() async {
    if (authService.user.value != null) {
      await _localAuthService.init();
      String? token = _localAuthService.getToken();
      if (token == null) {
        print('Token is not available');
        return;
      }

      String userEmail = authService.user.value!.email!;
      var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
      if (userId != null) {
        bool favoriteStatus = await favoriteService.checkFavorite(userId, widget.book.id!);
        setState(() {
          isFavorite = favoriteStatus;
        });
      }
    }
  }
  IconData get favoriteIcon {
    if (authService.user.value == null) return Icons.favorite_border;
    return isFavorite ? Icons.favorite : Icons.favorite_border;
  }

  Color? get favoriteColor {
    if (authService.user.value == null) return null;
    return isFavorite ? Colors.red : null;
  }

  void _showChaptersDialog(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: MyColor.primaryColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: const Center(
                      child: Text(
                        'Danh sách chương',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: book.chapters?.length ?? 0,
                      itemBuilder: (context, index) {
                        Chapter chapter = book.chapters![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(context);
                                if (chapter.mediaFile != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFViewerPage(
                                        assetPath: chapter.mediaFile!.url,
                                        bookId: book.id!,
                                        chapterId: chapter.id!.toString(),
                                        chapterName: chapter.nameChapter,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: MyColor.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        chapter.nameChapter,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
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
            );
          },
        );
      },
    );
  }

  //Download file
  Future<void> downloadPdfFromStrapi(String pdfUrl, String chapterName) async {
    try {
      var response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        String filePath = '$appDocPath/$chapterName.pdf';

        File pdfFile = File(filePath);
        await pdfFile.writeAsBytes(response.bodyBytes);
        print('Downloaded PDF file to: $filePath');
      } else {
        print('Failed to download PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }
  Future<void> downloadAllChapters() async {
    for (var chapter in widget.book.chapters!) {
      if (chapter.mediaFile != null) {
        String pdfUrl = baseUrl + chapter.mediaFile!.url;
        await downloadPdfFromStrapi(pdfUrl, chapter.nameChapter);
      }
    }
    print('All chapters downloaded!');
  }

  Future<List<Book>> getBooksByCategory(String categoryName) async {
    try {
      String categoryFilter = 'filters[categories][name]=$categoryName';
      final response = await http.get(Uri.parse('$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*&$categoryFilter'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Book.fromJson({
          'id': json['id'],
          ...json['attributes'] ?? {},
        })).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading books: $e');
      rethrow;
    }
  }

  Future<List<Book>> _fetchRelatedBooks() async {
    Set<Book> relatedBooks = {};
    Set<String> uniqueBookIds = {}; // Tạo một Set để lưu trữ các ID duy nhất

    for (var category in widget.book.categories ?? []) {
      List<Book> books = await getBooksByCategory(category.nameCategory);
      for (var book in books) {
        if (book.id != widget.book.id && !uniqueBookIds.contains(book.id)) {
          relatedBooks.add(book);
          uniqueBookIds.add(book.id!);
        }
      }
    }

    return relatedBooks.toList();
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
  Widget _buildProductList(List<Book> products) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 50), // Thêm padding 50 pixel ở dưới
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
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left:10, right: 10, top: 10),
            child: Container(
              width: double.infinity,
              height: 220,
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
                          baseUrl + (product.coverImage?.url ?? ''),
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
                        ),
                      ),
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
                                  padding: const EdgeInsets.only(right: 4),
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
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: FutureBuilder<Book>(
          future: _futureBook,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load book'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Book not found'));
            }

            final book = snapshot.data!;

            return SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  // Rest of the UI code here, replace `product` with `book`
                  // For example:
                  Stack(
                    children: [
                      Container(
                        height: 290,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              baseUrl + book.coverImage!.url,
                              fit: BoxFit.cover,
                            ),
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                color: Colors.white.withOpacity(0.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 25,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_backspace_outlined, color: Colors.black),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.file_download_outlined, color: Colors.black),
                                  onPressed: downloadAllChapters,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.question_mark, color: Colors.black),
                                  onPressed: () {
                                    // Handle question mark action
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_outlined, color: Colors.black),
                                  onPressed: () {
                                    // Handle share action
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 45,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, top: 30),
                              child: Container(
                                height: 190,
                                width: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(0, 2),
                                      blurRadius: 20,
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(baseUrl + book.coverImage!.url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: Text(
                                        book.title!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30, // Chiều cao của container
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: book.authors?.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            Author author = entry.value;
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Text(
                                                '${author.authorName}${index < book.authors!.length - 1 ? ', ' : ''}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            );
                                          }).toList() ?? [
                                            Text(
                                              'Không có tác giả',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: book.categories?.map((category) => Padding(
                                          padding: EdgeInsets.only(right: 4), // Khoảng cách giữa các chip
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
                                        )).toList() ?? [Chip(label: Text('Không có danh mục'))],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite, color: Colors.red,size: 25,),
                                        const SizedBox(width: 4),
                                        Text(
                                          book.likes.toString(),
                                          style: const TextStyle(color: Colors.black, fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.remove_red_eye, color: Colors.black,size: 25),
                                        const SizedBox(width: 4),
                                        Text(
                                          book.view.toString(),
                                          style: const TextStyle(color: Colors.black, fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        const TabBar(
                          dividerColor: Colors.transparent,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black,
                          indicatorColor: Colors.black,
                          tabAlignment: TabAlignment.center,
                          isScrollable: true,
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                          tabs: [
                            Tab(text: "Giới thiệu"),
                            Tab(text: "Bình luận"),
                            Tab(text: "Sách liên quan"),
                            Tab(text: "Báo lỗi"),
                          ],
                        ),
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text('ISBN: ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5,),
                                          Text(book.isbn!,style: TextStyle(fontSize: 15),)
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text('Số trang: ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5,),
                                          Text(book.pages.toString(),style: TextStyle(fontSize: 15),)
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text('Ngôn ngữ: ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5,),
                                          Text(book.language!,style: const TextStyle(fontSize: 15),)
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Mô tả',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                                      const SizedBox(height: 5,),
                                      Text(book.description!,style: const TextStyle(fontSize: 15,),textAlign: TextAlign.justify,),
                                      const SizedBox(height: 50,)
                                    ],
                                  ),
                                ),
                              ),
                              Center(child: CommentScreen()), // Placeholder for comments
                              FutureBuilder<List<Book>>(
                                future: _fetchRelatedBooks(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('Không có sách liên quan',style: TextStyle(fontSize: 16),));
                                  } else {
                                    // Debugging print statement to ensure data is fetched
                                    print('Related Books: ${snapshot.data}');

                                    return _buildProductList(snapshot.data!);
                                  }
                                },
                              ),

                              Container(
                                height: 200,
                                child: const Center(
                                  child: Text(
                                    'Báo lỗi',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left:  16.0,right: 16.0,bottom: 16.0,top: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  favoriteIcon,
                  color: favoriteColor,
                  size: 35,
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 16), // Add some spacing between the icon and button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (authService.user.value == null) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.topSlide,
                        title: 'Thông báo',
                        desc: 'Bạn cần đăng nhập để đọc sách.',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const ChonDangNhapWidget(),
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
                        btnOkText: 'Đồng ý',
                        btnCancelText: 'Không',
                      ).show();
                    }
                    else {
                      if (widget.book.status == 'Mới nhất') {
                        bool isUserVIP = await authService.checkUserVIPStatus();
                        if (!isUserVIP) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.topSlide,
                            title: 'Thông báo',
                            titleTextStyle: const TextStyle(
                              fontSize: 22, // Custom font size
                              fontWeight: FontWeight.bold, // Custom font weight
                              color: Colors.black, // Custom color
                            ),
                            desc: 'Vui lòng đăng ký VIP để được đọc những cuốn sách mới nhất.',
                            descTextStyle: const TextStyle(
                              fontSize: 16, // Custom font size
                              color: Colors.black54, // Custom color
                            ),
                            btnOkOnPress: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => GiaHanGoi(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            btnOkText: 'Đăng ký VIP',
                            btnOkColor: Colors.green, // Custom button color
                            btnCancelOnPress: () {},
                            btnCancelText: 'Đóng',
                            btnCancelColor: Colors.red, // Custom button color
                          ).show();
                        } else {
                          _showChaptersDialog(context, widget.book);
                        }
                      } else {
                        _showChaptersDialog(context, widget.book);
                      }
                    }
                  },
                  child: const Text(
                    "Đọc sách",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}


