import 'dart:convert';
import 'dart:io';

import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/model/chapter_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';

import '../model/book_model.dart';
import '../model/file_upload.dart';
import 'package:http/http.dart' as http;

import '../model/uploadfilepdf.dart';
class ChapterController extends GetxController{
  static ChapterController instance = Get.find();
  Rxn<Chapter> chapter = Rxn<Chapter>();
  late BuildContext context;


  RxString chapterName = ''.obs;
  Rxn<File> selectedFile = Rxn<File>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<MediaFile?> uploadPDF(File file) async {
    var uri = Uri.parse('$baseUrl/api/upload');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'files',
      file.path,
      contentType: MediaType('application', 'pdf'),
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);
      return MediaFile.fromJson(jsonResponse[0]);  // Giả sử API trả về một mảng và chúng ta lấy phần tử đầu tiên
    } else {
      print('Failed to upload PDF: ${response.statusCode}');
      return null;
    }
  }

  Future<Chapter?> createChapter(String name, MediaFile file) async {
    var uri = Uri.parse('$baseUrl/api/chapters?populate=files');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
      'data': {
        'nameChaper': name, // Tên trường đã được sửa đổi dựa trên mẫu JSON
        'files': file.toJson(), // Đảm bảo files.data là một mảng với dữ liệu tệp
      }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['data'] != null) {
        return Chapter.fromJson(jsonResponse['data']);
      } else {
        print('Định dạng phản hồi không hợp lệ');
        return null;
      }
    } else {
      print('Lỗi khi tạo chương: ${response.statusCode}');
      print('Nội dung phản hồi: ${response.body}');
      return null;
    }
  }

  Future<void> updateBookInStrapi(Book book) async {
    var uri = Uri.parse('$baseUrl/api/books/${book.id}');
    var response = await http.put(
      uri,
      headers: <String, String> {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(book.toJsonChapter()),
    );

    if (response.statusCode != 200) {
      print('Failed to update book ${book.id}: ${response.statusCode}');
      print(book.toJson()); // Print the JSON payload after update

    } else {
      print('Successfully updated book ${book.id}');
      // Cập nhật UI
      update();
      // Hiển thị thông báo thành công
      Get.snackbar(
        'Thành công',
        'Đã thêm chương thành công',
        backgroundColor: const Color.fromRGBO(5, 127, 67, 100),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  void setChapterName(String name) {
    chapterName.value = name;
  }

  void setSelectedFile(File file) {
    selectedFile.value = file;
  }

  void clearSelectedFile() {
    selectedFile.value = null;
  }

  Future<void> addChapter(Book book) async {
    if (chapterName.isNotEmpty && selectedFile.value != null) {
      // Upload PDF file
      MediaFile? uploadedFile = await uploadPDF(selectedFile.value!);
      if (uploadedFile != null) {
        // Print uploaded file details for debugging
        print('Uploaded File Details:');
        print('ID: ${uploadedFile.id}');
        print('Name: ${uploadedFile.name}');
        print('URL: ${uploadedFile.url}');
        print('MIME Type: ${uploadedFile.mime}');

        // Create new chapter
        Chapter? newChapter = await createChapter(chapterName.value, uploadedFile);
        if (newChapter != null) {
          // Add new chapter to the book
          book.chapters ??= [];
          book.chapters!.add(newChapter);

          // Print chapter details for debugging
          print('New Chapter Created:');
          print('ID: ${newChapter.id}');
          print('Name: ${newChapter.nameChapter}');
          print('Media File URL: ${newChapter.mediaFile?.url}');

          // Update book in Strapi
          await updateBookInStrapi(book);

          // Clear the form
          chapterName.value = '';
          selectedFile.value = null;

          // Notify listeners
          update();
        }
      }
    }
  }

  Future<void> updateChapter(Book book, Chapter chapter) async {
    if (chapterName.value.isEmpty) {
      chapterName.value = chapter.nameChapter;
    }

    try {
      // Chuẩn bị dữ liệu để gửi lên server
      var chapterId = chapter.id;
      var newChapterName = chapterName.value;
      File? newFile = selectedFile.value;
      MediaFile? uploadedFile;

      // Kiểm tra xem có tệp mới được chọn không
      if (newFile != null) {
        print('Tệp mới đã được chọn:');
        print('Tên tệp: ${newFile.path}');
        print('Dung lượng: ${newFile.lengthSync()} bytes');

        // Thực hiện tải lên tệp mới và lấy thông tin tệp đã tải lên
        uploadedFile = await uploadPDF(newFile);
      // Nếu có tệp mới được chọn, hãy tải lên tệp đó
        // Kiểm tra và in ra thông tin của tệp đã tải lên
        if (uploadedFile != null) {
          print('Thông tin tệp đã tải lên:');
          print('ID: ${uploadedFile.id}');
          print('Tên: ${uploadedFile.name}');
          print('URL: ${uploadedFile.url}');
          // Thêm các thông tin khác của uploadedFile nếu cần
        }
      } else {
        print('Không có tệp mới được chọn.');
      }
      var uri = Uri.parse('$baseUrl/api/chapters/$chapterId');
      var response = await http.put(
        uri,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'data': {
            'nameChaper': newChapterName, // Tên trường đã được sửa đổi dựa trên mẫu JSON
            'files': uploadedFile!.toJson(), // Đảm bảo files.data là một mảng với dữ liệu tệp
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        var updatedChapter = Chapter.fromJson(jsonResponse['data']);

        // Cập nhật chapter trong danh sách local
        int index = book.chapters!.indexWhere((c) => c.id == chapterId);
        if (index != -1) {
          book.chapters![index] = updatedChapter;
        } else {
          print('Không tìm thấy chapter để cập nhật');
        }

        // Cập nhật UI
        update();
        // Hiển thị thông báo thành công
        Get.snackbar(
          'Thành công',
          'Đã cập nhật chapter thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('Lỗi khi cập nhật chapter: ${response.statusCode}');
        print('Nội dung phản hồi: ${response.body}');
        Get.snackbar(
          'Lỗi',
          'Không thể cập nhật chapter. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Lỗi khi cập nhật chapter: $e');
      // Xử lý lỗi
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật chapter. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateChapterNoFile(Book book, Chapter chapter) async {
    if (chapterName.value.isEmpty) {
      chapterName.value = chapter.nameChapter;
    }

    try {
      // Chuẩn bị dữ liệu để gửi lên server
      var chapterId = chapter.id;
      var newChapterName = chapterName.value;
      var uri = Uri.parse('$baseUrl/api/chapters/$chapterId');
      var response = await http.put(
        uri,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'data': {
            'nameChaper': newChapterName, // Tên trường đã được sửa đổi dựa trên mẫu JSON
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        var updatedChapter = Chapter.fromJson(jsonResponse['data']);

        // Cập nhật chapter trong danh sách local
        int index = book.chapters!.indexWhere((c) => c.id == chapterId);
        if (index != -1) {
          book.chapters![index] = updatedChapter;
          // Cập nhật selectedFile với file hiện tại của chapter
          if (updatedChapter.mediaFile != null) {
            // Tạo một File tạm thời từ URL của mediaFile
            selectedFile.value = File(updatedChapter.mediaFile!.url);
          }
        } else {
          print('Không tìm thấy chapter để cập nhật');
        }
        // Cập nhật UI
        update();
        // Hiển thị thông báo thành công
        Get.snackbar(
          'Thành công',
          'Đã cập nhật chapter thành công',
          backgroundColor: const Color.fromRGBO(5, 127, 67, 100),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('Lỗi khi cập nhật chapter: ${response.statusCode}');
        print('Nội dung phản hồi: ${response.body}');
        Get.snackbar(
          'Lỗi',
          'Không thể cập nhật chapter. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Lỗi khi cập nhật chapter: $e');
      // Xử lý lỗi
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật chapter. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteChapter(Book book, Chapter chapter) async {
    try {
      var chapterId = chapter.id;
      var uri = Uri.parse('$baseUrl/api/chapters/$chapterId');
      var response = await http.delete(uri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Xóa chapter khỏi danh sách local
        book.chapters!.removeWhere((c) => c.id == chapterId);

        // Cập nhật UI
        update();
        Get.snackbar(
          'Thành công',
          'Đã xóa chapter thành công',
          backgroundColor: const Color.fromRGBO(5, 127, 67, 100),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('Lỗi khi xóa chapter: ${response.statusCode}');
        print('Nội dung phản hồi: ${response.body}');
        Get.snackbar(
          'Lỗi',
          'Không thể xóa chapter. Vui lòng thử lại.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Lỗi khi xóa chapter: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể xóa chapter. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadChapters(Book book) async {
    try {
      var uri = Uri.parse('$baseUrl/api/books/${book.id}?populate=chapters');
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var updatedBook = Book.fromJson(jsonResponse['data']);
        book.chapters = updatedBook.chapters;
        update();
      } else {
        print('Lỗi khi tải lại chapters: ${response.statusCode}');
        print('Nội dung phản hồi: ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi tải lại chapters: $e');
    }
  }

  Future<List<Chapter>> getChapters(String bookId) async {
    final url = '$baseUrl/api/books/$bookId?populate[chapters][populate]=files';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final chaptersJson = jsonResponse['data']['attributes']['chapters']['data'] as List;
      return chaptersJson.map((json) => Chapter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chapters');
    }
  }
}
