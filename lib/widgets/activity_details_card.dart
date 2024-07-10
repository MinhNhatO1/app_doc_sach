import 'package:flutter/material.dart';
import 'package:app_doc_sach/data/book_details.dart'; // Import your BookDetails class
import 'package:app_doc_sach/model/book_statistical_model.dart';
import 'package:app_doc_sach/widgets/custom_card_widget.dart';

class ActivityDetailsCard extends StatefulWidget {
  final BookDetails bookDetails; // Accept BookDetails instance

  const ActivityDetailsCard({Key? key, required this.bookDetails}) : super(key: key);

  @override
  _ActivityDetailsCardState createState() => _ActivityDetailsCardState();
}

class _ActivityDetailsCardState extends State<ActivityDetailsCard> {
  @override
  void initState() {
    super.initState();
    widget.bookDetails.fetchBooksFromStrapi().then((_) {
      setState(() {}); // Update state to refresh UI
    });
    widget.bookDetails.fetchAuthorsFromStrapi().then((_) {
      setState(() {}); // Update state to refresh UI
    });
    widget.bookDetails.fetchUsersFromStrapi().then((_) {
      setState(() {}); // Update state to refresh UI
    });
     widget.bookDetails.fetchCategoriesFromStrapi().then((_) {
      setState(() {}); // Update state to refresh UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.bookDetails.bookData.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Example: Change as per your responsive needs
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemBuilder: (context, index) => CustomCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              widget.bookDetails.bookData[index].icon,
              width: 30,
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 4),
              child: Text(
                widget.bookDetails.bookData[index].value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              widget.bookDetails.bookData[index].title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}