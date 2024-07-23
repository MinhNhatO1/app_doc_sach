import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const.dart';
import 'package:http/http.dart' as http;

import '../../controller/auth_controller.dart';
import '../../model/chapterprocess_model.dart';
import '../../model/readinghistory_model.dart';
import '../../service/local_service/local_auth_service.dart';
import '../../service/remote_auth_service.dart';

class PDFViewerPage extends StatefulWidget {
  final String assetPath;
  final String bookId;
  final String chapterId;
  final String chapterName;
  const PDFViewerPage({super.key, required this.assetPath,required this.bookId,
    required this.chapterId,required this.chapterName});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PdfViewerController _pdfViewerController;
  int _currentPage = 0;
  final LocalAuthService _localAuthService = LocalAuthService();
  AuthController authController = Get.find();
  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadLastPage();
  }

  Future<void> _loadLastPage() async {
    await _localAuthService.init(); // Đảm bảo khởi tạo

    String? token = _localAuthService.getToken();
    if (token == null) {
      throw Exception("Token không khả dụng");
    }

    String userEmail = authController.user.value?.email ?? '';
    if (userEmail.isEmpty || token.isEmpty) {
      print('Email hoặc token trống.');
      return;
    }

    var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
    if (userId == null) {
      print('Không tìm thấy người dùng với email: $userEmail');
      return;
    }

    // Điều chỉnh URL để phù hợp với cấu trúc API của bạn
    final url = Uri.parse('$baseUrl/api/reading-histories?populate=book,profile,chapter_processes.chapter&filters[profile][id]=$userId&filters[book][id]=${widget.bookId}');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        final readingHistoryData = data['data'][0]['attributes'];
        final chapterProcesses = readingHistoryData['chapter_processes']['data'];

        // Tìm tiến trình đọc cho chương hiện tại
        final currentChapterProcess = chapterProcesses.firstWhere(
              (process) => process['attributes']['chapter']['data']['id'].toString() == widget.chapterId,
          orElse: () => null,
        );

        if (currentChapterProcess != null) {
          // Nếu chương đã có trong lịch sử, nhảy đến trang cuối cùng đã đọc
          setState(() {
            _currentPage = currentChapterProcess['attributes']['pageNumber'];
            _pdfViewerController.jumpToPage(_currentPage + 1);
          });
        } else {
          // Nếu chương chưa có trong lịch sử, thêm nó với trang 0
          await _addNewChapterProgress(data['data'][0]['id'], userId);
        }
      } else {
        // Nếu không có lịch sử đọc cho cuốn sách này, tạo mới
        await createNewReadingHistory(userId.toString());
      }
    } else {
      print('Error response: ${response.body}');
      throw Exception('Không thể tải lịch sử đọc. Status code: ${response.statusCode}');
    }
  }


  Future<void> _addNewChapterProgress(int readingHistoryId, String userId) async {
    final url = Uri.parse('$baseUrl/api/chapter-processes');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'data': {
          'chapter': widget.chapterId,
          'pageNumber': _currentPage,  // Sử dụng _currentPage thay vì 0
          'lastReadAt': DateTime.now().toIso8601String(),
          'reading_history': readingHistoryId,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add new chapter progress');
    }
  }

  Future<void> createNewReadingHistory(String userId) async {
    final url = Uri.parse('$baseUrl/api/reading-histories');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'data': {
          'profile': {
            'connect': [userId]
          },
          'book': {
            'connect': [widget.bookId]
          },
          'lastReadAt': DateTime.now().toIso8601String(),
          'chapter_processes': {
            'create': [
              {
                'chapter': {
                  'connect': [widget.chapterId]
                },
                'pageNumber': 0,
                'lastReadAt': DateTime.now().toIso8601String(),
              }
            ]
          }
        }
      }),
    );

    if (response.statusCode != 200) {
      print('E: ${response.body}');
      throw Exception('Failed to create new reading history');
    }
  }

  Future<void> _updateReadingHistory() async {
    final url = Uri.parse('$baseUrl/api/reading-histories?populate=book,profile,chapter_processes.chapter&filters[profile][id]=${authController.user.value?.id}&filters[book][id]=${widget.bookId}');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        ReadingHistory readingHistory = ReadingHistory.fromJson(data['data'][0]);

        ChapterProgress? currentChapterProgress = readingHistory.chapterProgress.firstWhereOrNull(
                (progress) => progress.chapter?.id.toString() == widget.chapterId
        );

        if (currentChapterProgress != null) {
          // Update existing chapter progress
          await _updateChapterProgress(currentChapterProgress.id!, _currentPage);
        } else {
          // Add new chapter progress
          await _addNewChapterProgress(readingHistory.id!, authController.user.value!.id!.toString());
        }

        // Update last read time for the reading history
        await _updateReadingHistoryLastReadAt(readingHistory.id!);
      } else {
        // If no reading history exists, create a new one
        await createNewReadingHistory(authController.user.value!.id!.toString());
      }
    }
  }

  Future<void> _updateChapterProgress(int chapterProgressId, int pageNumber) async {
    final url = Uri.parse('$baseUrl/api/chapter-processes/$chapterProgressId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'data': {
          'pageNumber': pageNumber,
          'lastReadAt': DateTime.now().toIso8601String(),
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update chapter progress');
    }
  }

  Future<void> _updateReadingHistoryLastReadAt(int readingHistoryId) async {
    final url = Uri.parse('$baseUrl/api/reading-histories/$readingHistoryId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'data': {
          'lastReadAt': DateTime.now().toIso8601String(),
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update reading history last read time');
    }
  }
  void _saveLastPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage_${widget.assetPath}', _currentPage);
  }

  @override
  void dispose() {
    _saveReadingProgress();
    super.dispose();
  }
  void _saveReadingProgress() async {
     _saveLastPage();
    await _updateReadingHistory();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName,style: const TextStyle(
          fontSize: 18,
          color: Colors.black
        ),),
      ),
      body: SfPdfViewer.network(
        baseUrl + widget.assetPath,
        controller: _pdfViewerController,
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _currentPage = details.newPageNumber - 1;
          });
          /*_saveLastPage();*/
        },
      ),
    );
  }
}