import 'dart:convert';

import 'package:app_doc_sach/model/uploadfilepdf.dart';

class Chapter {
  int? id;
  final String nameChapter;
  MediaFile? mediaFile;

  Chapter({
    this.id,
    required this.nameChapter,
    this.mediaFile,
  });

  factory Chapter.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['attributes'] == null) {
      throw ArgumentError('Invalid JSON data for Chapter');
    }
    var filesData = json['attributes']['files'] != null ? json['attributes']['files']['data'] : null;
    MediaFile? mediaFile;
    if (filesData is List && filesData.isNotEmpty) {
      mediaFile = MediaFile.fromJson({
        'id': json['id'], // Thêm 'id' vào đây
        ...filesData[0]['attributes'], // Spread các thuộc tính từ attributes
      });
    }


    return Chapter(
      id: json['id'],
      nameChapter: json['attributes']['nameChaper'],
      mediaFile: mediaFile,
    );
  }


  @override
  String toString() {
    return 'Chapter(id: $id, name: $nameChapter, mediaFile: $mediaFile)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameChaper': nameChapter,
      'mediaFile': mediaFile?.toJson(), // Chuyển đổi đối tượng MediaFile thành JSON nếu có
    };
  }
}
// Method to parse list of chapters from JSON
List<Chapter> parseChapters(String jsonString) {
  final parsed = json.decode(jsonString);

  // Kiểm tra và lấy danh sách các chương từ dữ liệu JSON
  List<dynamic>? chaptersData = parsed['chapters'] != null ? parsed['chapters']['data'] : null;

  if (chaptersData == null || chaptersData.isEmpty) {
    return []; // Trả về danh sách rỗng nếu không có dữ liệu chương nào
  }

  // Chuyển đổi danh sách JSON thành danh sách các đối tượng Chapter
  return chaptersData.map((chapterJson) {
    // Kiểm tra và lấy thông tin về tệp đính kèm từ JSON
    var filesData = chapterJson['attributes']['files'] != null ? chapterJson['attributes']['files']['data'] : null;
    MediaFile? mediaFile;

    // Xác định và tạo đối tượng MediaFile nếu có thông tin tệp
    if (filesData is List && filesData.isNotEmpty) {
      mediaFile = MediaFile.fromJson(filesData[0]);
    }

    // Tạo đối tượng Chapter từ JSON
    return Chapter(
      id: chapterJson['id'],
      nameChapter: chapterJson['attributes']['nameChaper'] ?? '',
      mediaFile: mediaFile,
    );
  }).toList();
}

