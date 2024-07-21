import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chon_dangnhap.dart';

class DangNhapDangKyWidget extends StatelessWidget {
  const DangNhapDangKyWidget({super.key});

  void  _getStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,)
    );
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8), // Đặt borderRadius cho Material
      child: InkWell(
        onTap: () => {
          _getStatusBarStyle(),
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                  ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0), // Bắt đầu từ bên phải
                    end: Offset.zero, // Kết thúc tại vị trí ban đầu
                  ).animate(animation),
                  child: child,
                );
              },
              pageBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  ) {
                return const ChonDangNhapWidget();
              },
            ),
          ),

        },
        borderRadius: BorderRadius.circular(8), // Đặt borderRadius cho InkWell
        child: Container(
          height: 38,
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
          child: const Center(
            child: Text(
              'Đăng nhập / Đăng ký',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
