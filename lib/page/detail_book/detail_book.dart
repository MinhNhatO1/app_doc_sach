import 'dart:convert';
import 'dart:ui'; // Import for ImageFilter
import 'package:app_doc_sach/controller/favorite_controller.dart';
import 'package:app_doc_sach/model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_doc_sach/model/product_phobien.dart';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/page/tab_detail_book/binhluan.dart';
import 'package:app_doc_sach/view/pdf_view/pdf_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';
import '../../controller/auth_controller.dart';
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

    String userEmail = authService.user.value!.email;
    var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
    if (userId == null) {
      print('User not found for email: $userEmail');
      return;
    }
    await favoriteService.toggleFavorite(userId,userEmail,token, widget.book);
    setState(() {
      isFavorite = !isFavorite;
    });
  }
  @override
  void initState() {
    super.initState();
    _futureBook = fetchBookById(widget.book.id!);
    _initFavoriteStatus();
  }
  void _initFavoriteStatus() async {
    if (authService.user.value != null) {
      await _localAuthService.init();
      String? token = _localAuthService.getToken();
      if (token == null) {
        print('Token is not available');
        return;
      }

      String userEmail = authService.user.value!.email;
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

  void _showChaptersDialog(BuildContext context,Book book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, // Điều chỉnh chiều cao tối đa
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top:  16,right: 16,left: 16 ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách chương',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.book.chapters?.length ?? 0,
                  itemBuilder: (context, index) {
                    Chapter chapter = widget.book.chapters![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(chapter.nameChapter),
                          onTap: () {
                            Navigator.pop(context); // Close the bottom sheet
                            if (chapter.mediaFile != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerPage(
                                    assetPath: chapter.mediaFile!.url,
                                    bookId: widget.book.id!,
                                    chapterId: chapter.id!.toString(),
                                    chapterName: chapter.nameChapter,
                                  ),
                                ),
                              );
                            }
                          },
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
                                  onPressed: () {
                                    // Handle download action
                                  },
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
                                    Text(
                                      book.authors?.map((author) => author.authorName).join(', ') ?? 'Không có tác giả',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400
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
                              Container(
                                height: 200,
                                child: const Center(
                                  child: Text(
                                    'Sách liên quan',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
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
                    } else {
                      _showChaptersDialog(context, widget.book);
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


