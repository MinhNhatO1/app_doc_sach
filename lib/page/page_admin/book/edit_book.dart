import 'dart:convert';
import 'dart:io';
import 'package:app_doc_sach/const.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/book_model.dart';
import '../../../model/author_model.dart';
import '../../../model/category_model.dart';
import '../../../controller/book_controller.dart';
import '../../../controller/author_controller.dart';
import '../../../controller/category_controller.dart';
import '../../../color/mycolor.dart';
import '../../../model/file_upload.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
class EditBookPage extends StatefulWidget {
  final Book book;
  const EditBookPage({Key? key, required this.book}) : super(key: key);

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final BookController _bookService = BookController();
  List<Book> _books = [];
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _pagesController;
  late TextEditingController _isbnController;
  late TextEditingController _languageController;

  List<Author> _authors = [];
  List<CategoryModel> _categories = [];
  List<Author> _selectedAuthors = [];
  List<CategoryModel> _selectedCategories = [];
  String? _imagePath;
  File? _newImageFile;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _descriptionController = TextEditingController(text: widget.book.description);
    _pagesController = TextEditingController(text: widget.book.pages.toString());
    _isbnController = TextEditingController(text: widget.book.isbn);
    _languageController = TextEditingController(text: widget.book.language);
    _selectedAuthors = List.from(widget.book.authors ?? []);
    _selectedCategories = List.from(widget.book.categories ?? []);
    _imagePath = widget.book.coverImage?.url;
    _loadAuthors();
    _loadCategories();
  }

  Future<void> _loadAuthors() async {
    try {
      final List<Author> fetchedAuthors = await AuthorController.instance.fetchAuthors();
      setState(() {
        _authors = fetchedAuthors;
      });
    } catch (e) {
      print('Error loading authors: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final List<CategoryModel> fetchedCategories = await CategoryController.instance.fetchCategories();
      setState(() {
        _categories = fetchedCategories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void showAlertSuccess(QuickAlertType quickalert){
    QuickAlert.show(context: context, type: quickalert).then((_) {
      // Đóng trang khi người dùng bấm nút "OK"
      Navigator.of(context).pop();
    });
  }

  void showAlertError(QuickAlertType quickalert){
    QuickAlert.show(context: context, type: quickalert).then((_) {
      // Đóng trang khi người dùng bấm nút "OK"
      Navigator.of(context).pop();
    });
  }
  bool _isLoading = false; // Biến để quản lý trạng thái loading

  // Widget hiển thị tiêu đề loading
  Widget _buildLoadingIndicator() {
    return _isLoading
        ? Center(
      child: CircularProgressIndicator(), // Thay thế bằng tiêu đề loading phù hợp
    )
        : SizedBox.shrink(); // Trả về widget trống nếu không cần hiển thị loading
  }
  Future<void> _updateBook() async {
    setState(() {
      _isLoading = true; // Bắt đầu hiển thị tiêu đề loading
    });
    // Chuẩn bị dữ liệu để gửi đi
    Map<String, dynamic> data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'pages': int.tryParse(_pagesController.text.trim()) ?? 0,
      'isbn': _isbnController.text.trim(),
      'language': _languageController.text.trim(),
      'authors': _selectedAuthors.map((author) => {'id': author.id}).toList(),
      'categories': _selectedCategories.map((category) => {'id': category.id}).toList(),
    };

    // Kiểm tra nếu có chọn ảnh mới
    if (_newImageFile != null) {
      // Tải lên ảnh mới và lấy URL của nó
      FileUpload? uploadedImage = await BookController.instance.uploadImage(_newImageFile!);
      if (uploadedImage != null) {
        data['cover_image'] = uploadedImage.toJson(); // Sử dụng toJson() của FileUpload
      }
    }

    // Yêu cầu PUT để cập nhật sách
    String apiUrl = '$baseUrl/api/books/${widget.book.id}';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'data': data}),
      );
      setState(() {
        _isLoading = false; // Ẩn tiêu đề loading sau khi nhận được kết quả từ server
      });
      if (response.statusCode == 200) {

        showAlertSuccess(QuickAlertType.success);
        print('Book Edit successfully');
        // Xử lý thành công nếu cần
      } else {
        setState(() {
          _isLoading = false; // Ẩn tiêu đề loading nếu có lỗi
        });
        showAlertError(QuickAlertType.error);
        print('Cập nhật thất bại');
        // Xử lý thất bại nếu cần
      }
    } catch (e) {
      showAlertError(QuickAlertType.error);
      print('Lỗi khi cập nhật sách: $e');
      // Xử lý khi có lỗi
    }
  }

  void _showAuthorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn tác giả'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _authors.map((author) {
                return CheckboxListTile(
                  title: Text(author.authorName),
                  value: _selectedAuthors.any((selectedAuthor) => selectedAuthor.authorName == author.authorName),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!_selectedAuthors.any((selectedAuthor) => selectedAuthor.authorName == author.authorName)) {
                          _selectedAuthors.add(author);
                        }
                      } else {
                        _selectedAuthors.removeWhere((selectedAuthor) => selectedAuthor.authorName == author.authorName);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn thể loại'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _categories.map((category) {
                return CheckboxListTile(
                  title: Text(category.nameCategory),
                  value: _selectedCategories.any((selectedCategory) => selectedCategory.nameCategory == category.nameCategory),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!_selectedCategories.any((selectedCategory) => selectedCategory.nameCategory == category.nameCategory)) {
                          _selectedCategories.add(category);
                        }
                      } else {
                        _selectedCategories.removeWhere((selectedCategory) => selectedCategory.nameCategory == category.nameCategory);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    } else {
      // Xử lý khi người dùng không chọn ảnh
      print('Người dùng không chọn ảnh');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa sách'),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10,),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề sách',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _pagesController,
                  decoration: InputDecoration(
                    labelText: 'Số trang',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _languageController,
                  decoration: InputDecoration(
                    labelText: 'Ngôn ngữ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _selectedAuthors.map((author) {
                          return Chip(
                            label: Text(author.authorName),
                            onDeleted: () {
                              setState(() {
                                _selectedAuthors.remove(author);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showAuthorDialog,
                  child: Text('Chọn tác giả'),
                ),
                SizedBox(height: 20),
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _selectedCategories.map((category) {
                          return Chip(
                            label: Text(category.nameCategory),
                            onDeleted: () {
                              setState(() {
                                _selectedCategories.remove(category);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showCategoryDialog,
                  child: Text('Chọn thể loại'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      width: 180,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Container(
                          height: 180,
                          width: 120,
                          child: _newImageFile != null
                              ? Image.file(_newImageFile!, fit: BoxFit.cover)
                              : (_imagePath != null
                              ? Image.network(
                            baseUrl + _imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(child: Text('Error loading image'));
                            },
                          )
                              : Center(child: Text('No image selected'))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Chọn ảnh bìa'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Xác nhận cập nhật'),
                      content: const Text('Bạn có chắc chắn muốn cập nhật sách?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Hủy'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                          },
                        ),
                        TextButton(
                          child: const Text('Cập nhật'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                            _updateBook(); // Gọi hàm cập nhật sách
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Cập nhật sách', style: TextStyle(color: Colors.white)),
            ),
                const SizedBox(height: 20,),
                _buildLoadingIndicator(), // Hiển thị tiêu đề loading ở đây
              ],
            ),
          ),
        ),
      ),
    );
  }
}