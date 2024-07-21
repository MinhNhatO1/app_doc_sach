import 'package:app_doc_sach/controller/category_controller.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/provider/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../listbook_category/lisistbook_category.dart';

class TimKiemDanhMuc extends StatefulWidget {
  const TimKiemDanhMuc({super.key, required this.textSearch,required this.onPopularSearchSelected,required this.popularSearches});
  final String? textSearch;

  final List<CategoryModel> popularSearches;
  final Function(String) onPopularSearchSelected;
  @override
  State<TimKiemDanhMuc> createState() => _TimKiemDanhMucState();
}

class _TimKiemDanhMucState extends State<TimKiemDanhMuc> {

  final CategoryController categoryController = CategoryController();
  bool isLoading = false;
  List<CategoryModel> featuredCategories = [
    CategoryModel(
      id: 1,
      nameCategory: 'Tâm lý',
      desCategory:
          'Những cuốn sách được bán nhiều nhất trong thời gian gần đây.',
    ),
    CategoryModel(
      id: 2,
      nameCategory: 'Kinh dị',
      desCategory: 'Những cuốn sách mới được xuất bản và phát hành.',
    ),
    CategoryModel(
      id: 3,
      nameCategory: 'Lãng mạn',
      desCategory:
          'Những cuốn sách nhận được nhiều đánh giá tích cực từ người đọc.',
    ),
    CategoryModel(
      id: 4,
      nameCategory: 'Sách đoạt giải',
      desCategory:
          'Những cuốn sách đã giành được các giải thưởng văn học uy tín.',
    ),
    CategoryModel(
      id: 5,
      nameCategory: 'Sách kinh điển',
      desCategory: 'Những cuốn sách được coi là kinh điển trong nền văn học.',
    ),
  ];

  Future<List<CategoryModel>> _getCategories(String textSearch) async {
    await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second
    try {
      return await categoryController.getCategoriesBySearch(textSearch);
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }
  @override
  void initState() {
    super.initState();
    if (widget.textSearch != null && widget.textSearch!.isNotEmpty) {
      isLoading = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<UiProvider>(
      builder: (BuildContext context, UiProvider value, Widget? child) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.textSearch != null && widget.textSearch!.isNotEmpty)
                    FutureBuilder<List<CategoryModel>>(
                      future: _getCategories(widget.textSearch!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height - 250,
                              child: const Center(child: CircularProgressIndicator())
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height - 250,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'Không tìm thấy danh mục.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return gridviewDanhmuc(snapshot.data!);
                        }
                      },
                    )
                  else
                    searchDefault(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget searchResults(String text) {
    return Consumer<UiProvider>(
      builder: (BuildContext context, UiProvider value, Widget? child) {
        return Container(
          color: value.isDark
              ? Colors.black12
              : const Color.fromRGBO(232, 245, 233, 1.0),
          child: FutureBuilder<List<CategoryModel>>(
            future: categoryController.getCategoriesBySearch(text),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không tìm thấy kết quả'));
              } else {
                return gridviewDanhmuc(snapshot.data!);
              }
            },
          ),
        );
      },
    );
  }


  Widget gridviewDanhmuc(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 250, // Adjust the height as needed
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Không tìm thấy danh mục.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 6.0,
          mainAxisSpacing: 13.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ListBookCategory(category: category),
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
            child: Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Center(
                child: Text(
                  category.nameCategory,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget searchDefault() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildSectionTitle('Tìm kiếm nổi bật'),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildSearchList(widget.popularSearches),
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchList(List<CategoryModel> items) {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 2.0,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              widget.onPopularSearchSelected(item.nameCategory);
            },
            child: Chip(
              label: Text(
                item.nameCategory,
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.green),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
