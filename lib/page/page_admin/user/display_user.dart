import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:app_doc_sach/page/page_admin/book/slideleftroutes.dart';
import 'package:app_doc_sach/page/page_admin/user/create_user.dart';
import 'package:app_doc_sach/page/page_admin/user/user_details.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
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
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(SlideLeftRoute(page: const CreateUser()));
              },
              child: const Text('Tạo mới'),
            ),
          )
        ],
      ),
      drawer: const SideWidgetMenu(),
      body: Padding(
        padding: const EdgeInsets.only(right: 13, left: 13, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm người dùng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Users>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không tìm thấy người dùng.'));
                  } else {
                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: ListTile(
                            title: Text(filteredUsers[index].fullName ?? 'Unknown'),
                            subtitle: Text(filteredUsers[index].email ?? 'Unknown'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserDetails(
                                    users: filteredUsers[index],
                                  ),
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
      ),
    );
  }
}
