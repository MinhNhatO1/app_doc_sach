import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/banner_model.dart';
import 'package:app_doc_sach/page/page_admin/banner/update_banner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BannerDetailPage extends StatefulWidget {
  final Banner_Model banner;

  const BannerDetailPage({Key? key, required this.banner}) : super(key: key);

  @override
  State<BannerDetailPage> createState() => _BannerDetailPageState();
}

class _BannerDetailPageState extends State<BannerDetailPage> {
  late Banner_Model? banner;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBannerDetails(widget.banner.id.toString());
  }

  Future<void> fetchBannerDetails(String bannerId) async {
    try {
      final url = Uri.parse('$baseUrl/api/banners/$bannerId?populate=image_banner');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Raw JSON response: $jsonResponse'); // Debugging line
        final Map<String, dynamic> data = jsonResponse['data'] ?? {};
        setState(() {
          try {
            banner = Banner_Model.fromJson({
              'id': data['id'],
              ...data['attributes'] ?? {},
            });
            isLoading = false;
          } catch (e, stackTrace) {
            print('Error parsing banner details: $e');
            print('Stack trace: $stackTrace');
            print('Problematic JSON: $data');
            isLoading = false;
          }
        });
      } else {
        throw Exception('Failed to load banner details: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error loading banner details: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }


  Future<void> _deleteBanner() async {
    final url = Uri.parse('$baseUrl/api/banners/${widget.banner.id}');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Quay lại trang trước và báo là đã xóa thành công

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa banner thất bại: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết banner'),
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: CachedNetworkImage(
                  imageUrl: baseUrl + (banner?.imageBanner?.url ?? ''),
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Banner ID: ${banner?.id ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Tên file ảnh: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${banner?.imageBanner?.name ?? 'N/A'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Width: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${banner?.imageBanner?.width ?? 'N/A'} pixel',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Height: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${banner?.imageBanner?.height ?? 'N/A'} pixel',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateBannerPage(banner: banner!),
                      ),
                    );
                    if (result == true) {
                      // Nếu banner mới được tạo, cập nhật danh sách
                      setState(() {
                        fetchBannerDetails(widget.banner.id.toString());
                      });
                    }
                  },
                  child: const Text('Cập nhật Banner', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        content: const Text('Bạn có chắc chắn muốn xóa banner này không?', style: TextStyle(fontSize: 16)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Hủy', style: TextStyle(fontSize: 18)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Xóa', style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    );
                    if (shouldDelete == true) {
                      await _deleteBanner();
                    }
                  },
                  child: const Text('Xóa Banner', style: TextStyle(fontSize: 16)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
