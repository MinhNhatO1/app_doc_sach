import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/page/page_admin/author/author_admin.dart';
import 'package:app_doc_sach/page/page_admin/banner/banner_admin.dart';
import 'package:app_doc_sach/page/page_admin/book_popular/bookpopular_admin.dart';
import 'package:app_doc_sach/page/page_admin/book_popular/display_bookpopular.dart';
import 'package:app_doc_sach/page/page_admin/category/category_admin.dart';
import 'package:app_doc_sach/page/page_admin/main_screen.dart';
import 'package:app_doc_sach/page/page_admin/book_admin.dart';
import 'package:app_doc_sach/page/page_admin/user/user_admin.dart';
import 'package:app_doc_sach/page/page_admin/user_vip/uservip_admin.dart';
import 'package:flutter/material.dart';

import '../../view/dashboard/dashboard_screen.dart';
import 'book/book_admin.dart';
import 'chapter/chapter_admin.dart';

class DashboardAdminWidget extends StatelessWidget{
  const DashboardAdminWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Admin',
      debugShowCheckedModeBanner: false,
      // ThemeData là một lớp cung cấp thông tin về màu sắc, kiểu chữ và các yếu tố giao diện khác
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
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
    );
  }
}