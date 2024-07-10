import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../const.dart';
import '../../controller/auth_controller.dart';
import '../../controller/historyreading_controller.dart';
import '../../model/author_model.dart';
import '../../model/book_model.dart';
import '../../model/category_model.dart';
import '../../model/readinghistory_model.dart';
import 'package:http/http.dart' as http;

import '../../model/user_model.dart';
import '../../service/local_service/local_auth_service.dart';
import '../../service/remote_auth_service.dart';
import '../detail_book/detail_book.dart';
class LichSuDocWidget extends StatefulWidget {
  const LichSuDocWidget({super.key});

  @override
  State<LichSuDocWidget> createState() => _LichSuDocWidgetState();
}

class _LichSuDocWidgetState extends State<LichSuDocWidget> {
  final ReadingHistoryController controller = ReadingHistoryController();
  final List<ReadingHistory> histories = [];
  RxBool isLoading = false.obs;
  final LocalAuthService _localAuthService = LocalAuthService();
  AuthController authController = Get.find();
  Timer? timer = Timer(Duration.zero, () {});
  @override
  void initState()  {
    super.initState();
    // Kiểm tra xem người dùng đã đăng nhập chưa

    setupUserListener();
  }
  void setupUserListener() {
      if (authController.user.value != null) {
        loadReadingHistories();
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 15), (Timer t) {
          loadReadingHistories();
        });
      } else {
        print('User not logged in. Cannot load reading histories.');
        timer?.cancel();
        timer = null;
        clearHistories();
      }
  }
  void clearHistories() {
    setState(() {histories.clear();}); // Cập nhật lại giao diện sau khi xóa lịch sử đọc
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    timer = null; // Gán timer = null để đảm bảo không có timer nào đang tồn tại
    super.dispose();
  }
  Future<void> loadReadingHistories() async {
    if (authController.user.value == null) {
      // Xử lý khi user là null, ví dụ:
      setState(() {
        histories.clear();
      });
      return;
    }
    try {
      await _localAuthService.init(); // Ensure initialization

      String? token = _localAuthService.getToken();
      if (token == null) {
        throw Exception("Token is not available");
      }

      String userEmail = authController.user.value?.email ?? '';
      if (userEmail.isEmpty || token.isEmpty) {
        isLoading.value = false; // Set loading state
        print('Email or token is empty.');
        return;
      }

      var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
      if (userId == null) {
        isLoading.value = false; // Set loading state
        print('User not found for email: $userEmail');
        return;
      }

      final response = await http.get(Uri.parse(
          '$baseUrl/api/reading-histories?filters[profile][id]=$userId&populate[book][populate][cover_image]=*&populate[book][populate][categories]=*&populate[book][populate][authors]=*&populate[book][populate][chapters][populate]=files&populate[profile]=*&populate[chapter_processes][populate][chapter]=files'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if JSON data exists and contains 'data' key
        if (data != null &&
            data['data'] != null &&
            data['data'] is List) {
          histories.clear();
          List<dynamic> dataList = data['data'];
          histories.addAll(dataList.map((item) => ReadingHistory.fromJson(item)));
         /* // Sort histories by ID from largest to smallest
          histories.sort((a, b) => b.id!.compareTo(a.id!));*/
          histories.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
         /* print('Loaded Reading Histories:');
          histories.forEach((history) {
            print('ID: ${history.id}');
            print('User: ${history.user?.id}');
            if (history.book != null) {
              print('Book:');
              print('ID: ${history.book!.id}');
              print('Title: ${history.book!.title}');
              print('Author: ${history.book!.authors}');
            } else {
              print('No Book information available.');
            }
            print('Chapter Progress:');
            history.chapterProgress.forEach((progress) {
              print('Process ID: ${progress.id}');
              print('Chapter ID: ${progress.chapter?.id}');
              print('Chapter Name: ${progress.chapter?.nameChapter}');
              print('Page Number: ${progress.pageNumber}');
              print('Last Read At: ${progress.lastReadAt}');
            });
            print('Last Read At: ${history.lastReadAt}');
            print('-------------------');
          });
*/
        } else {
          throw Exception('No data found or invalid JSON structure');

        }
      } else {
        throw Exception('Failed to load reading histories: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in loadReadingHistories: $e');
      print('Stack trace: $stackTrace'); // Print stack trace for detailed error location
    } finally {
      isLoading.value = false; // Set loading state
      setState(() {}); // Update widget state
    }
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
  List<Color> _bookColors = [];
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
    // Đảm bảo rằng danh sách _bookColors có cùng số lượng phần tử với danh sách books
    if (_bookColors.length != histories.length) {
      _bookColors = List<Color>.generate(histories.length, (index) => getRandomColor());
    }
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
              child: Obx(() {
                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Kiểm tra xem người dùng đã đăng nhập hay chưa
                  if (authController.user.value != null) {
                    // Đã đăng nhập, hiển thị danh sách lịch sử đọc
                    if (histories.isEmpty) {
                      return const Center(child: Text('Không tìm thấy lịch sử đọc'));
                    } else {
                      return buildGridView(); // Hiển thị danh sách lịch sử đọc
                    }
                  } else {
                    // Chưa đăng nhập, hiển thị thông báo không tìm thấy lịch sử đọc
                    return const Center(child: Text('Không tìm thấy lịch sử đọc'));
                  }
                }
              }),
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
                '${controller.user.value != null ? histories.length : 0} sách',
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
                    icon: const FaIcon(
                      CupertinoIcons.circle_grid_3x3_fill,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {},
                    icon: const FaIcon(
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

  Widget buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 7,
      ),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        final bookColor = _bookColors[index];
        return GestureDetector(
          onTap: () {
            incrementView(history.book!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(book: history.book!),
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
                      baseUrl +
                          (history.book?.coverImage?.url ?? ''),
                      fit: BoxFit.cover,
                      height: 180,
                      width: 130,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.book),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
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
                        getFirstCategoryName(
                            history.book?.categories ?? []),
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
                    history.book?.title ?? 'UnKnow',
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
                    getFirstAuthorName(history.book?.authors ?? []),
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
