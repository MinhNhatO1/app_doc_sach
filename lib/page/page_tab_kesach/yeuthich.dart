import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';
import '../../controller/auth_controller.dart';
import '../../controller/favorite_controller.dart';
import '../../model/author_model.dart';
import '../../model/book_model.dart';
import '../../model/category_model.dart';
import '../../model/favorite_model.dart';
import '../../service/local_service/local_auth_service.dart';
import '../../service/remote_auth_service.dart';
import '../detail_book/detail_book.dart';

class YeuthichWidget extends StatefulWidget {
  const YeuthichWidget({super.key});

  @override
  State<YeuthichWidget> createState() => _LichSuDocWidgetState();
}

class _LichSuDocWidgetState extends State<YeuthichWidget> {
  final FavoriteService _favoriteService = FavoriteService();
  final AuthController _authController  = Get.find();
  final LocalAuthService _localAuthService = LocalAuthService();
  Timer? timer = Timer(Duration.zero, () {});
   Favorite? _favorite;
  final _isLoading = false.obs;
  late bool isFavorite = false; // Initialize isFavorite
  @override
  void initState() {
    super.initState();
    setupUserListener();
  }
  void setupUserListener() {
    if (_authController.user.value != null) {
      _loadFavorites();
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 15), (Timer t) {
        _loadFavorites();
      });
    } else {
      print('User not logged in. Cannot load reading histories.');
      timer?.cancel();
      timer = null;
      clearFavorites();
    }
  }
  void clearFavorites() {
    setState(() {_favorite = null;
      _favorite?.books!.clear();;}); // Cập nhật lại giao diện sau khi xóa lịch sử đọc
  }
  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    timer = null; // Gán timer = null để đảm bảo không có timer nào đang tồn tại
    super.dispose();
  }
  Future<void> _loadFavorites() async {
    if (_authController.user.value == null) {
      print('User is null, clearing favorite');
      setState(() {
        _favorite == null;
        _favorite?.books!.clear();
      });
      return;
    }

    try {
      await _localAuthService.init();

      String? token = _localAuthService.getToken();
      if (token == null) {
        print('Token is not available');
        throw Exception("Token is not available");
      }

      String userEmail = _authController.user.value?.email ?? '';
      if (userEmail.isEmpty || token.isEmpty) {
        _isLoading.value = false;
        print('Email or token is empty. Email: $userEmail, Token: ${token.isNotEmpty ? 'Not empty' : 'Empty'}');
        return;
      }

      var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
      if (userId == null) {
        _isLoading.value = false;
        print('User not found for email: $userEmail');
        return;
      }
      print('User ID: $userId');

      final favorite = await _favoriteService.getFavoriteByUserId(userId);
      print('Loaded favorite');

      setState(() {
        _favorite = favorite!;
        _isLoading.value = false;
      });
    } catch (e) {
      print('Error loading favorite: $e');
      setState(() => _isLoading.value = false);
    }
  }

  List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.amberAccent,
    Colors.purple,
  ];
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
    finally{
      _isLoading.value = false;
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
  Color getRandomColor() {
    final random = Random();
    return _colors[random.nextInt(_colors.length)];
  }
  List<Color> _bookColors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(232, 245, 233, 1.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            GetX<AuthController>(
              builder: (controller) {
                return buildHeader(controller);
              },
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: GetX<AuthController>(
                builder: (_) {
                  if (_isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (_.user.value != null) {
                      if (_favorite == null) {
                        return const Center(child: Text('Không tìm thấy danh sách yêu thích'));
                      } else {
                        // Ensure _bookColors has the same length as _favorite.books
                        if (_bookColors.length != _favorite!.books!.length) {
                          _bookColors = List<Color>.generate(_favorite!.books!.length, (index) => getRandomColor());
                        }
                        return buildFavoriteGridView();
                      }
                    } else {
                      return const Center(child: Text('Không tìm thấy danh sách yêu thích'));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildHeader(AuthController controller) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      height: 50,
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                '${ controller.user.value != null ?
                    _favorite?.books!.length : 0} sách',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.circle_grid_3x3_fill,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_list_alt,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFavoriteGridView() {
    if (_favorite == null|| _favorite!.books!.isEmpty) {
      return Center(child: Text('Không tìm thấy danh sách yêu thích')); // Xử lý trường hợp _favorite là null hoặc rỗng
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 3,
      ),
      itemCount: _favorite?.books!.length,
      itemBuilder: (context, index) {
        final book = _favorite?.books![index];
        final bookColor = _bookColors[index % _bookColors.length];

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
                      baseUrl + (book!.coverImage?.url ?? ''),
                      fit: BoxFit.cover,
                      height: 180,
                      width: 130,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.book),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    book.title ?? 'Unknown',
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
