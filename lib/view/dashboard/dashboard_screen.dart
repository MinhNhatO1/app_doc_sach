import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/page/kesachwidget.dart';
import 'package:app_doc_sach/page/taikhoanwidget.dart';
import 'package:app_doc_sach/page/thongbaowidget.dart';
import 'package:app_doc_sach/page/timkiemwidget.dart';
import 'package:app_doc_sach/page/trangchuwidget.dart';
import 'package:app_doc_sach/provider/tab_provider.dart';
import 'package:app_doc_sach/state/tab_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../provider/ui_provider.dart';
import '../../service/local_service/local_auth_service.dart';
class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  late TabState _tabState;
  int _selectedIndex = 0;
  final LocalAuthService _localAuthService = LocalAuthService();
  static const List<Widget> _widgetOption = <Widget>[
    TrangChuWidget(),
    KeSachWidget(),
    TimKiemWidget(),
    ThongBaoWidget(),
    TaiKhoanWidget()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    _localAuthService.init();
    super.initState();
    /*
    var tabProvider = Provider.of<TabProvider>(context, listen: false);

    tabProvider.addListener(() {
      setState(() {
        _selectedIndex = tabProvider.selectedIndex;
      });
    });*/
    _tabState = Provider.of<TabState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: IndexedStack(
            index: _tabState.selectedTab,
            children: const [
              TrangChuWidget(),
              KeSachWidget(),
              TimKiemWidget(),
              ThongBaoWidget(),
              TaiKhoanWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer <UiProvider>(
        builder: (context,UiProvider notifier, child) {

          return Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: notifier.isDark ? Colors.grey.shade700 : Colors.grey.shade300))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 13),
              child:GNav(
                tabBorderRadius: 25,
                color: notifier.isDark ? Colors.white : Colors.grey.shade700,
                activeColor: MyColor.primaryColor,
                tabActiveBorder: const Border(top: BorderSide(color: MyColor.primaryColor,width: 1),bottom: BorderSide(color: MyColor.primaryColor,width: 1),right: BorderSide(color: MyColor.primaryColor,width: 1),left: BorderSide(color: MyColor.primaryColor,width: 1)),
                haptic: true,
                iconSize: 18,
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                gap: 8,tabs: const[
                GButton(icon: CupertinoIcons.home, text: 'Trang chủ',textStyle: TextStyle(fontSize: 13,color: MyColor.primaryColor),),
                GButton(icon: FontAwesomeIcons.bookBookmark,text: 'Kệ sách',textStyle: TextStyle(fontSize: 13,color: MyColor.primaryColor),),
                GButton(icon: CupertinoIcons.search,text: 'Tìm kiếm',textStyle: TextStyle(fontSize: 13,color: MyColor.primaryColor),),
                GButton(icon: Icons.notification_important_rounded,text: 'Thông báo',textStyle: TextStyle(fontSize: 13,color: MyColor.primaryColor),),
                GButton(icon: CupertinoIcons.person_alt_circle,text: 'Tài khoản',textStyle: TextStyle(fontSize: 13,color: MyColor.primaryColor),)
              ],

                selectedIndex: _tabState.selectedTab,
                onTabChange: (index) {
                  setState(() {
                    _tabState.setSelectedTab(index);
                  });
                },
              ),
            ),
          );
        }
      ),
    );
  }
}
