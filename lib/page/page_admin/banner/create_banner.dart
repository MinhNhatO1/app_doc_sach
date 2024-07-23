import 'dart:io';
import 'package:app_doc_sach/model/file_upload.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_doc_sach/const.dart';

class CreateBannerPage extends StatefulWidget {
  @override
  _CreateBannerPageState createState() => _CreateBannerPageState();
}

class _CreateBannerPageState extends State<CreateBannerPage> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
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
          return FileUpload.fromJson(jsonResponse[0]);
        } else if (jsonResponse is Map<String, dynamic>) {
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

  Future<void> createBanner() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một ảnh')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload ảnh
      FileUpload? uploadedImage = await uploadImage(_image!);

      if (uploadedImage == null) {
        throw Exception('Lỗi khi tải lên ảnh');
      }

      // Tạo banner mới
      var response = await http.post(
        Uri.parse('$baseUrl/api/banners'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': {
            'image_banner': uploadedImage.id,
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner đã được tạo thành công')),
        );
        Navigator.of(context).pop(true); // Trả về true để cập nhật trang chính
      } else {
        throw Exception('Lỗi khi tạo banner');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Banner Mới'),
        backgroundColor: Colors.blueGrey, // Màu sắc của AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:16.0,right: 5,left: 5,bottom: 16),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _image != null
                  ? Padding(
                padding: const EdgeInsets.only(left: 5,right: 5),
                    child: Image.file(
                                    _image!,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                  ),
                  )
                  : Center(
                child: SizedBox(
                  height: 100, // Chiều cao của ảnh nhỏ hơn
                  width: 100, // Chiều rộng của ảnh nhỏ hơn
                  child: Image.asset(
                    'assets/icon/image_default.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Màu chữ nút
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: getImage,
                  child: Text('Chọn Ảnh', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(width: 20), // Khoảng cách giữa hai nút
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Màu chữ nút
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : createBanner,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo Banner', style: TextStyle(fontSize: 18)),
                ),
              ],
            )

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshPage, // Hàm để làm mới trang
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ),
    );

  }
  void refreshPage() {
    setState(() {
      // Đặt lại trạng thái của các biến về giá trị ban đầu hoặc thực hiện các hành động làm mới trang khác
      _image = null;
      _isLoading = false;
    });
}
}
