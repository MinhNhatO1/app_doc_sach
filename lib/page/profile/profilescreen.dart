import 'dart:convert';
import 'dart:io';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/controller/auth_controller.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../service/remote_auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File;
import 'package:http_parser/http_parser.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late Future<Users> futureUser;
  String? selectedGender;
  File? _imageFile;
  Future<Users> fetchUserByEmail(String email, String token) async {
    try {
      var userResult = await RemoteAuthService().getUserByEmail(email: email, token: token);
      if (userResult.statusCode == 200) {
        var userData = json.decode(userResult.body);
        print('User data from API: $userData'); // In ra dữ liệu nhận được từ API
        return Users.fromJson(userData); // Assuming Users.fromJson handles potential parsing errors
      } else {
        throw Exception('Error fetching user by email: ${userResult.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    _ageController.text = formatDate(DateTime.now());
  }

// Hàm để khởi tạo giá trị ban đầu cho selectedGender
  void initializeData() async {
    AuthController authController = Get.find();
    String userEmail = authController.user.value?.email ?? '';
    String? token = authController.getToken();

    // Gọi fetchUserByEmail để lấy dữ liệu người dùng
    futureUser = fetchUserByEmail(userEmail, token!);

    // Sau khi lấy được dữ liệu người dùng, khởi tạo selectedGender dựa trên giới tính của người dùng
    futureUser.then((user) {
      setState(() {
        if (user.gender == 'Nam') {
          selectedGender = 'Nam';
        } else if (user.gender == 'Nữ') {
          selectedGender = 'Nữ';
        } else if (user.gender == 'Khác') {
          selectedGender = 'Khác';
        }
        else{
          selectedGender = '';
        }
      });
      _ageController.text = formatDate(user.age!);
    }).catchError((error) {
      print('Error initializing data: $error');
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return DateFormat('dd-MM-yyyy').format(date);
  }
/*
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        await _uploadImage(_imageFile!);
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Please grant access to photos.')),
      );

      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }
*/
  Future<String> uploadImage(File image) async {
    AuthController authController = Get.find();
    String token = authController.getToken()!;
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload/'));

    var stream = http.ByteStream(image.openRead().cast());
    var length = await image.length();

    if (length == 0) {
      throw Exception('File is empty');
    }

    var multipartFile = http.MultipartFile(
      'files',
      stream,
      length,
      filename: image.path.split('/').last,
      contentType: MediaType('image', 'png'),
    );

    request.files.add(multipartFile);
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      'Authorization': 'Bearer $token',
    });

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var result = String.fromCharCodes(responseData);
      var jsonResponse = json.decode(result);
      return jsonResponse[0]['url']; // Assuming 'url' is the key where image URL is returned
    } else {
      var responseData = await response.stream.toBytes();
      var result = String.fromCharCodes(responseData);
      throw Exception('Failed to upload image. Status code: ${response.statusCode}. Response: $result');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      try {
        AuthController authController = Get.find();
        var imageUrl = await uploadImage(_imageFile!);

        // Update profile with the image URL
        String userId = authController.user.value?.id.toString() ?? '';
        var profileUpdateResponse = await updateProfileImage(userId, imageUrl);

        // Handle response from profile update API
        if (profileUpdateResponse.statusCode == 200) {
          // Profile image updated successfully
          print('Profile image updated successfully.');
        } else {
          throw Exception('Failed to update profile image. Status code: ${profileUpdateResponse.statusCode}');
        }

      } catch (e) {
        print('Error uploading image or updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image or updating profile: $e')),
        );
      }
    } else {
      print('No image selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<http.Response> updateProfileImage(String userId, String imageUrl) async {
    AuthController authController = Get.find();
    String token = authController.getToken()!;

    var profileUpdateUrl = '$baseUrl/api/profiles/$userId'; // Replace with your API endpoint to update profile

    var body = json.encode({
      'data': {
        'image': imageUrl
      }

    });

    var response = await http.put(Uri.parse(profileUpdateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body);

    return response;
  }
  String date ='';
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Thông tin tài khoản",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Thêm dòng này
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: FutureBuilder<Users>(
          future: futureUser,
          builder: (BuildContext context, AsyncSnapshot<Users> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var user = snapshot.data!;
              _nameController.text = user.fullName;
              _phoneController.text = user.phone;
              _addressController.text = user.address;
              _emailController.text = user.email;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // -- IMAGE with ICON
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: _imageFile != null
                                  ? Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              )
                                  :  user.avatar != null
                                  ? Image.network(
                                baseUrl + user.avatar!,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                'assets/icon/noimage.png',  // Nếu không có avatar, sử dụng ảnh mặc định
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap:  _pickImage,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: MyColor.primaryColor,
                                ),
                                child: const Icon(Icons.camera, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // -- Form Fields
                    Form(
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Tên tài khoản',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: MyColor.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                              child: TextFormField(
                                controller: _nameController,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: MyColor.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                              child: TextFormField(
                                controller: _emailController,
                                enabled: false,
                                style: TextStyle(fontSize: 12,color:  Colors.black),
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Số điện thoại',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: MyColor.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                              child: TextFormField(
                                controller: _phoneController,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Giới tính',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Nam',
                                      groupValue: selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                          // Cập nhật giá trị cho user.gender tại đây nếu cần
                                        });
                                      },
                                    ),
                                    const Text('Nam'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Nữ',
                                      groupValue: selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                          // Cập nhật giá trị cho user.gender tại đây nếu cần
                                        });
                                      },
                                    ),
                                    const Text('Nữ'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Khác',
                                      groupValue: selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGender = value;
                                          // Cập nhật giá trị cho user.gender tại đây nếu cần
                                        });
                                      },
                                    ),
                                    const Text('Khác'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Địa chỉ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: MyColor.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                              child: TextFormField(
                                controller: _addressController,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Ngày sinh',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: MyColor.primaryColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _ageController,
                                        style: TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            _ageController.text = formatDate(pickedDate);
                                          });
                                        } else {
                                          print('No date selected');
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_today_outlined),
                                    ),
                                  ],
                                )

                            ),
                          ),

                          const SizedBox(height: 20),
                          // -- Form Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.topSlide,
                                  showCloseIcon: true,
                                  title: "Xác nhận",
                                  desc: "Bạn có chắc muốn lưu thay đổi?",
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () {
                                    // Proceed with updating the profile if the user confirms
                                    String ageString = _ageController.text.trim();
                                    DateTime? parsedAge = DateFormat('dd-MM-yyyy').parse(ageString);
                                    AuthController.instance.UpdateProfile(
                                      context: context,
                                      fullName: _nameController.text,
                                      phone: _phoneController.text,
                                      address: _addressController.text,
                                      gender: selectedGender ?? '',
                                      email: _emailController.text,
                                      age: parsedAge ?? DateTime.now(),
                                    );
                                  },
                                ).show();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColor.primaryColor,
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Cập nhật thông tin',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text('No data found'));
            }
          },
        ),
      ),
    );
  }
}
class CurvedShape extends StatelessWidget {
  const CurvedShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: MyColor.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
    );
  }
}
