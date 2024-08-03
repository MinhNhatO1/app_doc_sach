import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/page/page_admin/dashboard_admin.dart';
import 'package:app_doc_sach/util/responsive.dart';
import 'package:app_doc_sach/widgets/dashboard_widget.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
import 'package:app_doc_sach/widgets/summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
    final isDesktop = Responsive.isDesktop(context);
     return Scaffold(
      drawer: !isDesktop
          ? const SizedBox(
              width: 300,
              child: SideWidgetMenu(),
            )
          : null,
      endDrawer: Responsive.isMobile(context)
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const SummaryWidget(),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              const Expanded(
                flex: 2,
                child: SizedBox(
                  child: SideWidgetMenu(),
                ),
              ),
            const Expanded(
              flex: 7,
              child: DashboardWidget(),
            ),
            if (isDesktop)
              const Expanded(
                flex: 3,
                child: SummaryWidget(),
              ),
          ],
        ),
      ),
    );
  }
}
