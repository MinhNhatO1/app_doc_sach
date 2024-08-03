import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/page/page_tab/danhmuc.dart';
import 'package:app_doc_sach/page/page_tab/khampha.dart';
import 'package:app_doc_sach/page/page_tab/moinhat.dart';
import 'package:app_doc_sach/page/page_tab/noibat.dart';
import 'package:app_doc_sach/state/tab_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../provider/ui_provider.dart';

class TrangChuWidget extends StatefulWidget {
  const TrangChuWidget({super.key});

  @override
  State<TrangChuWidget> createState() => _TrangChuWidgetState();
}

class _TrangChuWidgetState extends State<TrangChuWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int selectedTab = 0;
  late TabController _tabController;

  //Trang thai cua Tab
  final _tabState = TabState();

  final _selectedColor = const Color(0xFF38A938) /*Color.fromRGBO(230, 133, 46,1)*/;
  final _unselectedColor =  Colors.black;
  final _tabs = const [
    Tab(text: 'Khám phá'),
    Tab(child: Text('Nổi bật')),
    Tab(child: Text('Mới nhất')),
    Tab(child: Text('Danh mục')),
  ];
  // Function to generate tabs with dynamic text color
  List<Tab> generateTabs(UiProvider notifier) {
    return const [
      Tab(
        child: Text(
          'Khám phá',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
      Tab(
        child: Text(
          'Nổi bật',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
      Tab(
        child: Text(
          'Mới nhất',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
      Tab(
        child: Text(
          'Danh mục',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  @override
  void initState() {
    _tabController = TabController(
        length: 4, vsync: this, initialIndex: _tabState.selectedTab);
    setStatusBarColor();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void setStatusBarColor() async {
    // Lấy UiProvider từ context
    final uiProvider = Provider.of<UiProvider>(context, listen: false);

    // Áp dụng thay đổi SystemUiOverlayStyle dựa trên giá trị của UiProvider
    if (uiProvider.isDark) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color.fromRGBO(232, 245, 233, 1.0),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _tabState,
      child: Scaffold(
        extendBodyBehindAppBar: true, // Lấn lên cả phần status bar
        body: AnnotatedRegion(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Làm trong suốt status bar
            statusBarIconBrightness: Brightness.dark, // Màu sắc icon trên status bar
          ),
          child: SafeArea(
            child: Consumer<UiProvider>(
                builder: (context, UiProvider notifier, child) {
              return Column(children: [
                Container(
                  width: double.infinity,
                  color: notifier.isDark
                      ? Colors.black12
                      : const Color.fromRGBO(232, 245, 233, 1.0),
                  padding: const EdgeInsets.only(top: 10), // Thêm padding ở đây
                  child: TabBar(
                    controller: _tabController,
                    tabs: generateTabs(notifier),
                    dividerColor: Colors.transparent,
                    labelColor: _selectedColor,
                    indicatorColor: _selectedColor,
                    unselectedLabelColor:
                        notifier.isDark ? Colors.white : _unselectedColor,
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    onTap: (index) {
                      _tabState.setSelectedTab(index);
                    },
                  ),
                ),

                // TabBarView
                Expanded(
                  child: Consumer<TabState>(
                    builder: (context, tabState, child) {
                      // Update the TabController index
                      return IndexedStack(
                        index: _tabState.selectedTab,
                        children: [
                          // Nội dung cho mỗi Tab
                          _buildTabContent(const KhamPhaWidget()),
                          _buildTabContent(const NoiBatWidget()),
                          _buildTabContent(const MoiNhatWidget()),
                          _buildTabContent(const DanhMucWidget()),
                        ],
                      );
                    },
                  ),
                ),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget widget) {
    return Center(child: widget);
  }
}
