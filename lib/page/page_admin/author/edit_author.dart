import 'dart:convert';
import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/author_model.dart';
import 'package:app_doc_sach/page/page_admin/author/display_author.dart';
import 'package:app_doc_sach/page/page_admin/category/textfield.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class EditAuthor extends StatefulWidget {
  final Author? authors;
  const EditAuthor({Key? key, this.authors});
  @override
  _EditAuthorState createState() => _EditAuthorState();
}

class _EditAuthorState extends State<EditAuthor> {
  late TextEditingController authorNameController;
  late TextEditingController birthDateController;
  late TextEditingController bornController;
  late TextEditingController teleController;
  late TextEditingController nationalityController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    authorNameController =
        TextEditingController(text: widget.authors?.authorName);
    birthDateController = TextEditingController(
      text: widget.authors?.birthDate != null
          ? DateFormat('dd-MM-yyyy').format(widget.authors!.birthDate!)
          : '',
    );
    bornController = TextEditingController(text: widget.authors?.born);
    teleController = TextEditingController(text: widget.authors?.telphone);
    nationalityController =
        TextEditingController(text: widget.authors?.nationality);
    bioController = TextEditingController(text: widget.authors?.bio);
  }

  @override
  void dispose() {
    authorNameController.dispose();
    birthDateController.dispose();
    bornController.dispose();
    teleController.dispose();
    nationalityController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.authors?.birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.authors?.birthDate) {
      setState(() {
        widget.authors?.birthDate = picked;
        birthDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cập nhật thành công'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lotte1.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                repeat: false,
              ),
              SizedBox(height: 20),
              Text('Cập nhật tác giả thành công!'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void editAuthor({
    required Author authors,
    String? authorName,
    DateTime? birthDate,
    String? born,
    String? telphone,
    String? nationality,
    String? bio,
    required BuildContext context, // Thêm BuildContext để hiển thị Snackbar
  }) async {
    Map<String, dynamic> data = {
      'data': {
        if (authorName != null) "authorName": authorName,
        if (birthDate != null) "birthDate": DateFormat('yyyy-MM-dd').format(birthDate),
        if (born != null) "born": born,
        if (telphone != null) "telephone": telphone,
        if (nationality != null) "nationality": nationality,
        if (bio != null) "bio": bio,
      }
    };

    // Loại bỏ các trường có giá trị null
    data['data'].removeWhere((key, value) => value == null);

    // Encode Map to JSON
    var body = json.encode(data);

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/authors/${authors.id}"),
        headers: <String, String>{
          'content-type': 'application/json;charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        _showSuccessDialog(context);
        // Chuyển hướng về trang DisplayAuthor
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const DisplayAuthor(),
          ),
              (Route<dynamic> route) => false,
        );
      } else {
        // Hiển thị thông báo lỗi khi cập nhật thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật tác giả không thành công. Vui lòng thử lại.',style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hiển thị thông báo lỗi khi có lỗi trong quá trình request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Sửa thông tin tác giả'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        widget.authors?.authorName = val;
                      },
                      controller: authorNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên tác giả',
                        hintText: 'Nhập tên tác giả',
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
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: birthDateController,
                          onChanged: (val) {
                            widget.authors?.birthDate =
                                DateFormat('dd-MM-yyyy').parse(val);
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
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        widget.authors?.born = val;
                      },
                      controller: bornController,
                      decoration: InputDecoration(
                        labelText: 'Nơi sinh',
                        hintText: 'Nhập nơi sinh',
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
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        widget.authors?.telphone = val;
                      },
                      controller: teleController,
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
                  Container(
                    height: 80,
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false, // optional. Shows phone code before the country name.
                          onSelect: (Country country) {
                            setState(() {
                              widget.authors?.nationality = country.name;
                              nationalityController.text = country.name;
                            });
                          },
                        );
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: nationalityController,
                          onChanged: (String val) {
                            // No-op, as the value is selected using the country picker.
                          },
                          decoration: InputDecoration(
                            labelText: 'Quốc gia',
                            suffixIcon: const Icon(Icons.offline_bolt),
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
                  Container(
                    height: 200,
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      onChanged: (val) {
                        widget.authors?.bio = val;
                      },
                      maxLines: 10,
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: 'Sơ yếu lý lịch',
                        hintText: 'Nhập sơ yếu lý lịch',
                        floatingLabelBehavior: FloatingLabelBehavior.always, // Đặt thuộc tính này để labelText luôn nằm lên trên
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(MyColor.primaryColor), // Màu nền
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Màu chữ
                          minimumSize: MaterialStateProperty.all(Size(200, 50)), // Kích thước tối thiểu của button
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16)), // Đệm bên trong button
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(fontSize: 15), // Cỡ chữ
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (authorNameController.text.isEmpty ||
                                DateFormat('dd-MM-yyyy').parse(birthDateController.text).year > 2006 ||
                                bornController.text.isEmpty ||
                                teleController.text.isEmpty ||
                                nationalityController.text.isEmpty ||
                                bioController.text.isEmpty) {
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
                                          Image.asset('assets/icon/error.png',width: 70,),
                                          const SizedBox(height: 20,),
                                          Text('Thông tin bạn nhập chưa đầy đủ',
                                              style: GoogleFonts.montserrat(fontSize: 15, color: const Color(0xffEC5B5B), fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5,),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if (authorNameController.text.isEmpty)
                                                Text('• Vui lòng nhập tên tác giả',
                                                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (DateFormat('dd-MM-yyyy').parse(birthDateController.text).year > 2006)
                                                Text('• Vui lòng điều chỉnh lại năm sinh',
                                                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (bornController.text.isEmpty)
                                                Text('• Vui lòng nhập nơi sinh',
                                                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (teleController.text.isEmpty)
                                                Text('• Vui lòng nhập số điện thoại',
                                                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (nationalityController.text.isEmpty)
                                                Text('• Vui lòng nhập quốc gia',
                                                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300)),
                                              if (bioController.text.isEmpty)
                                                Text('• Vui lòng nhập sơ yếu lý lịch',
                                                    style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300)),
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
                              editAuthor(
                                context: context,
                                authors: widget.authors!,
                                authorName: authorNameController.text.isNotEmpty ? authorNameController.text : null,
                                birthDate: birthDateController.text.isNotEmpty ? DateFormat('dd-MM-yyyy').parse(birthDateController.text) : null,
                                born: bornController.text.isNotEmpty ? bornController.text : null,
                                telphone: teleController.text.isNotEmpty ? teleController.text : null,
                                nationality: nationalityController.text.isNotEmpty ? nationalityController.text : null,
                                bio: bioController.text.isNotEmpty ? bioController.text : null,
                              );
                            }
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.update,color: Colors.white,), // Biểu tượng
                            SizedBox(width: 5), // Khoảng cách giữa icon và văn bản
                            Text('Cập nhật tác giả'), // Văn bản
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
}
