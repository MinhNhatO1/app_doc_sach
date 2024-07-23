import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/model/banner_model.dart';
import 'package:app_doc_sach/model/file_upload.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UpdateBannerPage extends StatefulWidget {
  final Banner_Model banner;

  UpdateBannerPage({Key? key, required this.banner}) : super(key: key);

  @override
  _UpdateBannerPageState createState() => _UpdateBannerPageState();
}

class _UpdateBannerPageState extends State<UpdateBannerPage> {
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Xác Nhận',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          content: const Text('Bạn có chắc chắn muốn cập nhật banner này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: Colors.red,fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Xác Nhận', style: TextStyle(color: Colors.white,fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop(true); // Trả về true để cập nhật trang chính
                updateBanner(); // Gọi hàm cập nhật banner
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateBanner() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một ảnh mới')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      FileUpload? uploadedImage = await uploadImage(_image!);

      if (uploadedImage == null) {
        throw Exception('Lỗi khi tải lên ảnh');
      }

      var response = await http.put(
        Uri.parse('$baseUrl/api/banners/${widget.banner.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': {
            'image_banner': uploadedImage.id,
          }
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner đã được cập nhật thành công')),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Lỗi khi cập nhật banner');
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
        title: Text('Cập Nhật Banner'),
        backgroundColor: Colors.blueGrey,
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
                  child: Image.file(_image!, fit: BoxFit.cover))
                  : Padding(
                padding: const EdgeInsets.only(left: 5,right: 5),
                    child: CachedNetworkImage(
                                    imageUrl: baseUrl + (widget.banner.imageBanner?.url ?? ''),
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                  ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: getImage,
              child: Text('Chọn Ảnh Mới', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : _showConfirmationDialog, // Hiển thị hộp thoại xác nhận
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Cập Nhật Banner', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}