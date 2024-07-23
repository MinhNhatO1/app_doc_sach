import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_controller.dart';
import '../../provider/ui_provider.dart';
import '../page_admin/dashboard_admin.dart';

class SlashScreen extends StatefulWidget {
  const SlashScreen({super.key});

  @override
  State<SlashScreen> createState() => _SlashScreenState();
}

class _SlashScreenState extends State<SlashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isShowingOverlay = true;
  AuthController authController = Get.find();
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animationController.forward(); // Kích hoạt animation
    _startNextScreen();
    _isShowingOverlay = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    ;
    super.dispose();
  }

  void _startNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _isShowingOverlay = false;
    });

    if (!mounted) return;

    if (authController.user.value != null) {
      // Người dùng đã đăng nhập
      String? userRole = await authController.getUserRoleByEmail(authController.user.value!.email!);

      if (userRole == 'admin') {
        // Chuyển đến trang Admin
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardAdminWidget(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        // Chuyển đến trang người dùng thông thường
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashBoardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    } else {
      // Người dùng chưa đăng nhập, chuyển đến trang người dùng
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashBoardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  SystemUiOverlayStyle _getStatusBarStyle(UiProvider uiProvider) {
    if (uiProvider.isDark) {
      return SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      );
    } else {
      return SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color.fromRGBO(232, 245, 233, 1.0),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _isShowingOverlay
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                )
              : _getStatusBarStyle(
                  notifier), // Sử dụng hàm này để lấy style tương ứng
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400 ,Colors.green.shade400],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Màu sắc của bóng
                        spreadRadius: 2, // Độ lan của bóng
                        blurRadius: 5, // Độ mờ của bóng
                        offset: Offset(0, 3), // Vị trí của bóng (x, y)
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/icon/logoapp.png'),
                    radius: 45, // Đảm bảo bán kính phù hợp với kích thước của CircleAvatar
                  ),
                ),
                /*SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Read Book Online',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),*/
              ],
            ),
          ),
        );
      }),
    );
  }
}
