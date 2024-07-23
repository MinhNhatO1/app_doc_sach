
import 'dart:convert';
import 'dart:io';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/controller/controller.dart';
import 'package:app_doc_sach/controller/vip_controller.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:app_doc_sach/service/local_service/local_auth_service.dart';
import 'package:app_doc_sach/service/remote_auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../page/page_admin/dashboard_admin.dart';
import '../page/page_tab_kesach/lichsu.dart';
import '../view/dashboard/dashboard_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final RxBool isLoggedIn = false.obs;
  final VipService _vipService = VipService();
  Rxn<Users> user = Rxn<Users>();
  final LocalAuthService _localAuthService = LocalAuthService();
  RxBool hasHiveData = false.obs;
  late BuildContext context;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

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
  void signInWithGoogle({required BuildContext context}) async {
    try {
      // Attempt to sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      // Make a request to your backend with the access token
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/google/callback?access_token=$accessToken'),
      );

      // Handle successful response from backend
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String jwt = data['jwt'];
        final userData = data['user'];

        // Retrieve user profile from your backend
        var userResult = await RemoteAuthService().getProfile(token: jwt);

        // Handle successful profile retrieval
        if (userResult.statusCode == 200) {
          var userProfile = usersFromJson(userResult.body);
          var userId = await getUserIdByUsername(userProfile.email!);
          // Update user profile on backend if needed
          await updateUserProfile(
            token: jwt,
            userId: userId,
          );

          // Handle user photo if available
          String? photoUrl = googleUser.photoUrl;
          if (photoUrl != null) {
            var response = await http.get(Uri.parse(photoUrl));
            if (response.statusCode == 200) {
              var tempDir = await getTemporaryDirectory();
              var filePath = '${tempDir.path}/profile_image.jpg';
              File file = File(filePath);
              await file.writeAsBytes(response.bodyBytes);

              var imageUrl = await uploadImageToStrapi(file, jwt);
              userProfile.avatar = imageUrl;
            } else {
              print('Failed to load user photo from Google');
            }
          }
          user.value = usersFromJson(userResult.body);
          // Handle successful login UI and local storage

          await _localAuthService.addToken(token: jwt);
          await _localAuthService.addUser(user: userProfile);

          final savedUser = _localAuthService.getUser();
          final savedToken = _localAuthService.getToken();

          _successMessageLogin(context);
          if (savedUser != null && savedToken != null) {
            await Future.delayed(const Duration(seconds: 2));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).pop();
            isLoggedIn.value = true;
            update();
          } else {
            print('Không thể lấy dữ liệu từ Hive');
          }
        } else if (userResult.statusCode == 404) {
          // Handle case where user profile doesn't exist, create new profile
          var createProfileResult = await RemoteAuthService().createProfileGoogle(
            token: jwt,
            fullName: googleUser.displayName ?? googleUser.email,
            photoUrl: googleUser.photoUrl ?? '',
          );
          if (createProfileResult.statusCode == 200) {
            final userProfile = usersFromJson(createProfileResult.body);

            await _localAuthService.addToken(token: jwt);
            await _localAuthService.addUser(user: userProfile);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', jwt);
            await prefs.setString('email', googleUser.email);
            _successMessageLogin(context);
            await Future.delayed(const Duration(seconds: 2));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).pop();
            isLoggedIn.value = true;
            update();
          } else {
            _handle1Error(createProfileResult);
          }
        } else {
          _handle1Error(userResult);
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
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

  Future<String?> getUserRoleByEmail(String email) async {
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
          return user['role_user'].toString(); // Return the ID as a string
        }
      }
      return null; // Return null if username is not found
    } else {
      return null; // Handle connection error or other HTTP errors here
    }
  }
  Future<String> uploadImageToStrapi(File imageFile, String jwt) async {
    try {
      // Tạo một request multipart để tải ảnh lên Strapi
      var uri = Uri.parse('$baseUrl/api/upload'); // Thay đổi URL upload của Strapi
      var request = http.MultipartRequest('POST', uri);

      // Thêm hình ảnh vào request
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'files',
        stream,
        length,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'png'), // Thay đổi nếu là file khác
      );
      request.files.add(multipartFile);

      // Thêm token vào header
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
        'Authorization': 'Bearer $jwt',
      });

      // Gửi request và chờ response
      var response = await request.send();

      // Đọc response từ Strapi và trả về URL của ảnh đã tải lên
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseJson = jsonDecode(utf8.decode(responseData));
        var imageUrl = responseJson[0]['url']; // Đổi lại key nếu API Strapi trả về dữ liệu khác
        return imageUrl;
      } else {
        print('Failed to upload image to Strapi: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error uploading image to Strapi: $e');
      return '';
    }
  }

  Future<dynamic> updateUserProfile({
    required String token,
    required String? userId,
  }) async {
    var body = {
      'role_user': "client",
      'type': "email",
    };

    var response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return response;
  }
  void _handle1Error(http.Response response) {
    print('Error: ${response.statusCode}');
    print('Response body: ${response.body}');
    // Hiển thị thông báo lỗi cho người dùng hoặc xử lý lỗi tại đây
  }

  void _succes1Message(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập thành công!')),
    );
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
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      EasyLoading.show(
        status: 'Loading...',
        dismissOnTap: false,
      );

      var result = await RemoteAuthService().signIn(
        email: email,
        password: password,
      );

      if (result.statusCode == 200) {
        String token = json.decode(result.body)['jwt'];
        var userResult = await RemoteAuthService().getProfile(token: token);
        if (userResult.statusCode == 200) {
          user.value = usersFromJson(userResult.body);
          await _localAuthService.addToken(token: token);
          await _localAuthService.addUser(user: user.value!);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('email', email);

          // Đóng EasyLoading
          EasyLoading.dismiss();

          // Hiển thị thông báo đăng nhập thành công
          _successMessageLogin(context);

          // Kiểm tra vai trò người dùng
          String? userRole = await getUserRoleByEmail(email);

          // Chờ một khoảng thời gian ngắn (2 giây) trước khi chuyển trang
          Future.delayed(const Duration(seconds: 2), () {
            if (userRole == 'admin') {
              // Chuyển đến trang admin và xóa tất cả các trang trước đó
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 800),
                  pageBuilder: (context, animation, secondaryAnimation) => const DashboardAdminWidget(), // Thay thế bằng trang admin của bạn
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                    );

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                ),
                    (route) => false, // Điều này sẽ xóa tất cả các trang trước đó
              );
            }
            else{
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 800),
                  pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0); // Bắt đầu từ trái
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                    );

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                ),
              );
            }
          });

          isLoggedIn.value = true;
          update();
        } else {
          EasyLoading.dismiss();
          _errorEmailOrPasswordMessage(context);
        }
      } else {
        EasyLoading.dismiss();
        if (result.statusCode == 401) {
          // Email hoặc mật khẩu không đúng
          _errorEmailOrPasswordMessage(context);
        } else if (result.statusCode == 404) {
          // Tài khoản không tồn tại
          _errorAccountNoExistMessage(context);
        } else {
          _errorEmailOrPasswordMessage(context);
        }
      }
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
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
                    Text("Succes", style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),

                    Spacer(),
                    Text('Tạo tài khoản thành công...',
                      style: TextStyle(
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
                      style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),),

                    Spacer(),
                    Text(
                      'Tài khoản đã tồn tại trong hệ thông, Không thể tạo tài khoản!.',
                      style: TextStyle(
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
        )
    );
  }

  _errorAccountNoExistMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            height: 105,
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
                      style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),),

                    Spacer(),
                    Text(
                      'Tài khoản không tồn tại trong hệ thông, Vui lòng tạo tài khoản để tiếp tục!.',
                      style: TextStyle(
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

  _errorEmailOrPasswordMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            height: 105,
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
                      style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),),

                    Spacer(),
                    Text(
                      'Email hoặc mật khẩu không đúng, Không thể đăng nhập!',
                      style: TextStyle(
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
  //Thong bao dang nhap thanh cong
  void _successMessageLogin(BuildContext context) {
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 80,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 81, 146, 83),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 40,),
            SizedBox(width: 15,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Success",
                  style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),),
                Spacer(),
                Text('Đăng nhập thành công',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,)
              ],
            )),
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
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    Text("Succes", style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),

                    Spacer(),
                    Text('Tạo tài khoản thành công...',
                      style: TextStyle(
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

  Future<bool> checkUserVIPStatus() async {
    if (user.value == null || user.value!.id == null) return false;

    final vip = await _vipService.checkVipStatus(user.value!.id.toString());
    return _vipService.isVipActive(vip);
  }
}