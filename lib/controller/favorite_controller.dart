import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../const.dart';
import '../model/book_model.dart';
import '../model/favorite_model.dart';
import '../model/user_model.dart';
import '../service/local_service/local_auth_service.dart';
import '../service/remote_auth_service.dart';
import 'auth_controller.dart'; // Giả sử bạn có file const.dart chứa BASE_URL
import 'package:flutter/material.dart';

class FavoriteService extends GetxController{
  final String _baseUrl = '$baseUrl/api';
  static FavoriteService instance = Get.find();
  Rxn<Favorite> favorite = Rxn<Favorite>();
  late BuildContext context;
  @override
  void onInit()  async {
    // TODO: implement onInit
    super.onInit();

    }

  Future<Favorite?> getFavoriteByUserId(String userId) async {
    final url = Uri.parse('$_baseUrl/favorites?filters[profile][id]=$userId&populate[books][populate][chapters][populate]=files&populate[profile]=*&populate[books][populate][cover_image]=*&populate[books][populate][categories]=*&populate[books][populate][authors]=*');
    print('Fetching favorite from URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> favoritesData = data['data'];

        if (favoritesData.isNotEmpty) {
          final favoriteData = favoritesData.first;
          final attributes = favoriteData['attributes'];

          // Parsing books data
          final List<dynamic> booksData = attributes['books']['data'];
          List<Book> books = booksData.map<Book>((bookData) {
            return Book.fromJson({
              'id': bookData['id'],
              ...bookData['attributes'] ?? {},
            });
          }).toList();
          // Đảo ngược danh sách sách
          books = books.reversed.toList();
/*
          // Parsing profile data
          final profileData = attributes['profile']['data'];
          Users profile = Users.fromJson(profileData['attributes']);
*/
        /*  print('Favorite ID: ${favoriteData['id']}, Books: ${books.length}, Profile: ${profile.fullName}');
*/
          // Printing books details
          print('Books in favorite:');
          for (var book in books) {
            print('- ${book.id}, by ${book.authors}');
            print('- ${book.title}, by ${book.authors}');
          }
          favorite.value = Favorite(
            id: int.parse(favoriteData['id'].toString()),
            /*profile: profile,*/
            books: books,
          );
          return favorite.value;
        } else {
          favorite.value = null; // Ensure favorite.value is null if no data
          return null;
        }
      } else {
        throw Exception('Failed to load favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorite: $e');
      throw Exception('Error fetching favorite: $e');
    }
  }

  Future<Users> getUserByEmail({required String email, required String token}) async {
    final url = Uri.parse('$baseUrl/api/profile/me?email=$email');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Users.fromJson(data);
      } else {
        print('API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Failed to load user. Network error: $e');
    }
  }

  Future<void> toggleFavorite(String userId, String email, String token, Book book) async {
    try {
      // Kiểm tra xem người dùng đã có danh sách yêu thích chưa
      Favorite? userFavorite = await getFavoriteByUserId(userId);

      // Lấy thông tin người dùng từ email và token
      Users userResult;
      try {
        userResult = await getUserByEmail(email: email, token: token);
      } catch (e) {
        print('Error getting user: $e');
        rethrow; // Ném lại lỗi để xử lý ở ngoài
      }

      bool isBookInFavorite = false;
      if (userFavorite != null) {
        // Nếu đã có, kiểm tra xem sách đã trong danh sách chưa
        isBookInFavorite = userFavorite.books!.any((b) => b.id == book.id);
      }

      if (userFavorite == null) {
        // Nếu chưa có, tạo mới danh sách yêu thích cho người dùng
        await createNewFavorite(userResult, book);
        Get.snackbar(
          'Thành công',
          'Đã thêm sách vào danh sách yêu thích',
          colorText: Colors.white,
          backgroundColor: Colors.green.withOpacity(0.7), // Màu xanh
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 3),
          borderRadius: 10,
        );
      } else {
        if (isBookInFavorite) {
          // Nếu sách đã có, xóa khỏi danh sách
          await removeFromFavorite(userFavorite.id!, book.id!);
          await decrementLikes(book);
          Get.snackbar(
            'Thành công',
            'Đã xóa sách khỏi danh sách yêu thích',
            colorText: Colors.white,
            backgroundColor: Colors.red.withOpacity(0.7),
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(20),
            duration: Duration(seconds: 3),
            borderRadius: 10,
          );
        } else {
          // Nếu sách chưa có, thêm vào danh sách
          await addToFavorite(userFavorite.id!, book);
          await incrementLikes(book);
          Get.snackbar(
            'Thành công',
            'Đã thêm sách vào danh sách yêu thích',
            colorText: Colors.white,
            backgroundColor: Colors.green.withOpacity(0.7), // Màu xanh
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(20),
            duration: Duration(seconds: 3),
            borderRadius: 10,
          );
        }
      }

      // Cập nhật lại danh sách yêu thích sau khi thay đổi
      favorite.value = await getFavoriteByUserId(userId);
      update();
    } catch (e) {
      print('Error toggling favorite: $e');
      throw Exception('Error toggling favorite: $e');
    }
  }


  Future<void> incrementLikes(Book book) async {
    try {
      // Địa chỉ endpoint của Strapi cho sách (thay đổi phù hợp với cấu hình của bạn)
      String apiUrl = '$baseUrl/api/books/${book.id}';
      // Lấy số lượt thích hiện tại của cuốn sách
      int currentLikes = await getLikes(book.id.toString());

      // Tạo body của yêu cầu PUT để tăng số lượt thích
      Map<String, dynamic> body = {
        'data': {
          'likes': currentLikes + 1, // Lấy số lượt thích hiện tại và tăng lên 1
        }
      };

      // Chuyển đổi body thành JSON
      String jsonBody = jsonEncode(body);

      // Gửi yêu cầu PUT đến Strapi
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        print('Likes incremented successfully for book ${book.id}');
      } else {
        print('Failed to increment likes: ${response.statusCode}');
        throw Exception('Failed to increment likes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error incrementing likes: $e');
      throw Exception('Error incrementing likes: $e');
    }
  }

  Future<void> decrementLikes(Book book) async {
    try {
      // Địa chỉ endpoint của Strapi cho sách (thay đổi phù hợp với cấu hình của bạn)
      String apiUrl = '$baseUrl/api/books/${book.id}';
      // Lấy số lượt thích hiện tại của cuốn sách
      int currentLikes = await getLikes(book.id.toString());
      // Tạo body của yêu cầu PUT để giảm số lượt thích
      Map<String, dynamic> body = {
        'data': {
          'likes': currentLikes - 1, // Lấy số lượt thích hiện tại và giảm đi 1
        }
      };

      // Chuyển đổi body thành JSON
      String jsonBody = jsonEncode(body);

      // Gửi yêu cầu PUT đến Strapi
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        print('Likes decremented successfully for book ${book.id}');
      } else {
        print('Failed to decrement likes: ${response.statusCode}');
        throw Exception('Failed to decrement likes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error decrementing likes: $e');
      throw Exception('Error decrementing likes: $e');
    }
  }


