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
  const SideWidgetMenu({super.key});

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Image(
                    image: AssetImage('assets/icon/logoapp.png'),
                    height: 50,
                  ),
                ),
                const SizedBox(width: 20),
                const Flexible(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ...SideMenuData().menu.map((menuItem) {
            return ListTile(
              leading: menuItem.icon,
              title: Text(menuItem.title),
              onTap: () async  {
                Navigator.pop(context); // Close the drawer
                if (menuItem.title == 'SignOut') {
                  await showLogoutConfirmationDialog(context);
                }
                else{
                  switch (menuItem.title) {
                    case 'Dashboard':
                      Navigator.pushNamed(context, '/homepage');
                      break;
                    case 'Book':
                      Navigator.pushNamed(context, '/bookpage');
                      break;
                    case 'Chương sách':
                      Navigator.pushNamed(context, '/chapterpage');
                      break;
                    case 'Category':
                      Navigator.pushNamed(context, '/category');
                      break;
                    case 'Author':
                      Navigator.pushNamed(context, '/author');
                      break;
                    case 'User':
                      Navigator.pushNamed(context, '/user');
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
  String _translateTitle(String title) {
    switch (title) {
      case 'Dashboard':
        return 'Bảng điều khiển';
      case 'Book':
        return 'Sách';
      case 'Category':
        return 'Thể loại';
      case 'Author':
        return 'Tác giả';
      case 'User':
        return 'Người dùng';
      case 'SignOut':
        return 'Thoát ra';
      default:
        return title;
    }
  }
}