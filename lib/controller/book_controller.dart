
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_doc_sach/model/book_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../const.dart';
import '../model/file_upload.dart';
class BookController extends GetxController{
  static BookController instance = Get.find();
  Rxn<Book> book = Rxn<Book>();
  late BuildContext context;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<List<Book>> getBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Raw JSON response: $jsonResponse'); // Thêm dòng này
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

  Future<Book> getBookById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/books/$id?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*'));

    if (response.statusCode == 200) {
      // Decode the response body and convert it to a Book object
      var jsonResponse = json.decode(response.body);
      var bookData = jsonResponse['data'];
      Book book = Book.fromJson({
        'id': bookData['id'],
        ...bookData['attributes'] ?? {},
      });
      return book;
    } else {
      throw Exception('Failed to load book');
    }
  }

  Future<List<Book>> getBooksBySearch(String textSearch) async {
    // Chuẩn hóa chuỗi tìm kiếm: chuyển về chữ thường và loại bỏ khoảng trắng
    final normalizedSearch = textSearch.toLowerCase().replaceAll(' ', '');

    // Xây dựng URL API với toán tử $containsi
    final String apiUrl = '$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*&filters[title][\$containsi]=$textSearch';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> bookData = data['data'] ?? [];

        return bookData.map((book) {
          try {
            return Book.fromJson({
              'id': book['id'],
              ...book['attributes'] ?? {},
            });
          } catch (e) {
            print('Error parsing book: $e');
            return null;
          }
        }).whereType<Book>().toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching books by search: $e');
      rethrow;
    }
  }
  Future<List<Book>> searchBooksLocally(String searchText, List<Book> allBooks) async {
    final normalizedSearch = searchText.toLowerCase().trim();

    return allBooks.where((book) {
      final bookTitle = book.title?.toLowerCase().trim() ?? '';
      return bookTitle.contains(normalizedSearch);
    }).toList();
  }

  //Get Book By Category
  Future<List<Book>> getBooksByCategory(String categoryName) async {
    try {
      // Build a query string for category name filter
      String categoryFilter = 'filters[categories][name]=$categoryName';

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
  Future<List<Book>> getBooksByAuthor(String authorName) async {
    try {
      // Build a query string for category name filter
      String authorFilter = 'filters[authors][authorName]=$authorName';

      final response = await http.get(Uri.parse('$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*&$authorFilter'));

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
  Future<List<Book>> getBooksByStatus(String status) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/books?populate[authors]=*&populate[categories]=*&populate[chapters][populate]=files&populate[cover_image]=*&filters[status]=$status'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Raw JSON response: $jsonResponse'); // Thêm dòng này
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
  Future<FileUpload?> uploadImage(File imageFile) async {
    var uri = Uri.parse('$baseUrl/api/upload');
    var request = http.MultipartRequest('POST', uri);

    List<int> imageBytes = await imageFile.readAsBytes();

    request.files.add(http.MultipartFile.fromBytes(
      'files',
      imageBytes,
      filename: 'image.png',
      contentType: MediaType('image', 'png'),
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          // Lấy phần tử đầu tiên nếu response là một List
          return FileUpload.fromJson(jsonResponse[0]);
        } else if (jsonResponse is Map<String, dynamic>) {
          // Nếu response là một Map, sử dụng nó trực tiếp
          return FileUpload.fromJson(jsonResponse);
        } else {
          print('Unexpected response format');
          return null;
        }
      } else {
        print('Lỗi khi tải lên ảnh. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi tải lên ảnh: $e');
      return null;
    }
  }

  Future<bool> createBook(Book book) async {
    final url = Uri.parse('$baseUrl/api/books');
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Book created successfully');
        return true;
      } else {
        print('Failed to create book. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating book: $e');
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/books/$bookId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Các header khác nếu cần thiết
        },
      );

      if (response.statusCode == 200) {
        print('Xóa sách thành công');
        return true;
      } else {
        print('Lỗi khi xóa sách. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi xóa sách: $e');
      return false;
    }
  }


}


