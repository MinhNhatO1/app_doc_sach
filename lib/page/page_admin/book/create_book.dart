
import 'dart:io';

import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/controller/category_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/author_controller.dart';
import '../../../controller/book_controller.dart';
import '../../../model/author_model.dart';
import '../../../model/book_model.dart';
import '../../../model/category_model.dart';
/*import 'dart:html' as html; // Import html package for web compatibility*/
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../model/chapter_model.dart';
import '../../../model/file_upload.dart';
class BookCreate extends StatefulWidget {
  const BookCreate({Key? key}) : super(key: key);

  @override
  _BookCreateState createState() => _BookCreateState();
}

class _BookCreateState extends State<BookCreate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _coverImageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _likesController = TextEditingController();
  final TextEditingController _viewController = TextEditingController();

  List<Author> _authors = []; // Populate this list from your data source
  List<CategoryModel> _categories = []; // Populate this list from your data source
  final BookController _bookService = BookController();
  final AuthorController _authorController = AuthorController.instance;
  final CategoryController _categoryController = CategoryController.instance;
  Author? _selectedAuthor;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _selectedCategories = []; // Các thể loại đã chọn
  List<Author> _selectedAuthors = []; // Các tác giả đã chọn
  FilePickerResult? _filePickerResult;
  String? _imagePath; // To store the selected image file
  List<Chapter> _chapters = [];
  List<Book> _books = [];

  //Load Author
  Future<void> _loadAuthors() async {
    try {
      // Example fetch function, replace with your actual fetch logic
      final List<Author> fetchedAuthors = await _authorController.fetchAuthors(); // Assuming fetchAuthors returns a List<Author>

      setState(() {
        _authors = fetchedAuthors; // Assign the fetched list of authors to _authors
      });
    } catch (e) {
      print('Error loading authors: $e');
      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách tác giả. Vui lòng thử lại sau.')),
      );
    }
  }

  //Load Category
  Future<void> _loadCategories() async {
    try {
      // Example fetch function, replace with your actual fetch logic
      final List<CategoryModel> fetchedCategories = await _categoryController.fetchCategories(); // Assuming fetchAuthors returns a List<Author>

      setState(() {
        _categories = fetchedCategories; // Assign the fetched list of authors to _authors
      });
    } catch (e) {
      print('Error loading authors: $e');
      // Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách tác giả. Vui lòng thử lại sau.')),
      );
    }
  }
  List<Author> _extractAuthors(List<Book> books) {
    Set<Author> uniqueAuthors = {};
    books.forEach((book) {
      uniqueAuthors.addAll(book.authors!);
    });
    return uniqueAuthors.toList();
  }

  List<CategoryModel> _extractCategories(List<Book> books) {
    Set<CategoryModel> uniqueCategories = {};
    books.forEach((book) {
      uniqueCategories.addAll(book.categories!);
    });
    return uniqueCategories.toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAuthors();
    _loadCategories();
  }

  //Dialog dnah sach category
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
                  value: _selectedCategories.contains(category),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!_selectedCategories.contains(category)) {
                          _selectedCategories.add(category);
                        }
                      } else {
                        _selectedCategories.remove(category);
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
//Load danh sach Author

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
                  value: _selectedAuthors.contains(author),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!_selectedAuthors.contains(author)) {
                          _selectedAuthors.add(author);
                        }
                      } else {
                        _selectedAuthors.remove(author);
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

  //chuc nang pot sach
  void _createBook() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAuthors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ít nhất một tác giả')),
        );
        return;
      }
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ít nhất một thể loại')),
        );
        return;
      }

      FileUpload? coverImageUpload;
      try {
        if (_imagePath != null) {
          coverImageUpload = await BookController.instance.uploadImage(_imagePath);
          if (coverImageUpload == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không thể tải lên ảnh bìa. Vui lòng thử lại')),
            );
            return;
          }
        }

        Book newBook = Book(
          title: _titleController.text,
          coverImage: coverImageUpload ?? FileUpload(url: ''),
          description: _descriptionController.text,
          pages: int.parse(_pagesController.text),
          isbn: _isbnController.text,
          language: _languageController.text,
          authors: _selectedAuthors,
          categories: _selectedCategories,
          chapters: _chapters,
          likes: 0,
          view: 0,
        );
