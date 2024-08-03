import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:app_doc_sach/page/page_admin/book/slideleftroutes.dart';
import 'package:app_doc_sach/page/page_admin/user/create_user.dart';
import 'package:app_doc_sach/page/page_admin/user/user_details.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../const.dart';

class DisplayUser extends StatefulWidget {
  const DisplayUser({Key? key}) : super(key: key);

  @override
  _DisplayUserState createState() => _DisplayUserState();
}

class _DisplayUserState extends State<DisplayUser> {
  List<Users> users = [];
  List<Users> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  Future<List<Users>>? _usersFuture;

  // Fetch users from the API
  Future<List<Users>> fetchUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/api/profiles/"));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      users = body.map((dynamic item) => Users.fromJson(item)).toList();
      filteredUsers = users;
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    // Ensure users are loaded once when the widget is created
    _usersFuture = fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Filter users based on the search query
  void _onSearchChanged() {
    setState(() {
      final lowerCaseQuery = _searchController.text.toLowerCase();
      filteredUsers = users.where((user) {
        final fullNameLower = user.fullName?.toLowerCase() ?? '';
        return fullNameLower.contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        elevation: 0.0,
        backgroundColor: backgroundColor,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(SlideLeftRoute(page: const CreateUser()));
              },
              icon: Icon(Icons.add),
              label: const Text('Tạo mới'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
      drawer: const SideWidgetMenu(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Users>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Không tìm thấy người dùng.', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = filteredUsers[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: user.avatar != null
                                  ? CachedNetworkImage(
                                imageUrl: baseUrl + user.avatar!,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              )
                                  : Container(
                                width: 60,
                                height: 60,
                                color: Colors.blue,
                                child: Center(
                                  child: Text(
                                    user.fullName?[0] ?? '?',
                                    style: TextStyle(fontSize: 24, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            user.fullName ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(user.email ?? 'Unknown'),

                            ],
                          ),
                          trailing: Icon(Icons.chevron_right, color: Colors.blue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserDetails(users: user),
                              ),
                            );
                          },
                        ),
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
}
