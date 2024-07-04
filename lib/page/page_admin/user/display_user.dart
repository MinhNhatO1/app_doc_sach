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
  _DisplayUsersState createState() => _DisplayUsersState();
}

  

class _DisplayUsersState extends State<DisplayUser> {
  List<Users> users = [];

  // Future<List<Users>> getAll() async {
  //   try {
  //     var response = await http.get(Uri.parse("http://10.21.1.33:1337/api/profiles/"));
  //     if (response.statusCode == 200) {
  //       users.clear();
  //       final decodedData = jsonDecode(response.body);
  //       for (var u in decodedData["data"]) {
  //         try {
  //           var attributes = u['attributes'];
  //           Users user = Users(
  //             id: u['id'] is int ? u['id'] : int.tryParse(u['id'].toString()) ?? 0,
  //             fullName: attributes["fullName"]?.toString() ?? 'N/A',
  //             email: attributes["email"]?.toString() ?? 'N/A',
  //             phone: attributes["phone"]?.toString() ?? 'N/A',
  //             gender: attributes["gender"]?.toString() ?? 'N/A',
  //             address: attributes["address"]?.toString() ?? 'N/A',
  //             age: attributes["age"] != null ? DateTime.tryParse(attributes["age"].toString()) : null,
  //             avatar: attributes["image"]?.toString(),
  //           );
  //           users.add(user);
  //         } catch (e) {
  //           print('Error parsing user data: $e\nData: $u');
  //         }
  //       }
  //     } else {
  //       print('Failed to load users, status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching users: $e');
  //   }
  //   return users;
  // }

  Future<List<Users>> fetchUsers() async {
  final response = await http.get(Uri.parse('$baseUrl/api/profiles/'));

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    users = body.map((dynamic item) => Users.fromJson(item)).toList();
    return users;
  } else {
    throw Exception('Failed to load users');
  }
}
  //update
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
      body: FutureBuilder<List<Users>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: ListTile(
                    title: Text(snapshot.data![index].fullName),
                    subtitle: Text(snapshot.data![index].email),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetails(
                            users: snapshot.data![index],
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
    );
  }
}