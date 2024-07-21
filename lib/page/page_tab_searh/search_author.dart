import 'package:app_doc_sach/controller/author_controller.dart';
import 'package:app_doc_sach/model/author_model.dart';
import 'package:app_doc_sach/page/listbook_author/listbook_author.dart';
import 'package:app_doc_sach/provider/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimKiemTacGia extends StatefulWidget {
  const TimKiemTacGia({super.key, required this.textSearch,required this.onPopularSearchSelected,required this.popularSearches});

  final String? textSearch;

  final List<String> popularSearches;
  final Function(String) onPopularSearchSelected;
  @override
  State<TimKiemTacGia> createState() => _TimKiemTacGiaState();
}

class _TimKiemTacGiaState extends State<TimKiemTacGia> {
  List<String> recentSearches = [];
  final AuthorController authorController = AuthorController();

  bool isLoading = false;
  List<String> vietnameseAuthors = [
    "Nguyễn Nhật Ánh",
    "Nguyên Phong",
    "Tần Minh",
    "Tô Hoài",
    "Xuân Diệu",
    "Nam Cao",
    "Nguyễn Huy Thiệp",
    "Phạm Tiến Duật",
    "Lê Minh Khuê",
    "Nguyễn Ngọc Tư",
  ];

  Future<List<Author>> _getAuthors(String textSearch) async {
    await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second
    try {
      return await authorController.getAuthorsBySearch(textSearch);
    } catch (e) {
      print('Error loading authors: $e');
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
                    FutureBuilder<List<Author>>(
                      future: _getAuthors(widget.textSearch!),
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
                                  'Không tìm thấy tác giả.',
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
/*
  Widget searchResults(String text) {
    return Consumer<UiProvider>(
      builder: (BuildContext context, UiProvider value, Widget? child) {
        return Container(
          color: value.isDark
              ? Colors.black12
              : const Color.fromRGBO(232, 245, 233, 1.0),
          child: gridviewDanhmuc(text),
        );
      },
    );
  }*/

  Widget gridviewDanhmuc(List<Author> authors) {
    if (authors.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 250, // Adjust the height as needed
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Không tìm thấy tác giả.',
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
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 300, // Điều chỉnh giá trị này nếu cần
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: authors.length,
          itemBuilder: (BuildContext context, index) {
            final author = authors[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ListBookAuthor(author: author),
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
                    author.authorName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),
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

  Widget _buildSearchList(List<String> items) {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 2.0,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              widget.onPopularSearchSelected(item);
            },
            child: Chip(
              label: Text(
                item,
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
