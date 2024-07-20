import 'package:app_doc_sach/model/favorite_model.dart';
import 'package:app_doc_sach/widgets/line_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:app_doc_sach/data/book_details.dart'; // Import your BookDetails class
import 'package:app_doc_sach/util/responsive.dart';
import 'package:app_doc_sach/widgets/activity_details_card.dart';
import 'package:app_doc_sach/widgets/header_widget.dart';
// Import the TopFavoriteBooksScreen widget
import 'package:app_doc_sach/widgets/summary_widget.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookDetails = BookDetails(); // Initialize BookDetails


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const HeaderWidget(),
            const SizedBox(height: 18),
            ActivityDetailsCard(bookDetails: bookDetails), // Pass BookDetails instance
            const SizedBox(height: 18),
            const TopFavoriteBooksScreen(), // Pass the Favorite instance
            const SizedBox(height: 18),
            if (Responsive.isTablet(context)) const SummaryWidget(),
          ],
        ),
      ),
    );
  }
}
