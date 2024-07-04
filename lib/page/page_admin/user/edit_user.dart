import 'dart:convert';
import 'dart:io';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'display_user.dart';
import 'package:app_doc_sach/model/user_model.dart';

//update
class EditUser extends StatefulWidget {
  final Users? users;

  const EditUser({Key? key, this.users}) : super(key: key);

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  late TextEditingController imageController;
  late TextEditingController phoneController;
  late TextEditingController genderController;
  late TextEditingController addressController;

  File? _image;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.users?.fullName);
    emailController = TextEditingController(text: widget.users?.email);
    ageController = TextEditingController(
      text: widget.users?.age != null
          ? DateFormat('yyyy-MM-dd').format(widget.users!.age!)
          : '',
    );
    imageController = TextEditingController(text: widget.users?.avatar);
    phoneController = TextEditingController(text: widget.users?.phone);
    genderController = TextEditingController(text: widget.users?.gender);
    addressController = TextEditingController(text: widget.users?.address);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    ageController.dispose();
    phoneController.dispose();
    imageController.dispose();
    genderController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.users?.age ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.users?.age) {
      setState(() {
        widget.users?.age = picked;
        ageController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<String> uploadImage(File image) async {
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
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      } else {
        throw Exception('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void editUser({
    required Users users,
    required String fullName,
    required String email,
    required DateTime age,
    required String image,
    required String phone,
    required String gender,
    required String address,
  }) async {
    if (_image != null) {
      try {
        image = await uploadImage(_image!);
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        return;
      }
    }

    Map data = {
      'data': {
        "fullName": fullName,
        "email": email,
        "age": DateFormat('yyyy-MM-dd').format(age),
        "image": image,
        "phone": phone,
        "gender": gender,
        "address": address,
      }
    };

    // Encode Map to JSON
    var body = json.encode(data);
    final response = await http.put(
      Uri.parse("$baseUrl/api/profiles/${users.id}"),
      headers: <String, String>{
        'content-type': 'application/json;charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('User updated successfully');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const DisplayUser(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Failed to update user: ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa thông tin người dùng'),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0.0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TextField(
                //   controller: fullNameController,
                //   decoration: const InputDecoration(
                //     labelText: 'Full Name',
                //   ),
                //   onChanged: (val) {
                //     setState(() {
                //       widget.users?.fullName = val;
                //     });
                //   },
                // ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (val) {
                      widget.users?.fullName = val;
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
                // const SizedBox(height: 10),
                // TextField(
                //   controller: emailController,
                //   decoration: const InputDecoration(
                //     labelText: 'Email',
                //   ),
                //   onChanged: (val) {
                //     setState(() {
                //       widget.users?.email = val;
                //     });
                //   },
                // ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (val) {
                      widget.users?.email = val;
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
                // const SizedBox(height: 10),
                // GestureDetector(
                //   onTap: () => _selectDate(context),
                //   child: AbsorbPointer(
                //     child: TextField(
                //       controller: ageController,
                //       decoration: const InputDecoration(
                //         labelText: 'Age',
                //       ),
                //       onChanged: (val) {
                //         setState(() {
                //           widget.users?.age = DateFormat('yyyy-MM-dd').parse(val);
                //         });
                //       },
                //     ),
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
                          widget.users?.age = DateFormat('yyyy-MM-dd').parse(val);
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
                // const SizedBox(height: 10),
                // TextField(
                //   controller: imageController,
                //   decoration: const InputDecoration(
                //     labelText: 'Image URL',
                //   ),
                //   onChanged: (val) {
                //     setState(() {
                //       widget.users?.avatar = val;
                //     });
                //   },
                // ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (val) {
                      widget.users?.avatar = val;
                    },
                    controller: imageController,
                    decoration: InputDecoration(
                      labelText: 'URL hình ảnh',
                      hintText: 'Nhập URL của hình ảnh',
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
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Chọn ảnh bìa'),
                  ),
                ),
                const SizedBox(height: 20),
                // TextField(
                //   controller: phoneController,
                //   decoration: const InputDecoration(
                //     labelText: 'Phone',
                //   ),
                //   onChanged: (val) {
                //     setState(() {
                //       widget.users?.phone = val;
                //     });
                //   },
                // ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (val) {
                      widget.users?.phone = val;
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
                // const SizedBox(height: 10),
                // TextField(
                //   controller: genderController,
                //   decoration: const InputDecoration(
                //     labelText: 'Gender',
                //   ),
                //   onChanged: (val) {
                //     setState(() {
                //       widget.users?.gender = val;
                //     });
                //   },
                // ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (val) {
                      widget.users?.gender = val;
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
                // const SizedBox(height: 10),
                // TextField(
                //   controller: addressController,
                //   decoration: const InputDecoration(
                //     labelText: 'Address',
                //   ),
                //   onChanged: (val) {
                //     setState(() {
                //       widget.users?.address = val;
                //     });
                //   },
                // ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    onChanged: (val) {
                      widget.users?.address = val;
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
                // ElevatedButton(
                //   onPressed: () {
                //     editUser(
                //       users: widget.users!,
                //       fullName: fullNameController.text,
                //       age: DateFormat('yyyy-MM-dd').parse(ageController.text),
                //       email: emailController.text,
                //       image: imageController.text,
                //       phone: phoneController.text,
                //       gender: genderController.text,
                //       address: addressController.text,
                //     );
                //   },
                //   child: const Text('Save'),
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
                            editUser(users: widget.users!,
                                fullName: fullNameController.text,
                                email: emailController.text,
                                age: DateFormat('yyyy-MM-dd').parse(ageController.text),
                                image: imageController.text,
                                phone: phoneController.text,
                                gender: genderController.text,
                                address: addressController.text);
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_sharp,color: Colors.white,), // Biểu tượng
                          SizedBox(width: 5), // Khoảng cách giữa icon và văn bản
                          Text('Lưu thông tin'), // Văn bản
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
    );
  }
}
