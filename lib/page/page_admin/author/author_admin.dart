import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/page/page_admin/author/display_author.dart';
import 'package:app_doc_sach/page/page_admin/book_admin.dart';
import 'package:app_doc_sach/page/page_admin/category/category_admin.dart';
import 'package:app_doc_sach/page/page_admin/main_screen.dart';
import 'package:app_doc_sach/page/page_admin/user/user_admin.dart';
import 'package:flutter/material.dart';

import '../book/book_admin.dart';
import '../chapter/chapter_admin.dart';

class AuthorAdminWidget extends StatelessWidget{
    const AuthorAdminWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Author',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      home:  const DisplayAuthor(),
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