import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../const.dart';
import '../../../controller/chapter_controller.dart';
import '../../../model/book_model.dart';
import '../../../model/chapter_model.dart';
import 'package:http/http.dart' as http;

class ChapterDetail extends StatefulWidget {
  const ChapterDetail({super.key, required this.book});
  final Book book;
  @override
  State<ChapterDetail> createState() => _ChapterDetailState();
}

class _ChapterDetailState extends State<ChapterDetail> {
  late String chapterName;
  File? selectedFile;
  late Future<List<Chapter>> _chaptersFuture;
   late String tenchuong;
  final ChapterController controller = Get.find<ChapterController>();
  void _editChapter(Chapter chapter) {
    // In ra dữ liệu của mediaFile trước khi hiển thị dialog
    if (chapter.mediaFile != null) {
      print('Media File Before Dialog:');
      print('ID: ${chapter.mediaFile!.id}');
      print('Name: ${chapter.mediaFile!.name}');
      print('URL: ${chapter.mediaFile!.url}');
    }

    // Hiển thị dialog chỉnh sửa chapter
    _showEditChapterDialog(chapter);
  }
  Future<List<Chapter>> _loadChapters() async {
    // Giả sử bạn có một phương thức để lấy danh sách chương mới nhất
    return await controller.getChapters(widget.book.id!);
  }


  void _removeChapter(Chapter chapter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa chương "${chapter.nameChapter}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng dialog
                await controller.deleteChapter(widget.book, chapter);
                _refreshChapters();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    chapterName = '';
    selectedFile = null;
    _chaptersFuture = _loadChapters();
  }

  void _refreshChapters() {
    setState(() {
      _chaptersFuture = _loadChapters();
    });
  }
  void _addChapter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Thêm chương mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Tên chương'),
                    onChanged: controller.setChapterName
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        controller.setSelectedFile(File(result.files.single.path!));
                      }
                    },
                    child: const Text('Chọn File'),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.selectedFile.value != null) {
                      return Column(
                        children: [
                          Image.asset(
                            'assets/icon/pdf.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text('File đã chọn: ${controller.selectedFile.value!.path.split('/').last}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: controller.clearSelectedFile,
                            child: const Text('Xóa File'),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    await controller.addChapter(widget.book);
                    Navigator.of(context).pop();
                    _refreshChapters();
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditChapterDialog(Chapter chapter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {

            return AlertDialog(
              title: const Text('Chỉnh sửa chương'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Tên chương'),
                    controller: TextEditingController(text: chapter.nameChapter),
                    onChanged: controller.setChapterName,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        controller.setSelectedFile(File(result.files.single.path!));
                        controller.update(); // Cập nhật UI sau khi setSelectedFile
                      }
                    },
                    child: const Text('Chọn File mới'),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.selectedFile.value != null) {
                      return Column(
                        children: [
                          Image.asset(
                            'assets/icon/pdf.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text('File đã chọn: ${controller.selectedFile.value!.path.split('/').last}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: controller.clearSelectedFile,
                            child: const Text('Xóa File'),
                          ),
                        ],
                      );
                    } else if (chapter.mediaFile != null) {
                      return Column(
                        children: [
                          Image.asset(
                            'assets/icon/pdf.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text('File hiện tại: ${chapter.mediaFile!.name}'), // Đảm bảo rằng 'name' được truy cập đúng
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    if (controller.selectedFile.value != null) {
                      await controller.updateChapter(widget.book, chapter);
                    } else {
                      await controller.updateChapterNoFile(widget.book, chapter);
                    }
                    Navigator.of(context).pop();
                    _refreshChapters();
                  },
                  child: const Text('Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title ?? 'Chi tiết sách'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  baseUrl + widget.book.coverImage!.url,
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tiêu đề sách
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                ),
                children: [
                  const TextSpan(
                    text: 'Tên sách: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: widget.book.title ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ISBN
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(
                    text: 'ISBN: ',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                  TextSpan(
                    text: widget.book.isbn ?? 'Không có ISBN',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tác giả
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Tác giả: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.book.authors!.isNotEmpty
                        ? widget.book.authors!.map((author) => author.authorName).join(', ')
                        : 'Không có tác giả',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ngôn ngữ
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Ngôn ngữ: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.book.language ?? 'Không có Ngôn ngữ',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ngôn ngữ
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(
                    text: 'Số trang: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: widget.book.pages.toString() ?? 'Không có so luong trang',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            const Text(
              'Danh sách chương',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Chapter>>(
              future: _chaptersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final chapters = snapshot.data!;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                chapter.nameChapter,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editChapter(chapter),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeChapter(chapter),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < chapters.length - 1)
                              const Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return  const CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addChapter();
        },
        tooltip: 'Thêm chương',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling, // Sử dụng hiệu ứng scaling
    );
  }
}