// In dữ liệu của newBook ra console hoặc debug console
        print('Thông tin sách mới:');
        print('Title: ${newBook.title}');
        print('Cover Image URL: ${newBook.coverImage!.url}');
        print('Description: ${newBook.description}');
        print('Pages: ${newBook.pages}');
        print('ISBN: ${newBook.isbn}');
        print('Language: ${newBook.language}');
        print('Authors:');
        for (var author in newBook.authors!) {
          print('  - ${author.authorName}');
        }
        print('Categories:');
        for (var category in newBook.categories!) {
          print('  - ${category.nameCategory}');
        }
        print('Chapters:');
        for (var chapter in newBook.chapters!) {
          print('  - ${chapter.nameChapter}, ${chapter.mediaFile}');
        }
        print(newBook.toJson());
        bool success = await BookController.instance.createBook(newBook);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sách đã được tạo thành công')),
          );
          _refreshForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể tạo sách. Vui lòng thử lại')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    }
  }
/*
  //Tạo một hàm để hiển thị bottom sheet chứa danh sách chapte
  void _showChaptersBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Danh sách Chapter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_chapters[index].nameChapter),
                          subtitle: Text(_chapters[index].fileUrl),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _chapters.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Thêm Chapter'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddChapterDialog();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  String chapterName = '';
  String fileName = '';
  Uint8List? fileBytes;

  void _showAddChapterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Thêm Chapter Mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: "Tên Chapter"),
                    onChanged: (value) {
                      setState(() {
                        chapterName = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Chọn File'),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          if (kIsWeb) {
                            fileBytes = result.files.single.bytes;
                            fileName = result.files.single.name;
                          } else {
                            fileName = result.files.single.path!;
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  if (fileName.isNotEmpty)
                    Column(
                      children: [
                        Image.asset(
                          'assets/icon/pdf.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 8),
                        Text('File đã chọn: $fileName'),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Thêm'),
                  onPressed: () {
                    if (chapterName.isNotEmpty && fileName.isNotEmpty) {
                      setState(() {
                        _chapters.add(Chapter(
                          nameChapter: chapterName,
                          fileUrl: fileName, // or use fileBytes if needed
                        ));
                        chapterName = ''; // Clear chapterName
                        fileName = ''; // Clear fileName
                        fileBytes = null; // Optionally clear fileBytes if necessary
                      });
                      Navigator.of(context).pop();
                      _showChaptersBottomSheet();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sách mới'),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left:  16.0,right: 16,bottom: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Tiêu đề sách',
                      hintText: 'Nhập tiêu đề sách',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    controller: _isbnController,
                    decoration: InputDecoration(
                      labelText: 'ISBN',
                      hintText: 'Nhập số ISBN',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    maxLines: 10,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      labelStyle: TextStyle(fontSize: 16),
                      hintText: 'Nhập mô tả sách',
                      floatingLabelBehavior: FloatingLabelBehavior.always, // Đặt thuộc tính này để labelText luôn nằm lên trên
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    controller: _pagesController,
                    decoration: InputDecoration(
                      labelText: 'Số trang',
                      hintText: 'Nhập số trang',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    controller: _languageController,
                    decoration: InputDecoration(
                      labelText: 'Ngôn ngữ',
                      hintText: 'Nhập ngôn ngữ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                // Hiển thị danh sách các tác giả đã chọn
                Container(
                  height: 80, // Điều chỉnh chiều cao phù hợp
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
                const SizedBox(height: 20,),
                // Nút để mở dialog chọn tác giả
                ElevatedButton(
                  onPressed: _showAuthorDialog,
                  child: Text('Chọn tác giả'),
                ),

                const SizedBox(height: 20,),
                Container(
                  height: 80, // Điều chỉnh chiều cao phù hợp
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
                const SizedBox(height: 20,),
                // Nút để mở dialog chọn thể loại
                ElevatedButton(
                  onPressed: _showCategoryDialog,
                  child: Text('Chọn thể loại'),
                ),


                const SizedBox(height: 20,),

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
                      child: _imagePath != null
                          ? Center(
                        child: Container(
                          height: 180,
                          width: 120,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image(
                                image: _imagePath!.startsWith('blob:')
                                    ? NetworkImage(_imagePath!)
                                    : kIsWeb
                                    ? NetworkImage(_imagePath!)
                                    : FileImage(File(_imagePath!)) as ImageProvider,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                      )
                          : Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: const Center(
                            child: Image(
                              image: AssetImage('assets/icon/image_default.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 90,),
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(); // Call function to pick an image
                      },
                      child: const Text('Chọn ảnh bìa'),
                    ),
                  ],
                ),
                // Inside _BookCreateState build method
                /*
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: _showChaptersBottomSheet,
                  child: Text('Danh sách Chapter'),
                ),*/
                const SizedBox(height: 40),
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
                          if (_selectedAuthors.isEmpty ||
                              _selectedCategories.isEmpty ||
                              _imagePath == null ||
                              _titleController.text.isEmpty ||
                              _isbnController.text.isEmpty ||
                              _descriptionController.text.isEmpty ||
                              _pagesController.text.isEmpty ||
                              _languageController.text.isEmpty) {
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
                                            if (_selectedAuthors.isEmpty)
                                              Text('• Vui lòng chọn ít nhất một tác giả',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_selectedCategories.isEmpty)
                                              Text('• Vui lòng chọn ít nhất một thể loại',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_imagePath == null)
                                              Text('• Vui lòng chọn ảnh bìa sách',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_titleController.text.isEmpty)
                                              Text('• Vui lòng nhập tiêu đề sách',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_isbnController.text.isEmpty)
                                              Text('• Vui lòng nhập ISBN',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_descriptionController.text.isEmpty)
                                              Text('• Vui lòng nhập mô tả sách',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_pagesController.text.isEmpty)
                                              Text('• Vui lòng nhập số trang',
                                                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w300)),
                                            if (_languageController.text.isEmpty)
                                              Text('• Vui lòng nhập ngôn ngữ',
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
                            _createBook();
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
                const SizedBox(height: 30,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickImage() async {

      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _filePickerResult = result;
          _imagePath = _filePickerResult!.files.single.path;
        });
    }
  }
  void _refreshForm() {
    setState(() {
      _titleController.clear();
      _coverImageController.clear();
      _descriptionController.clear();
      _pagesController.clear();
      _isbnController.clear();
      _languageController.clear();
      _likesController.clear();
      _viewController.clear();
      _selectedAuthor = null;
      _selectedCategory = null;
      _imagePath = null;
      _filePickerResult = null;
      _selectedCategories.clear();
      _selectedAuthors.clear();
    });
  }}
  //void _pickImage() async {
  //  if (kIsWeb) {
  //    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  //    uploadInput.accept = 'image/*';
 //     uploadInput.click();

 //     uploadInput.onChange.listen((e) {
  //      final files = uploadInput.files;
    //    if (files!.isNotEmpty) {
      //    final reader = html.FileReader();
        //  reader.readAsDataUrl(files[0]);
          //reader.onLoadEnd.listen((e) {
          //  setState(() {
           //   _imagePath = reader.result as String?;
           // });
         // });
        //}
   //   });
  //  } else {
  //    final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //    if (result != null) {
  //      setState(() {
   //       _filePickerResult = result;
    //      _imagePath = _filePickerResult!.files.single.path;
    //    });
    //  }
  //  }
 // }


