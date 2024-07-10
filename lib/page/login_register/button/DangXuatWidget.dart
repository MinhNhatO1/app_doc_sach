import 'dart:async';
import 'dart:convert';
import 'package:app_doc_sach/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import '../../../controller/auth_controller.dart';
import '../../../model/user_model.dart';
import '../../../service/remote_auth_service.dart';

class DangXuatWidget extends StatefulWidget {
  const DangXuatWidget({super.key});

  @override
  State<DangXuatWidget> createState() => _DangXuatWidgetState();
}

class _DangXuatWidgetState extends State<DangXuatWidget> {
  Users? users;
  Timer? _timer;

  Future<Users> fetchUserByEmail(String email, String token) async {
    try {
      var userResult = await RemoteAuthService().getUserByEmail(email: email, token: token);
      if (userResult.statusCode == 200) {
        var userData = json.decode(userResult.body);
        print('User data from API: $userData');
        return Users.fromJson(userData);
      } else {
        throw Exception('Error fetching user by email: ${userResult.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> initializeData() async {
    AuthController authController = Get.find();
    String userEmail = authController.user.value?.email ?? '';
    String? token = authController.getToken();

    try {
      var userResult = await fetchUserByEmail(userEmail, token!);
      setState(() {
        users = userResult;
      });
    } catch (e) {
      print('Error initializing data: $e');
      // Handle error appropriately, such as showing an error message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();

    // Schedule the timer to fetch data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      initializeData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đăng xuất"),
          content: const Text("Bạn có chắc muốn đăng xuất?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Đồng ý"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                AuthController authController = Get.find();
                authController.signOut();
                setState(() {
                  users = null;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          if (users != null) ...[
            Text(
              users!.fullName ?? '',
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(
            height: 10,
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _showLogoutConfirmationDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 35,
                width: 190,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Đăng xuất',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
