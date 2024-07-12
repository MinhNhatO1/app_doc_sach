import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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

  void _startNextScreen() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isShowingOverlay = false; // Đặt giá trị _isShowingOverlay là false
      });
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashBoardScreen() /*DashboardAdminWidget()*/,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
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
                colors: [MyColor.primaryColor, MyColor.secondaryColor],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/icon/logoapp.png'),
                  width: 100,
                  height: 100,
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
