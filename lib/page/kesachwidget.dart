import 'package:app_doc_sach/page/page_tab_kesach/bosuutap.dart';
import 'package:app_doc_sach/page/page_tab_kesach/danhngon.dart';
import 'package:app_doc_sach/page/page_tab_kesach/lichsu.dart';
import 'package:app_doc_sach/page/page_tab_kesach/yeuthich.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/ui_provider.dart';
import '../state/tab_kesach.dart';
import '../state/tab_state.dart';

class KeSachWidget extends StatefulWidget {
  const KeSachWidget({super.key});

  @override
  State<KeSachWidget> createState() => _KeSachWidgetState();
}


class _KeSachWidgetState extends State<KeSachWidget> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin  {
  int selectedTab = 0;
  late TabController _tabController;

  //Trang thai cua Tab
  final _tabState = TabStateKeSach();
  final _selectedColor = const Color(0xFF38A938) /*Color.fromRGBO(230, 133, 46,1)*/;
  final _unselectedColor =  Colors.black;

  final _tabs = const [
    Tab(text: 'Lịch sử đọc'),
    Tab(child: Text('Yêu thích')),
    Tab(child: Text('Danh ngôn')),
    Tab(child: Text('Bộ sưu tập')),
  ];

  // Function to generate tabs with dynamic text color
  List<Tab> generateTabs(UiProvider notifier) {
    return const [
      Tab(
        child: Text(
          'Lịch sử đọc',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
      Tab(
        child: Text(
          'Yêu thích',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
      Tab(
        child: Text(
          'Danh ngôn',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
      Tab(
        child: Text(
          'Bộ sưu tập',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }
  @override
  void initState() {
    _tabController = TabController(
        length: _tabs.length, vsync: this, initialIndex: _tabState.selectedTab);
    super.initState();
    /* _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isSearching = false;
        });
      }
    });*/
  }


  @override
  void dispose() {
    /*_focusNode.dispose();*/
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _tabState,
      child: Scaffold(
        body: SafeArea(
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
                    child: Consumer<TabStateKeSach>(
                      builder: (context, tabState, child) {
                        // Update the TabController index
                        return IndexedStack(
                          index: _tabState.selectedTab,
                          children: [
                            // Nội dung cho mỗi Tab
                            _buildTabContent(const LichSuDocWidget()),
                            _buildTabContent(const YeuthichWidget()),
                            _buildTabContent(const DanhngonWidget()),
                            _buildTabContent(const BosuutapWidget()),
                          ],
                        );
                      },
                    ),
                  ),
                ]);
              }),
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget widget) {
    return Center(child: widget);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
