import 'package:app_doc_sach/model/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icon(Icons.home), title: 'Dashboard'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/openbook.png'),size: 25,), title: 'Sách'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/chapter.png'),size: 25,), title: 'Chương sách'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/favoritebook.png'),size: 25,), title: 'Sách phổ biến'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/optionslines.png'),size: 25,), title: 'Thể loại'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/author.png'),size: 25,), title: 'Tác giả'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/ads.png'),size: 25,), title: 'Banner'),
    MenuModel(icon: Icon(Icons.person), title: 'Người dùng'),
    MenuModel(icon: ImageIcon(AssetImage('assets/icon/vipcard.png'),size: 25,), title: 'Tài khoản VIP'),
    MenuModel(icon: Icon(Icons.logout), title: 'Đăng xuất Admin'),
  ];
}