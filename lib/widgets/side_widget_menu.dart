import 'package:flutter/material.dart';
import '../data/side_menu_data.dart';

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
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  title: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          menuItem.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _translateTitle(menuItem.title),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    switch (menuItem.title) {
                      case 'Dashboard':
                        Navigator.pushNamed(context, '/homepage');
                        break;
                      case 'Book':
                        Navigator.pushNamed(context, '/bookpage');
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
                      case 'SignOut':
                        break;
                    }
                  },
                ),
                const Divider(color: Colors.grey),
              ],
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