// Hàm lấy số lượt thích hiện tại của cuốn sách từ Strapi
  Future<int> getLikes(String bookId) async {
    try {
      // Địa chỉ endpoint của Strapi cho sách (thay đổi phù hợp với cấu hình của bạn)
      String apiUrl = '$baseUrl/api/books/$bookId';

      // Gửi yêu cầu GET để lấy thông tin cuốn sách từ Strapi
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Phân tích JSON và trả về số lượt thích của cuốn sách
        Map<String, dynamic> bookData = jsonDecode(response.body);
        return bookData['data']['attributes']['likes'];
      } else {
        print('Failed to get likes: ${response.statusCode}');
        throw Exception('Failed to get likes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting likes: $e');
      throw Exception('Error getting likes: $e');
    }
  }
  Future<void> createNewFavorite(Users user, Book book) async {
    final url = Uri.parse('$_baseUrl/favorites');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Thêm token nếu cần thiết
          // 'Authorization': 'Bearer ${user.token}',
        },
        body: json.encode({
          'data': {
            'profile': user.id,  // Sử dụng ID của user thay vì toàn bộ object
            'books': [book.id],  // Sử dụng ID của book trong một mảng
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Favorite created successfully');
        await incrementLikes(book);
      } else {
        print('Failed to create favorite. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Không thể tạo mục yêu thích mới: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi tạo mục yêu thích mới: $e');
      throw Exception('Lỗi khi tạo mục yêu thích mới: $e');
    }
  }

  Future<void> addToFavorite(int favoriteId, Book book) async {
    final url = Uri.parse('$_baseUrl/favorites/$favoriteId');
    try {
      // Lấy danh sách sách hiện tại
      List<String> currentBooks = favorite.value?.books!.map((b) => b.id!).toList() ?? [];

      // Kiểm tra xem sách đã có trong danh sách chưa
      if (!currentBooks.contains(book.id)) {
        currentBooks.add(book.id!);
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'data': {
            'books':
            {
              "connect": currentBooks,
            }
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add to favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding to favorite: $e');
      throw Exception('Error adding to favorite: $e');
    }
  }

  Future<void> removeFromFavorite(int favoriteId, String bookId) async {
    final url = Uri.parse('$_baseUrl/favorites/$favoriteId');
    try {
      // Lấy danh sách sách hiện tại và xóa sách cần xóa
      List<String> currentBooks = favorite.value?.books!.map((b) => b.id!).toList() ?? [];
      currentBooks.remove(bookId);

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'data': {
            'books': currentBooks,
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing from favorite: $e');
      throw Exception('Error removing from favorite: $e');
    }
  }

  Future<bool> checkFavorite(String userId, String bookId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/favorites?filters[profile][id]=$userId&filters[books][id]=$bookId&populate[books.chapters.populate]=files&populate=profile,books.cover_image,categories,authors'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if there's any data matching the filters
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          // If there's any data matching, consider it as favorite
          return true;
        } else {
          // No favorite found for this user and book
          return false;
        }
      } else {
        throw Exception('Failed to check favorite status');
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}