import 'package:app_doc_sach/page/page_admin/book/display_book.dart';
import 'package:app_doc_sach/page/page_admin/book_popular/display_bookpopular.dart';
import 'package:flutter/material.dart';

import '../../../const/constant.dart';
import '../author/author_admin.dart';
import '../author/display_author.dart';
import '../banner/banner_admin.dart';
import '../book/book_admin.dart';
import '../category/category_admin.dart';
import '../chapter/chapter_admin.dart';
import '../main_screen.dart';
import '../user/user_admin.dart';
import '../user_vip/uservip_admin.dart';

class BookpopularAdminWidget extends StatefulWidget {
  const BookpopularAdminWidget({super.key});

  @override
  State<BookpopularAdminWidget> createState() => _BookpopularAdminWidgetState();
}

class _BookpopularAdminWidgetState extends State<BookpopularAdminWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sách phổ biến',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisplayBookpopular(),
      routes: {
        '/homepage': (context) => const MainScreen(),
        '/bookpage': (context) => const BookAdminWidget(),
        '/chapterpage': (context) => const ChapterAdminWidget(),
        '/bookpopular': (context) => const  BookpopularAdminWidget(),
        '/category': (context) => const CategoryAdminWidget(),
        '/author': (context) => const AuthorAdminWidget(),
        '/banner': (context) => const BannerAdminWidget(),
        '/user': (context) => const UserAdminWidget(),
        '/uservip': (context) => const UserVipAdminWidget(),
      },
    );;
  }
}
