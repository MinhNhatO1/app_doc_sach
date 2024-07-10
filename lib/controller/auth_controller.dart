
import 'dart:convert';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/controller/controller.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:app_doc_sach/service/local_service/local_auth_service.dart';
import 'package:app_doc_sach/service/remote_auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../page/page_tab_kesach/lichsu.dart';
import '../view/dashboard/dashboard_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final RxBool isLoggedIn = false.obs;
  Rxn<Users> user = Rxn<Users>();
  final LocalAuthService _localAuthService = LocalAuthService();
  RxBool hasHiveData = false.obs;
  late BuildContext context;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  Future<String?> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      // Gửi accessToken đến backend để đăng nhập và lấy JWT
      final response = await http.post(
        Uri.parse('$baseUrl/api/connect/google/callback'), // Thay YOUR_BACKEND_LOGIN_ENDPOINT bằng endpoint của bạn
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'accessToken': accessToken!,
        }),
      );

      if (response.statusCode == 200) {
        // Trả về JWT từ backend
        final jwt = jsonDecode(response.body)['token'];
        var userResult = await RemoteAuthService().getUserByEmail(email: googleUser.email, token: jwt);
        if (userResult.statusCode == 200) {
          user.value = usersFromJson(userResult.body);
          await _saveUserInfoAndNavigate(
            context: context,
            token: jwt,
            email: googleUser.email,
            user: user.value!,
          );
        } else if (userResult.statusCode == 404) {
          // Người dùng chưa có profile, tạo mới
          var createProfileResult = await RemoteAuthService().createProfile(
            token: jwt,
            fullName: googleUser.displayName ?? googleUser.email,
          );
          if (createProfileResult.statusCode == 200) {
            user.value = usersFromJson(createProfileResult.body);
            await _saveUserInfoAndNavigate(
              context: context,
              token: jwt,
              email: googleUser.email,
              user: user.value!,
            );
          } else {
            // Xử lý lỗi khi tạo profile
            _handleError(createProfileResult);
          }
        } else {
          // Xử lý lỗi từ backend khi lấy profile
          _handleError(userResult);
        }
      } else {
        // Xử lý lỗi từ backend khi đăng nhập
        return null;
      }
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
    return null;
  }

  Future<void> _saveUserInfoAndNavigate({
    required BuildContext context,
    required String token,
    required String email,
    required Users user,
  }) async {
    await _localAuthService.addToken(token: token);
    await _localAuthService.addUser(user: user);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
    _succesMessage(context);
    await Future.delayed(const Duration(seconds: 2));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
    isLoggedIn.value = true;
    update();
  }

  @override
  void onInit() async {
   await  _localAuthService.init();
  await _checkHiveData();
    if (_localAuthService.getUser() != null && _localAuthService.getToken() != null) {
      user.value = _localAuthService.getUser(); // Lấy thông tin tài khoản từ LocalAuthService
    }
    super.onInit();
  }
 Future<void> _checkHiveData() async {
    // Kiểm tra xem "box" đã được mở trước đó chưa
    if (!Hive.isBoxOpen('token')) {
      // Nếu chưa mở, thì mở "box"
      await Hive.openBox<String>('token');
    }

    // Sử dụng hộp đã mở để kiểm tra dữ liệu
    final box = Hive.box<String>('token');
    print('Got object store box in database token');
    final data = box.get('token');
    print('Box found!');
    // Kiểm tra xem dữ liệu có giá trị không
    if (data != null) {
      // Có dữ liệu trong Hive
      hasHiveData.value = true;
      print('Data found!');
    } else {
      // Không có dữ liệu trong Hive
      hasHiveData.value = false;
      print('No data found!');
    }
  }

  void signUp({
    required BuildContext context, // Add context as a required parameter
    required String fullName,
    required String email ,
    required String password}) async{
    try{
      EasyLoading.show(
        status: 'Loading...',
        dismissOnTap: false
      );

      var result = await RemoteAuthService().signUp(
        email: email,
        password: password,
      );

      if(result.statusCode == 200){
        EasyLoading.dismiss();
        String token = json.decode(result.body)['jwt'];
        var userResult = await RemoteAuthService().createProfile(
            token: token,
            fullName: email,);
        if(userResult.statusCode == 200){
          user.value = usersFromJson(userResult.body);
          await _localAuthService.addToken(token: token);
          await _localAuthService.addUser(user: user.value!);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('email', email);
          _succesMessage(context);
          // Chờ 2 giây trước khi chuyển đến trang chủ
          await Future.delayed(const Duration(seconds: 2));
          // Ẩn thông báo thành công
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500), // Độ dài của animation
              pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(), // Builder cho trang chủ
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Bắt đầu từ ngoài phải
                const end = Offset.zero; // Kết thúc ở vị trí ban đầu
                const curve = Curves.ease; // Kiểu animation
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve)); // Tạo tween
                var offsetAnimation = animation.drive(tween); // Áp dụng tween vào animation
                return SlideTransition(
                  position: offsetAnimation, // Sử dụng SlideTransition với animation đã thiết lập
                  child: child,
                );
              },
            ),
          );
          isLoggedIn.value = true;
          update();
        }
        else{
          _handleError(result);
        }
      }
      else if(result.statusCode == 400){
        _errorAccountExistMessage(context);
      }
      else{
        _handleError(result);
    }
    }finally{
      EasyLoading.dismiss();
    }
  }

  void signIn({
    required BuildContext context, // Add context as a required parameter
    required String email ,
    required String password}) async{
    try{
      EasyLoading.show(
          status: 'Loading...',
          dismissOnTap: false
      );

      var result = await RemoteAuthService().signIn(
        email: email,
        password: password,
      );

      if(result.statusCode == 200){
        EasyLoading.dismiss();
        String token = json.decode(result.body)['jwt'];
        var userResult = await RemoteAuthService().getProfile(token: token,);
        if(userResult.statusCode == 200){
          user.value = usersFromJson(userResult.body);
          await _localAuthService.addToken(token: token);
          await _localAuthService.addUser(user: user.value!);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('email', email);
          // Save login state
         /* await saveLoginState(token);
*/
          _succesMessageLogin(context);
          // Chờ một khoảng thời gian trước khi điều hướng
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              // Độ dài của animation
              pageBuilder: (context, animation,
                  secondaryAnimation) => const DashBoardScreen(),
              // Builder cho trang chủ
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Bắt đầu từ ngoài phải
                const end = Offset.zero; // Kết thúc ở vị trí ban đầu
                const curve = Curves.ease; // Kiểu animation
                var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve)); // Tạo tween
                var offsetAnimation = animation.drive(
                    tween); // Áp dụng tween vào animation
                return SlideTransition(
                  position: offsetAnimation,
                  // Sử dụng SlideTransition với animation đã thiết lập
                  child: child,
                );
              },
            ),
          );
          isLoggedIn.value = true;
          update();
        }
        else{
          _handleError(userResult);
        }
      }
      else{
        _handleError(result);
      }
    }finally{
      EasyLoading.dismiss();
    }
  }
  String? getToken() {
    return _localAuthService.getToken();
  }

  void signOut() async {
    try {
      // Đăng xuất Google
      await _googleSignIn.signOut();
    } catch (error) {
      print('Error signing out from Google: $error');
    }
    user.value = null;
    await _localAuthService.clear();
    isLoggedIn.value = false;
    authController.update();
  }

  void _handleError(dynamic result) {
    print('Error response: ${result.body}');
    EasyLoading.showError('Đăng ký không thành công. Vui lòng thử lại sau.');
  }
  _succesMessage(BuildContext context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            height: 80,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 81, 146, 83),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle,color: Colors.white,size: 40,),

                SizedBox(width: 15,),

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Succes", style: TextStyle(fontSize: 15,color: Colors.white),),

                    Spacer(),
                    Text('Tạo tài khoản thành công...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
        )
    );
  }

  // Thông báo tài khoản ton tai trong he thong
  _errorAccountExistMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            height: 90,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 179, 89, 89),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 40,),

                SizedBox(width: 15,),

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Opps. An Error Occured",
                      style: TextStyle(fontSize: 15, color: Colors.white),),

                    Spacer(),
                    Text(
                      'Tài khoản đã tồn tại trong hệ thông, Không thể tạo tài khoản!.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
        )
    );
  }

  //Thong bao dang nhap thanh cong
  _succesMessageLogin(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            height: 80,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 81, 146, 83),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 40,),

                SizedBox(width: 15,),

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Succes",
                      style: TextStyle(fontSize: 15, color: Colors.white),),

                    Spacer(),
                    Text('Đăng nhập thành công',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
        )
    );
  }

  // Function to save login state
  Future<void> saveLoginState(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }



  _succesUpdateMessage(BuildContext context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            height: 80,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 81, 146, 83),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle,color: Colors.white,size: 40,),

                SizedBox(width: 15,),

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Succes", style: TextStyle(fontSize: 15,color: Colors.white),),

                    Spacer(),
                    Text('Tạo tài khoản thành công...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
        )
    );
  }

  Future<void> UpdateProfile({
    required BuildContext context, // Add context as a parameter
    required String fullName,
    required String phone,
    required String address,
    required DateTime age,
    required String gender,
    required String email,
  }) async {
    try {
      EasyLoading.show(
        status: 'Updating profile...',
        dismissOnTap: false,
      );

      // Lấy token từ local service
      String? token = _localAuthService.getToken();
      if (token == null) {
        throw Exception("Token is not available");
      }

      // Tìm ID của người dùng bằng email
      var userId = await RemoteAuthService().getUserIdByEmail(email, token);
      if (userId == null) {
        throw Exception("User not found");
      }

      // Gọi hàm updateProfile từ RemoteAuthService
      var response = await RemoteAuthService().updateProfile(
        token: token,
        userId: userId,
        fullName: fullName,
        phone: phone,
        address: address,
        age: age, // Đảm bảo age là kiểu DateTime
        gender: gender,
      );

      // Kiểm tra kết quả trả về từ response
      if (response.statusCode == 200) {
        print('Profile updated successfully');
        // Show success dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Success",
          desc: "Your profile has been updated successfully.",
          btnOkOnPress: () {},
        ).show();
      } else {
        print("Failed to update profile: ${response.statusCode} ${response.reasonPhrase}");
        // Show failure dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Error",
          desc: "Failed to update profile. Please try again.",
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      // Xử lý các loại lỗi khác nhau
      if (e is TypeError) {
        // Xử lý lỗi khi có sự không phù hợp kiểu dữ liệu
        print("Type error occurred: $e");
      } else {
        print("Exception occurred: $e");
      }
      // Show exception dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Error",
        desc: "An error occurred: $e",
        btnOkOnPress: () {},
      ).show();
    } finally {
      EasyLoading.dismiss();
    }
  }
}