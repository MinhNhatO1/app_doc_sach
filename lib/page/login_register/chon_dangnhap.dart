import 'dart:convert';
import 'dart:developer';
import 'package:app_doc_sach/controller/auth_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_doc_sach/controller/controller.dart';
import 'package:app_doc_sach/page/login_register/dangnhap.dart';
import 'package:app_doc_sach/page/login_register/service/auth_service.dart';
import 'package:app_doc_sach/page/taikhoanwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../color/mycolor.dart';
import '../../const.dart';
import '../../provider/ui_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../view/dashboard/dashboard_screen.dart';
class ChonDangNhapWidget extends StatefulWidget {
  const ChonDangNhapWidget({super.key});

  @override
  State<ChonDangNhapWidget> createState() => _ChonDangNhapWidgetState();
}

class _ChonDangNhapWidgetState extends State<ChonDangNhapWidget> {

  void  _getStatusBarStyle(UiProvider uiProvider) {
    if (uiProvider.isDark) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,)
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ));
    }
  }

  void  _getStatusBarStyleDN() {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ));
  }
// Biến để lưu trữ SystemUiOverlayStyle trước khi thay đổi
  SystemUiOverlayStyle? _previousSystemOverlayStyle;

// Hàm để cập nhật SystemUiOverlayStyle cho màn hình gọi
  void updateSystemUiOverlayStyle(BuildContext context) {
    _previousSystemOverlayStyle = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(_previousSystemOverlayStyle!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Làm trong suốt status bar
          statusBarIconBrightness: Brightness.dark, // Màu sắc icon trên status bar
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400 ,Colors.green.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
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


                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Read Book Online',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      final authService = AuthController();
                      final jwt = await authService.signInWithGoogle(context: context);
                      if (jwt != null) {
                        // Lưu JWT và chuyển hướng người dùng
                        print('Đăng nhập thành công: $jwt');
                        // TODO: Lưu JWT vào local storage hoặc state management
                        // TODO: Chuyển hướng người dùng đến màn hình chính
                      } else {
                        print('Đăng nhập thất bại');
                        // TODO: Hiển thị thông báo lỗi cho người dùng
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Đặt màu nền là trong suốt
                      elevation: 0, // Loại bỏ hiệu ứng độ nâng
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero, // Loại bỏ padding mặc định
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:  LinearGradient(
                          colors: [MyColor.googleColor2, Colors.blue, MyColor.googleColor],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Container(
                        width: 300,
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(top:  5,left: 35,right: 5,bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                child: Image.asset('assets/icon/google.png'),
                              ),
                              const SizedBox(width: 10,),
                              const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Column(
                                  children: [
                                    Text('Đăng nhập bằng Google',style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),),
                                    /*Text('Google',style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),)*/
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Consumer <UiProvider>(
                    builder: (context,UiProvider notifier, child) {
                      return ElevatedButton(
                        onPressed: () {
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
                                return DangNhapWidget();

                              },

                            ),
                          );
                          /*
                          Future.delayed(Duration(milliseconds: 100), () {
                            _getStatusBarStyleDN();
                          });
        */
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Đặt màu nền là trong suốt
                          elevation: 0, // Loại bỏ hiệu ứng độ nâng
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero, // Loại bỏ padding mặc định
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient:  LinearGradient(
                              colors: [Colors.cyanAccent.shade700, Colors.cyanAccent.shade400],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 300,
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(top:  5,left: 35,right: 5,bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    child: Image.asset('assets/icon/email.png'),
                                  ),
                                  const SizedBox(width: 10,),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Column(
                                      children: [
                                        Text('Đăng nhập bằng Email',style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),),
                                        /*Text('Email',style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),)*/
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                  Transform.translate(
                    offset: Offset(0, 100), // Điều chỉnh vị trí dịch chuyển xuống dưới
                    child: Center(
                      child: Consumer<UiProvider>(
                        builder: (context, UiProvider notifier, child) {
                          return ElevatedButton(
                            onPressed: () {
                              // Cập nhật lại SystemUiOverlayStyle cho màn hình gọi
                              updateSystemUiOverlayStyle(context);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(11), // Điều chỉnh kích thước nút tròn bằng cách thay đổi padding
                              elevation: 5, // Tạo bóng với độ nâng là 5
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 30, // Điều chỉnh kích thước biểu tượng
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /*void signInWithGoogle({
    required BuildContext context,
  }) async {
    try {
      EasyLoading.show(
        status: 'Loading...',
        dismissOnTap: false,
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng đã hủy đăng nhập
        EasyLoading.dismiss();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? token = googleAuth.idToken;
      final String fullName = googleUser.displayName ?? '';

      // Gửi token đến Strapi API để xác thực và lưu trữ người dùng
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/callback/google'),
        body: {'access_token': token},
      );

      if (response.statusCode == 200) {
        String strapiToken = json.decode(response.body)['jwt'];

        // Gọi createProfile để tạo hồ sơ người dùng
        var userResult = await createProfile(
          token: strapiToken,
          fullName: fullName,
        );

        if (userResult.statusCode == 200) {
          var user = json.decode(userResult.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', strapiToken);
          await prefs.setString('user', json.encode(user));

          // Hiển thị thông báo đăng nhập thành công
          _succesMessageLogin(context);

          // Chờ một khoảng thời gian trước khi điều hướng
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Bắt đầu từ ngoài phải
                const end = Offset.zero; // Kết thúc ở vị trí ban đầu
                const curve = Curves.ease; // Kiểu animation
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve)); // Tạo tween
                var offsetAnimation = animation.drive(tween); // Áp dụng tween vào animation
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        } else {
          _handleError(userResult);
        }
      } else {
        _handleError(response);
      }
    } catch (error) {
      print('Error during Google login: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }
*/
  Future<dynamic> createProfile({
    required String token,
    required String fullName,
  }) async {
    var body = {
      "fullName": fullName,
    };
    var response = await http.post(
      Uri.parse('https://your-strapi-api.com/api/profile/me'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    return response;
  }

  void _succesMessageLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng nhập thành công!')),
    );
  }

  void _handleError(http.Response response) {
    print('Failed to login: ${response.body}');
    EasyLoading.showError('Đăng nhập thất bại: ${response.body}');
  }
}

