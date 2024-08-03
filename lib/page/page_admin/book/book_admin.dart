import 'package:app_doc_sach/page/page_admin/book/display_book.dart';
import 'package:flutter/material.dart';

import '../../../const/constant.dart';
import '../author/author_admin.dart';
import '../author/display_author.dart';
import '../banner/banner_admin.dart';
import '../book_popular/bookpopular_admin.dart';
import '../category/category_admin.dart';
import '../chapter/chapter_admin.dart';
import '../main_screen.dart';
import '../user/user_admin.dart';
import '../user_vip/uservip_admin.dart';

class BookAdminWidget extends StatefulWidget {
  const BookAdminWidget({super.key});

  @override
  State<BookAdminWidget> createState() => _BookAdminWidgetState();
}

class _BookAdminWidgetState extends State<BookAdminWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisplayBook(),
      routes: {
        '/homepage': (context) => const MainScreen(),
        '/bookpage': (context) => const BookAdminWidget(),
        '/chapterpage': (context) => const ChapterAdminWidget(),
        '/bookpopular': (context) => const BookpopularAdminWidget(),
        '/category': (context) => const CategoryAdminWidget(),
        '/author': (context) => const AuthorAdminWidget(),
        '/banner': (context) => const BannerAdminWidget(),
        '/user': (context) => const UserAdminWidget(),
        '/uservip': (context) => const UserVipAdminWidget(),
      },
    );;
  }
}
