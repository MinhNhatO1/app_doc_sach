import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../route/app_route.dart';
import '../view/dashboard/dashboard_screen.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  AuthController authController = Get.find();

  void restartApp() {
    authController.signOut();
    Get.offAll(
          () => const DashBoardScreen(),
      routeName: AppRoute.dashboard,
      transition: Transition.rightToLeft, // Hiệu ứng chuyển đổi từ phải qua trái
      duration: const Duration(milliseconds: 300), // Thời gian của hiệu ứng chuyển đổi
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Text(
          'Đăng Xuất',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Bạn có chắc chắn muốn đăng xuất?',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: const Text(
              'Đăng Xuất',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
            ),
            onPressed: () {
              Get.back(); // Đóng hộp thoại trước
              restartApp(); // Sau đó điều hướng đến màn hình khác
            },
          ),
        ],
      );
    },
  );
}
