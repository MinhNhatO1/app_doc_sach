import 'package:app_doc_sach/page/page_admin/banner/display_banner.dart';
import 'package:app_doc_sach/page/page_admin/book/display_book.dart';
import 'package:app_doc_sach/page/page_admin/book_popular/display_bookpopular.dart';
import 'package:flutter/material.dart';

import '../../../const/constant.dart';
import '../author/author_admin.dart';
import '../author/display_author.dart';
import '../book/book_admin.dart';
import '../book_popular/bookpopular_admin.dart';
import '../category/category_admin.dart';
import '../chapter/chapter_admin.dart';
import '../main_screen.dart';
import '../user/user_admin.dart';
import '../user_vip/uservip_admin.dart';

class BannerAdminWidget extends StatefulWidget {
  const BannerAdminWidget({super.key});

  @override
  State<BannerAdminWidget> createState() => _BannerAdminWidgetState();
}

class _BannerAdminWidgetState extends State<BannerAdminWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisplayBanner(),
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
