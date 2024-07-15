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


  Future<List<Users>> fetchUsers() async {
   //Từ khóa await được sử dụng để chờ đợi cho đến khi yêu cầu HTTP hoàn thành và trả về kết quả. 
  final response = await http.get(Uri.parse("$baseUrl/api/profiles/"));

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);//Giải mã nội dung phản hồi (dạng JSON) thành một đối tượng Dart.
    //body.map: Áp dụng hàm map lên mỗi phần tử của body.
    //
    //chuyển đổi json thành đối tượng
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
      drawer: const SideWidgetMenu(), // Assuming you have a SideWidgetMenu
      body: FutureBuilder<List<Users>>(
        //là hàm trả về Future<List<Users>>
        future: fetchUsers(),
        //snapshot (trạng thái hiện tại của Future).
        builder: (context, snapshot) {
          //ktra nếu đang ở trạng thái chờ đợi
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
                //Widget này cho phép các phần tử trong danh sách có thể tương tác (như bắt sự kiện chạm).
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