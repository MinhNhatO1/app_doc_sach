import 'package:app_doc_sach/page/page_admin/chapter/display_chapter.dart';
import 'package:flutter/material.dart';

import '../../../const/constant.dart';
import '../author/author_admin.dart';
import '../book/book_admin.dart';
import '../category/category_admin.dart';
import '../category/display_category.dart';
import '../main_screen.dart';
import '../user/user_admin.dart';

class ChapterAdminWidget extends StatefulWidget {
  const ChapterAdminWidget({super.key});

  @override
  State<ChapterAdminWidget> createState() => _ChapterAdminWidgetState();
}

class _ChapterAdminWidgetState extends State<ChapterAdminWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chương sách',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisplayChapter(),
      routes: {
        '/homepage': (context) => const MainScreen(),
        '/bookpage': (context) => const BookAdminWidget(),
        '/chapterpage': (context) => const ChapterAdminWidget(),
        '/category': (context) => const CategoryAdminWidget(),
        '/author': (context) => const AuthorAdminWidget(),
        '/user': (context) => const UserAdminWidget(),
      },
    );
  }
}
