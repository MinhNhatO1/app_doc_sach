import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/page/page_admin/author/author_admin.dart';
import 'package:app_doc_sach/page/page_admin/book_admin.dart';
import 'package:app_doc_sach/page/page_admin/category/category_admin.dart';
import 'package:app_doc_sach/page/page_admin/category/display_category.dart';
import 'package:app_doc_sach/page/page_admin/main_screen.dart';
import 'package:app_doc_sach/page/page_admin/user/display_user.dart';
import 'package:app_doc_sach/page/page_admin/user/user_admin.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
import 'package:flutter/material.dart';

import '../banner/banner_admin.dart';
import '../book/book_admin.dart';
import '../book_popular/bookpopular_admin.dart';
import '../chapter/chapter_admin.dart';
import '../user_vip/uservip_admin.dart';

class UserAdminWidget extends StatelessWidget{
    const UserAdminWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisplayUser(),
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