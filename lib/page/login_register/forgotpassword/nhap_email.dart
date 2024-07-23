import 'dart:convert';

import 'package:app_doc_sach/page/login_register/button/button_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../color/mycolor.dart';
import '../../../const.dart';
import '../../../state/keyboardstate.dart';
import '../form/form_dangnhap/text_form.dart';
class NhapEmail_ForgotPass extends StatefulWidget {
  const NhapEmail_ForgotPass({super.key});

  @override
  State<NhapEmail_ForgotPass> createState() => _NhapEmail_ForgotPassState();
}

class _NhapEmail_ForgotPassState extends State<NhapEmail_ForgotPass> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  final TextEditingController newPasswordController = TextEditingController();
  final FocusNode newPasswordFocusNode = FocusNode();

  final TextEditingController confirmNewPasswordController = TextEditingController();
  final FocusNode confirmNewPasswordFocusNode = FocusNode();
  bool _hasEmailText = false;
  bool _showPasswordFields = false;
  String? _userId;

  bool obscurePassword = true;
  bool obscureRePassword = true;
  final FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    newPasswordController.dispose();
    newPasswordFocusNode.dispose();
    confirmNewPasswordController.dispose();
    confirmNewPasswordFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _focusNode.unfocus(); // Ẩn bàn phím bằng cách làm mất trung tâm
  }
  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateHasEmailTextValue);
    obscurePassword = true;
    obscureRePassword = true;
  }
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Đang xử lý..."),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Thành công"),
          content: const Text("Mật khẩu đã được thay đổi thành công."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword; // Thay đổi trạng thái hiển thị/ẩn mật khẩu
    });
  }

  void toggleRePasswordVisibility() {
    setState(() {
      obscureRePassword = !obscureRePassword; // Thay đổi trạng thái hiển thị/ẩn mật khẩu
    });
  }
  void _updateHasEmailTextValue() {
    setState(() {
      _hasEmailText = _emailController.text.isNotEmpty;
    });
  }
  void clearEmail() {
    _emailController.clear(); // Xóa văn bản trong email
  }
  Future<String?> getUserIdByUsername(String email) async {
    final url = Uri.parse('$baseUrl/api/users');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data.isEmpty) {
        return null; // Return null if no users are found
      }

      for (var user in data) {
        if (user['email'] == email) {
          return user['id'].toString(); // Return the ID as a string
        }
      }
      return null; // Return null if username is not found
    } else {
      return null; // Handle connection error or other HTTP errors here
    }
  }
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
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',
      caseSensitive: false,
      multiLine: false,
    );
    return passwordRegex.hasMatch(password) && containsUpperCase(password);
  }

  bool containsUpperCase(String password) {
    for (var char in password.split('')) {
      if (char == char.toUpperCase() && char != char.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handlePasswordReset() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      _errorMessage(context, 'Vui lòng nhập đầy đủ mật khẩu mới');
      return;
    }
    if (!_isPasswordValid(newPasswordController.text)) {
      _errorMessage(context, 'Mật khẩu không hợp lệ. Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và số');
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      _errorMessage(context, 'Mật khẩu không khớp');
      return;
    }

    _showProcessingDialog();
    await Future.delayed(Duration(seconds: 2));
    _userId = await getUserIdByUsername(_emailController.text);
    if (_userId == null) {
      Navigator.of(context).pop(); // Đóng dialog xử lý
      _errorMessage(context, 'Lỗi: Không tìm thấy ID người dùng');
      return;
    }

    bool success = await resetPassword(_userId!, newPasswordController.text);
    Navigator.of(context).pop(); // Đóng dialog xử lý

    if (success) {
      await _succesMessage(context, 'Mật khẩu đã được thay đổi thành công.');
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop(); // Quay lại màn hình trước đó
    } else {
      _errorMessage(context, 'Lỗi: Không thể thay đổi mật khẩu');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85.0), // Đặt chiều cao của AppBar
        child: Padding(
          padding: const EdgeInsets.only(top: 13),
          child: AppBar(title: const Text('Quên mật khẩu',style: TextStyle(fontSize: 23,color: Colors.black,fontWeight: FontWeight.bold),),
          iconTheme: const IconThemeData(size: 30),
          ),
        ),
      ),
      body: KeyboardDismissWrapper(
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
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      height: 45,
                    ),
        
                    // ... (giữ nguyên phần code cho logo và tiêu đề)
                    if (!_showPasswordFields) ...[
                      const Text(
                        'Xác nhận Email',
                        style: TextStyle(
                          color: MyColor.primaryColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Vui lòng nhập Email và nhấn vào liên kết xác nhận để tiếp tục thay đổi mật khẩu',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormGlobal(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        text: 'Email',
                        obscure: false,
                        textInputType: TextInputType.emailAddress,
                        icon: const Icon(Icons.email_outlined),
                        suffixIcon: _hasEmailText
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade700),
                          onPressed: clearEmail,
                        )
                            : null,
                      ),
                      const SizedBox(height: 40),
                      ButtonGlobal(
                        text: 'Tiếp tục',
                        onPressed: () async {
                          // Ẩn bàn phím và loại bỏ focus khỏi tất cả các trường input
                          // Ẩn bàn phím
                          FocusManager.instance.primaryFocus?.unfocus();

                          _showProcessingDialog();
                          await Future.delayed(Duration(seconds: 2));
                          if (_emailController.text.isEmpty) {
                            _errorMessage(context, 'Vui lòng nhập email');
                          } else if (!_isEmailValid(_emailController.text)) {
                            _errorMessage(context, 'Email không hợp lệ');
                          } else {
                            var userId = await getUserIdByUsername(_emailController.text);
                            Navigator.of(context).pop(); // Đóng dialog xử lý
                            FocusScope.of(context).unfocus();
                            if (userId != null) {
                              _succesMessage(context,'Xác nhận Email thành công');
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {
                                _showPasswordFields = true;
                              });
                              // Đợi một khoảng thời gian ngắn để đảm bảo UI đã được cập nhật
                              await Future.delayed(Duration(milliseconds: 100));
        
                              // Sau đó, đặt focus vào trường mật khẩu mới (nếu cần)
                              FocusScope.of(context).requestFocus(newPasswordFocusNode);
                            } else {
                              _errorMessage(context, 'Email không tồn tại trong hệ thống');
                            }
                          }
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Nhập mật khẩu mới',
                        style: TextStyle(
                          color: MyColor.primaryColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormGlobal(
                        controller: newPasswordController,
                        focusNode: newPasswordFocusNode,
                        obscure: obscurePassword,
                        text: 'Mật khẩu mới',
                        textInputType: TextInputType.visiblePassword,
                        icon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,color: Colors.grey.shade700,
                          ),
                          onPressed: togglePasswordVisibility, // Gọi hàm togglePasswordVisibility khi nhấn vào IconButton
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormGlobal(
                        controller: confirmNewPasswordController,
                        focusNode: confirmNewPasswordFocusNode,
                        text: 'Xác nhận mật khẩu mới',
                        textInputType: TextInputType.visiblePassword,
                        obscure: obscureRePassword,
                        icon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                              obscureRePassword ? Icons.visibility_off : Icons.visibility,color: Colors.grey.shade700
                          ),
                          onPressed: toggleRePasswordVisibility, // Gọi hàm togglePasswordVisibility khi nhấn vào IconButton
                        ),
                      ),
                      const SizedBox(height: 40),
                      ButtonGlobal(
                        text: 'Xác nhận thay đổi',
                        onPressed: _handlePasswordReset
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_succesMessage(BuildContext context,String textMess){
  return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          height: 80,
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 81, 146, 83),
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,color: Colors.white,size: 40,),

              const SizedBox(width: 15,),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Succes", style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),

                  const Spacer(),
                  Text(textMess,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,)
                ],
              ))
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(milliseconds: 1500), // Thời gian hiển thị thông báo
        animation: CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeInOutCubic,
        ),
      )
  );
}
_errorMessage(BuildContext context, String textMess) {
  return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          height: 105,
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 179, 89, 89),
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child:  Row(
            children: [
             const Icon(Icons.error_outline, color: Colors.white, size: 40,),

              const SizedBox(width: 15,),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Opps. An Error Occured",
                    style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),),

                  const Spacer(),
                  Text(
                    textMess,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,)
                ],
              ))
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      )
  );
}