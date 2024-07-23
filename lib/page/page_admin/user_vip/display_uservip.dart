import 'dart:async';
import 'dart:convert';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/page/page_admin/user_vip/coutdowntime.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../const/constant.dart';
import '../../../model/vip_model.dart';
import '../../../service/remote_auth_service.dart';
import '../../../widgets/side_widget_menu.dart';
import 'package:app_doc_sach/model/user_model.dart'; // Import model
import 'package:intl/intl.dart';
class DisPlayUserVip extends StatefulWidget {
  const DisPlayUserVip({super.key});

  @override
  State<DisPlayUserVip> createState() => _DisPlayUserVipState();
}

class _DisPlayUserVipState extends State<DisPlayUserVip> {
  late Future<List<Vip>> _futureVipList;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _futureVipList = fetchVipList();
  }
  @override
  void dispose() {
    super.dispose();
  }
  Future<List<Vip>> fetchVipList({String? searchQuery}) async {
    try {
      String url = '$baseUrl/api/vips?populate[profile][publicationState]=preview&publicationState=preview';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += '&filters[profile][fullName][\$containsi]=$searchQuery';
      }
      final response = await http.get(Uri.parse(url));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          List<dynamic> vipList = jsonResponse['data'];
          return vipList.map((data) {
            try {
              // Kết hợp id và attributes vào một Map
              Map<String, dynamic> vipData = {
                'id': data['id'],
                ...data['attributes'],
              };
              // Nếu profile tồn tại, thêm nó vào vipData
              if (data['attributes']['profile'] != null) {
                vipData['profile'] = data['attributes']['profile']['data'];
              }
              return Vip.fromJson(vipData);
            } catch (e) {
              print('Error parsing Vip: $e');
              print('Problematic data: $data');
              return null;
            }
          }).whereType<Vip>().toList();
        } else {
          throw Exception('Invalid JSON structure: ${jsonResponse.toString()}');
        }
      } else {
        throw Exception('Failed to load VIP list. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchVipList: $e');
      rethrow;
    }
  }

  Future<Users> fetchUserByID(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/profiles/$id'));
      print('User API response: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        if (userData['data'] != null) {
          return Users.fromJson(userData['data']['attributes']);
        } else {
          throw Exception('User data structure is not as expected');
        }
      } else {
        throw Exception('Failed to load user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserByID: $e');
      rethrow;
    }
  }


  String getTimeLeft(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    if (difference.isNegative) {
      return 'Đã hết hạn';
    }
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text;
      _futureVipList = fetchVipList(searchQuery: _searchQuery);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách tài khoản VIP', style: TextStyle(color: Colors.white)),
        elevation: 0.0,
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: const SideWidgetMenu(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm tài khoản theo tên...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: Text('Tìm kiếm'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Vip>>(
              future: _futureVipList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có tài khoản VIP', style: TextStyle(fontSize: 18)));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vip = snapshot.data![index];
                      final profile = vip.profile;
                      return FutureBuilder<Users>(
                        future: fetchUserByID(profile!.id.toString()),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return _buildSkeletonCard();
                          } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                            return _buildErrorCard(userSnapshot.error);
                          } else {
                            final user = userSnapshot.data!;
                            return _buildUserCard(user, vip);
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundColor: Colors.grey[300]),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 150, color: Colors.grey[300]),
                  SizedBox(height: 8),
                  Container(height: 16, width: 100, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(dynamic error) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Lỗi: $error', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildUserCard(Users user, Vip vip) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    String formatDate(DateTime date) => dateFormat.format(date);
    String formatTime(DateTime date) => timeFormat.format(date);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage('$baseUrl${user.avatar}')
                    : const AssetImage('assets/icon/image_default.png') as ImageProvider,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'Không có tên',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bắt đầu:',
                          style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              formatDate(vip.dayStart),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 20, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              formatTime(vip.dayStart),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kết thúc:',
                          style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              formatDate(vip.dayEnd),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 20, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              formatTime(vip.dayEnd),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    CountdownTimer(endDate: vip.dayEnd),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
