import 'package:app_doc_sach/model/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icon(Icons.home), title: 'Dashboard'),
    MenuModel(icon: Icon(Icons.book), title: 'Book'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/chapter.png'),size: 25,), title: 'Chương sách'),
    MenuModel(icon: Icon(Icons.category), title: 'Category'),
    MenuModel(icon: Icon(Icons.person_add_alt), title: 'Author'),
    MenuModel(icon: Icon(Icons.person), title: 'User'),
    MenuModel(icon: Icon(Icons.logout), title: 'SignOut'),
  ];
}