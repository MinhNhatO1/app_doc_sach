import 'package:app_doc_sach/page/page_admin/book/display_book.dart';
import 'package:app_doc_sach/page/page_admin/book_popular/display_bookpopular.dart';
import 'package:app_doc_sach/page/page_admin/user_vip/display_uservip.dart';
import 'package:flutter/material.dart';

import '../../../const/constant.dart';
import '../author/author_admin.dart';
import '../author/display_author.dart';
import '../banner/banner_admin.dart';
import '../book/book_admin.dart';
import '../book_popular/bookpopular_admin.dart';
import '../category/category_admin.dart';
import '../chapter/chapter_admin.dart';
import '../main_screen.dart';
import '../user/user_admin.dart';

class UserVipAdminWidget extends StatefulWidget {
  const UserVipAdminWidget({super.key});

  @override
  State<UserVipAdminWidget> createState() => _UserVipAdminWidgetState();
}

class _UserVipAdminWidgetState extends State<UserVipAdminWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tài khoản VIP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisPlayUserVip(),
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
    );
  }
}
