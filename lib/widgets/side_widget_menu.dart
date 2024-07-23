import 'package:app_doc_sach/data/side_menu_data.dart';
import 'package:app_doc_sach/main.dart';
import 'package:app_doc_sach/widgets/showdialog_signoutAdmin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../page/slash_screen/slash_screen.dart';
import '../route/app_route.dart';
import '../view/dashboard/dashboard_screen.dart';

class SideWidgetMenu extends StatelessWidget {
  const SideWidgetMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          //...:nó chèn all phần tử của 1 danh sách vào một list khác
          ...SideMenuData().menu.map((menuItem) {
            return ListTile(
              leading: menuItem.icon,
              title: Text(menuItem.title),
              onTap: () async  {
                Navigator.pop(context); // Close the drawer
                if (menuItem.title == 'Đăng xuất Admin') {
                  await showLogoutConfirmationDialog(context);
                }
                else{
                  switch (menuItem.title) {
                    case 'Dashboard':
                      Navigator.pushNamed(context, '/homepage');
                      break;
                    case 'Sách':
                      Navigator.pushNamed(context, '/bookpage');
                      break;
                    case 'Chương sách':
                      Navigator.pushNamed(context, '/chapterpage');
                      break;
                    case 'Sách phổ biến':
                      Navigator.pushNamed(context, '/bookpopular');
                      break;
                    case 'Thể loại':
                      Navigator.pushNamed(context, '/category');
                      break;
                    case 'Tác giả':
                      Navigator.pushNamed(context, '/author');
                      break;
                    case 'Banner':
                      Navigator.pushNamed(context, '/banner');
                      break;
                    case 'Người dùng':
                      Navigator.pushNamed(context, '/user');
                      break;
                    case 'Tài khoản VIP':
                      Navigator.pushNamed(context, '/uservip');
                      break;
                  // Add other cases for different menu items here
                  }
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
