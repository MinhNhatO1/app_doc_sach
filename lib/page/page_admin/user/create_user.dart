import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/controller/auth_controller.dart';
import 'package:app_doc_sach/model/file_upload.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:app_doc_sach/model/user_model.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/page/page_admin/user/display_user.dart';
import 'package:app_doc_sach/page/page_admin/category/textfield.dart';
import 'package:flutter/foundation.dart';

import '../../../color/mycolor.dart';

class CreateUser extends StatefulWidget {
  final int? id;
  const CreateUser({Key? key, this.id});
  @override
  _CreateUserState createState() => _CreateUserState();
}

//update
Users users = Users(
  id: 0,
  fullName: '',
  email: '',
  age: DateTime.now(),
  avatar: '',
  phone: '',
  gender: '',
  address: '',
);

// TextEditingController initialization
TextEditingController fullNameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController ageController = TextEditingController(
  text: users.age != null ? DateFormat('yyyy-MM-dd').format(users.age!) : '',
);
TextEditingController imageController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController genderController = TextEditingController();
TextEditingController addressController = TextEditingController();

class _CreateUserState extends State<CreateUser> {
  File? _imageFile;
  String? _webImagePath;

  Future<FileUpload?> uploadImage(dynamic imageData) async {
    var uri = Uri.parse('$baseUrl/api/upload/');
    var request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      // Handling for web
      if (imageData is String && imageData.startsWith('data:image')) {
        // This is a Data URL
        var bytes = base64Decode(imageData.split(',').last);
        request.files.add(http.MultipartFile.fromBytes(
          'files',
          bytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'),
        ));
      } else {
        throw Exception('Invalid image data for web');
      }
    } else {
      // Handling for mobile
      if (imageData is File) {
        var stream = http.ByteStream(imageData.openRead());
        var length = await imageData.length();
        request.files.add(http.MultipartFile(
          'files',
          stream,
          length,
          filename: imageData.path.split('/').last,
          contentType: MediaType('image', 'png'),
        ));
      } else {
        throw Exception('Invalid image data for mobile');
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var fileUpload = FileUpload.fromJson(jsonResponse[0]);
        print('Upload successful: ${fileUpload.url}');
        return fileUpload;
      } else {
        print('Error uploading image. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _imageFile = imageFile;
      });

      try {
        var fileUpload = await uploadImage(imageFile);

        if (fileUpload != null) {
          setState(() {
            _webImagePath = fileUpload.url;
            users.avatar = fileUpload.url;
          });
        }
      } catch (e) {
        print('Error uploading image or updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image or updating profile: $e')),
        );
      }
    }
  }

  Future<void> save() async {
    try {
      Map data = {
        'data': {
          "fullName": users.fullName,
          "email": users.email,
          "age": users.age != null
              ? DateFormat('yyyy-MM-dd').format(users.age!)
              : '',
          "image": users.avatar,
          "phone": users.phone,
          "gender": users.gender,
          "address": users.address,
        }
      };
      var body = json.encode(data);
      var response = await http.post(
        Uri.parse("$baseUrl:1337/api/profiles/"),
        headers: <String, String>{
          'content-type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const DisplayUser()),
            (Route<dynamic> route) => false);
      } else {
        print('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: users.age,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != users.age) {
      setState(() {
        users.age = picked; // Cập nhật ngày sinh vào đối tượng author
        ageController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
        centerTitle: true,
        title: const Text('Thêm người dùng'),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              // padding: const EdgeInsets.all(20),
              // height: 850,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10),
              //   color: Colors.white,
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.grey.withOpacity(0.3),
              //       spreadRadius: 2,
              //       blurRadius: 5,
              //       offset: const Offset(0, 3),
              //     ),
              //   ],
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //   width: double.infinity,
                  //   color: Colors.white,
                  //   child: Textfield(
                  //     controller: fullNameController,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         users.fullName = val;
                  //       });
                  //     },
                  //     hintText: 'Full Name',
                  //     icon: const Icon(Icons.person),
                  //     hintStyle: const TextStyle(color: Colors.black54),
                  //   ),
                  // ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        users.fullName = val;
                      },
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        hintText: 'Nhập tên đầy đủ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // Container(
                  //   width: double.infinity,
                  //   child: Textfield(
                  //     controller: emailController,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         users.email = val;
                  //       });
                  //     },
                  //     hintText: 'Email',
                  //     icon: const Icon(Icons.email),
                  //     hintStyle: const TextStyle(color: Colors.black54),
                  //   ),
                  // ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        users.email = val;
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Nhập email người dùng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // Container(
                  //   width: double.infinity,
                  //   child: Textfield(
                  //     controller: ageController,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         users.age = DateTime.tryParse(val);
                  //       });
                  //     },
                  //     hintText: 'Age (YYYY-MM-DD)',
                  //     icon: const Icon(Icons.cake),
                  //     hintStyle: const TextStyle(color: Colors.black54),
                  //   ),
                  // ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: ageController,
                          onChanged: (String val) {
                            users.age = DateFormat('dd-MM-yyyy').parse(val);
                          },
                          decoration: InputDecoration(
                            labelText: 'Ngày sinh',
                            suffixIcon: const Icon(Icons.date_range),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.red, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.red, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_imageFile != null)
                    Image.file(
                      _imageFile!,
                      height: 200,
                      width: 200,
                    )
                  else if (_webImagePath != null)
                    Image.network(
                      _webImagePath!,
                      height: 200,
                      width: 200,
                    )
                  else
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh bìa'),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Container(
                  //   width: double.infinity,
                  //   child: Textfield(
                  //     controller: phoneController,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         users.phone = val;
                  //       });
                  //     },
                  //     hintText: 'Phone',
                  //     icon: const Icon(Icons.phone),
                  //     hintStyle: const TextStyle(color: Colors.black54),
                  //   ),
                  // ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        users.phone = val;
                      },
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Điện thoại',
                        hintText: 'Nhập số điện thoại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // Container(
                  //   width: double.infinity,
                  //   child: Textfield(
                  //     controller: genderController,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         users.gender = val;
                  //       });
                  //     },
                  //     hintText: 'Gender',
                  //     icon: const Icon(Icons.wc),
                  //     hintStyle: const TextStyle(color: Colors.black54),
                  //   ),
                  // ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        users.gender = val;
                      },
                      controller: genderController,
                      decoration: InputDecoration(
                        labelText: 'Giới tính',
                        hintText: 'Nhập giới tính',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // Container(
                  //   width: double.infinity,
                  //   child: Textfield(
                  //     controller: addressController,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         users.address = val;
                  //       });
                  //     },
                  //     hintText: 'Address',
                  //     icon: const Icon(Icons.home),
                  //     hintStyle: const TextStyle(color: Colors.black54),
                  //   ),
                  // ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        users.address = val;
                      },
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ',
                        hintText: 'Nhập địa chỉ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.white,
                  //       backgroundColor: Colors.black,
                  //       padding: const EdgeInsets.symmetric(vertical: 15),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //     ),
                  //     onPressed: save,
                  //     child: const Text('Save'),
                  //   ),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(MyColor.primaryColor), // Màu nền
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Màu chữ
                          minimumSize: MaterialStateProperty.all(Size(120, 50)), // Kích thước tối thiểu của button
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16)), // Đệm bên trong button
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(fontSize: 15), // Cỡ chữ
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (fullNameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                DateFormat('dd-MM-yyyy').parse(ageController.text).year > 2006 ||
                                imageController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                genderController.text.isEmpty ||
                                addressController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xff2A303E),
                                          borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 20,),
                                          Image.asset('assets/icon/error.png',width: 50,),
                                          const SizedBox(height: 20,),
                                          Text('Thông tin bạn nhập chưa đầy đủ',
                                              style: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xffEC5B5B), fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5,),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if (fullNameController.text.isEmpty)
                                                Text('• Vui lòng nhập tên đầy đủ',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (emailController.text.isEmpty)
                                                Text('• Vui lòng nhập email',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (DateFormat('dd-MM-yyyy').parse(ageController.text).year > 2006)
                                                Text('• Vui lòng nhập ngày sinh',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (imageController.text.isEmpty)
                                                Text('• Vui lòng thêm ảnh',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (phoneController.text.isEmpty)
                                                Text('• Vui lòng nhập số điện thoại',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (genderController.text.isEmpty)
                                                Text('• Vui lòng nhập giới tính',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (addressController.text.isEmpty)
                                                Text('• Vui lòng nhập địa chỉ',
                                                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                              const SizedBox(height: 20,),
                                              Center(
                                                child: OutlinedButton(
                                                  onPressed: () {Navigator.of(context).pop();},
                                                  style: OutlinedButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                                      foregroundColor: const Color(0xffEC5B5B),
                                                      side: const BorderSide(color: Color(0xffEC5B5B),)
                                                  ),
                                                  child: const Text('Đóng'),
                                                ),
                                              ),
                                              const SizedBox(height: 10,),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              save();
                            }
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_sharp,color: Colors.white,), // Biểu tượng
                            SizedBox(width: 5), // Khoảng cách giữa icon và văn bản
                            Text('Thêm'), // Văn bản
                          ],
                        ),
                      ),
                      const SizedBox(width: 85,),
                      ElevatedButton(
                        onPressed: () {
                          _refreshForm(); // Gọi hàm để làm mới form
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Màu nền
                          minimumSize: Size(120, 50), // Kích thước tối thiểu của button
                          padding: EdgeInsets.all(16), // Đệm bên trong button
                          textStyle: TextStyle(fontSize: 15), // Cỡ chữ
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh,color: Colors.white,), // Biểu tượng
                            SizedBox(width: 5), // Khoảng cách giữa icon và văn bản
                            Text('Làm mới'), // Văn bản
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _refreshForm() {
    setState(() {
      fullNameController.clear();
      emailController.clear();
      ageController.clear();
      imageController.clear();
      phoneController.clear();
      genderController.clear();
      addressController.clear();
    });
  }
}
