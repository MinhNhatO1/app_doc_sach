import 'dart:convert';
import 'dart:math';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/page/login_register/button/button_global.dart';
import 'package:app_doc_sach/page/login_register/dangky.dart';
import 'package:app_doc_sach/page/login_register/forgotpassword/nhap_email.dart';
import 'package:app_doc_sach/page/login_register/form/form_dangnhap/text_form.dart';
import 'package:app_doc_sach/page/login_register/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:http/http.dart' as http;
import '../../controller/auth_controller.dart';
import '../../state/keyboardstate.dart';
import '../../view/dashboard/dashboard_screen.dart';

class DangNhapWidget extends StatefulWidget {
  const DangNhapWidget({super.key});

  @override
  State<DangNhapWidget> createState() => _DangNhapWidgetState();
}

class _DangNhapWidgetState extends State<DangNhapWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  // Khởi tạo một đối tượng ProgressDialog
  late ProgressDialog progressDialog;

//thay đổi kiểu dáng của thanh trạng thái để phù hợp với giao diện của ứng dụng
  void _getStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }
/*
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String username = '';
        return AlertDialog(
          title: Text('Quên mật khẩu'),
          content: TextField(
            controller: emailController,
            onChanged: (value) {
              username = value;
            },
            decoration: InputDecoration(hintText: "Nhập Email đăng nhập"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tiếp tục'),
              onPressed: () async {
                var userId = await getUserIdByUsername(username);
                if (userId != null) {
                  Navigator.of(context).pop();
                  _showResetPasswordDialog(username, userId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email không tồn tại trong hệ thống')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _showResetPasswordDialog(String username, String userId) {
    String newPassword = '';
    String confirmPassword = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đặt lại mật khẩu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: newPasswordController,
                onChanged: (value) {
                  newPassword = value;
                },
                obscureText: true,
                decoration: InputDecoration(hintText: "Mật khẩu mới"),
              ),
              TextField(
                controller: confirmNewPasswordController,
                onChanged: (value) {
                  confirmPassword = value;
                },
                obscureText: true,
                decoration: InputDecoration(hintText: "Xác nhận mật khẩu mới"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () async {
                if (newPassword == confirmPassword) {
                  var success = await resetPassword(userId, newPassword);
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mật khẩu đã được cập nhật')),
                    );
                    emailController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật mật khẩu thất bại')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu không khớp')),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Xác nhận'),
              onPressed: () async {
                if (newPassword == confirmPassword) {
                  var success = await resetPassword(userId, newPassword);
                  // Thực hiện đặt lại mật khẩu (cập nhật trong database hoặc hiển thị thông báo thành công)
                  print('Reset password for user: $username');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu đã được cập nhật')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu không khớp')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
*/
  Future<bool> resetPassword(String userId, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/users/$userId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  bool _hasEmailText = false;
  bool obscurePassword = true;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    /*newPasswordController.dispose();
    confirmNewPasswordController.dispose();*/
    super.dispose();
  }

  // Initialize Firebase in initState()
  @override
  void initState() {
    super.initState();
    initializeFirebase();
    progressDialog =
        ProgressDialog(context); // Khởi tạo ProgressDialog với context
    progressDialog.style(
        message: 'Đang đăng nhập...'); // Thiết lập thông điệp hiển thị

    emailController.addListener(_updateHasEmailTextValue);
    obscurePassword = true;
  }

  void clearEmail() {
    emailController.clear(); // Xóa văn bản trong email
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword =
          !obscurePassword; // Thay đổi trạng thái hiển thị/ẩn mật khẩu
    });
  }

  // Function to initialize Firebase
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  void _updateHasEmailTextValue() {
    setState(() {
      _hasEmailText = emailController.text.isNotEmpty;
    });
  }

  final AuthController authController = AuthController.instance;
  @override
  Widget build(BuildContext context) {
    //WillPopScope là một widget trong Flutter cho phép bạn can thiệp và
    ///xử lý sự kiện khi người dùng nhấn nút "back" (trở về) trên thiết bị.
    return Scaffold(
      body:  KeyboardDismissWrapper(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Làm trong suốt status bar
            statusBarIconBrightness: Brightness.dark, // Màu sắc icon trên status bar
          ),
          child: SafeArea(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 300), () {
                                _getStatusBarStyle();
                              });

                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back_sharp,
                              size: 30,
                              color: Colors.black,
                            )),
                        Container(
                          alignment: Alignment.center,
                          child: Container(
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
                        ),

                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: MyColor.primaryColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),
                        // Email Input
                        TextFormGlobal(
                          controller: emailController,
                          text: 'Email',
                          obscure: false,
                          textInputType: TextInputType.emailAddress,
                          icon: const Icon(Icons.email_outlined),
                          suffixIcon: _hasEmailText
                              ? IconButton(
                            icon:
                            Icon(Icons.clear, color: Colors.grey.shade700),
                            onPressed: clearEmail,
                          )
                              : null,
                        ),

                        const SizedBox(
                          height: 15,
                        ),
                        // Password Input
                        TextFormGlobal(
                          controller: passwordController,
                          text: 'Password',
                          obscure: obscurePassword,
                          textInputType: TextInputType.text,
                          icon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade700,
                            ),
                            onPressed:
                            togglePasswordVisibility, // Gọi hàm togglePasswordVisibility khi nhấn vào IconButton
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  /*_showForgotPasswordDialog();*/
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const NhapEmail_ForgotPass(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                      transitionDuration: Duration(milliseconds: 300), // Thời gian chuyển đổi
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Quên mật khẩu ?',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ButtonGlobal(
                          text: 'Đăng nhập',
                          onPressed: () {
                            _login();
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 50,
                            color: Colors.grey.shade50,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Bạn chưa có tài khoản?',
                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration:
                                        const Duration(milliseconds: 300),
                                        transitionsBuilder: (
                                            BuildContext context,
                                            Animation<double> animation,
                                            Animation<double> secondaryAnimation,
                                            Widget child,
                                            ) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              // Bắt đầu từ bên phải
                                              end: Offset
                                                  .zero, // Kết thúc tại vị trí ban đầu
                                            ).animate(animation),
                                            child: child,
                                          );
                                        },
                                        pageBuilder: (
                                            BuildContext context,
                                            Animation<double> animation,
                                            Animation<double> secondaryAnimation,
                                            ) {
                                          return const DangKyWidget();
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                        color: MyColor.primaryColor, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) // Thêm khoảng cách giữa form và bottom navigation bar
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // Thông báo yêu cầu điền thông tin đầy đủ
  _errorNullMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 80,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 179, 89, 89),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: const Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Opps. An Error Occured",
                  style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Vui lòng điền đầy đủ thông tin.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ))
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }

  // Thông báo Email không hợp lệ
  _errorEmailMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 90,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 179, 89, 89),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: const Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Opps. An Error Occured",
                  style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Email không hợp lệ. Vui lòng kiểm tra lại.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ))
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }

// Thông báo Mật khẩu không hợp lệ
  _errorMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 110,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 179, 89, 89),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: const Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Opps. An Error Occured",
                  style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Tài khoản hoặc mật khẩu không đúng,'
                  ' Không thể Đăng nhập!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ))
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }

  bool _isEmailValid(String email) {
    // Biểu thức chính quy để kiểm tra email
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  _login() async {
    // Ẩn bàn phím
    FocusManager.instance.primaryFocus?.unfocus();
    // Kiểm tra trường nhập liệu không được trống
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorNullMessage(context);
      return;
    }
    // Kiểm tra email có hợp lệ không
    if (!_isEmailValid(emailController.text)) {
      _errorEmailMessage(context);
      return;
    }
    try {
      authController.signIn(email: emailController.text, password: passwordController.text, context: context);
    }on FirebaseAuthException catch (e) {
      progressDialog.hide();
      if (e.code == 'user-not-found') {
        _errorMessage(context);
      } else if (e.code == 'wrong-password') {
        _errorMessage(context);
      } else {
        _errorMessage(context);
      }
    } catch (e) {
      /*progressDialog.hide();*/
      _errorMessage(context);
    }
  }
}


