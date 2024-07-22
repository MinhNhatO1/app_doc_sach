import 'package:app_doc_sach/card/quote_card.dart';
import 'package:app_doc_sach/model/quote_model.dart';
import 'package:flutter/material.dart';

class TimKiemDanhNgon extends StatefulWidget {
  const TimKiemDanhNgon({super.key, required this.textSearch});

  final String textSearch;

  @override
  State<TimKiemDanhNgon> createState() => _TimKiemDanhNgonState();
}

class _TimKiemDanhNgonState extends State<TimKiemDanhNgon> {
  final List<Quote> quotes = [
    Quote(
      text: "Sách là phép màu độc nhất và diệu kỳ trong đời thực.",
      author: "Stephen King",
      imageUrl: "assets/danhngon/img_2.png",
      likes: 20,
    ),
    Quote(
      text:
          "Đọc sách là một nghệ thuật tốt của, giàu trí tưởng tượng và cầu nối tri thức.",
      author: "Khaled Hosseini",
      imageUrl: "assets/danhngon/img_2.png",
      likes: 33,
    ),
    Quote(
      text:
          "Sách là bạn đồng hành tốt trong những lúc buồn chán, vui vẻ, và sách là con người.",
      author: "E.B White",
      imageUrl: "assets/danhngon/img_2.png",
      likes: 12,
    ),
  ];

  List<Quote> featuredQuotas = [
    Quote(
      text: "Đọc sách là một nghệ thuật",
      author: "Khaled Hosseini",
      imageUrl: "assets/danhngon/img_2.png",
      likes: 33,
    ),
    Quote(
      text: "Sách là bạn đồng hành",
      author: "E.B White",
      imageUrl: "assets/danhngon/img_2.png",
      likes: 12,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    // Filter quotes based on the search text
    final filteredQuotes = quotes.where((quote) {
      final text = quote.text.toLowerCase();
      final search = widget.textSearch.toLowerCase();
      return text.contains(search);
    }).toList();

    return SafeArea(
      child: Scaffold(
        body: widget.textSearch.isEmpty
            ? searchDefault()
            : filteredQuotes.isEmpty
                ? const Center(child: Text('Không tìm thấy danh ngôn',style: TextStyle(fontSize: 16),))
                : ListView.builder(
                    itemCount: filteredQuotes.length,
                    itemBuilder: (context, index) {
                      return QuoteCard(quote: filteredQuotes[index]);
                    },
                  ),
      ),
    );
  }

  Widget searchDefault() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildSectionTitle('Tìm kiếm nổi bật'),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildSearchList(featuredQuotas),
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchList(List<Quote> items) {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 2.0,
        children: items.map((item) {
          return Chip(
            label: Text(
              item.text,
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.green),
            ),
          );
        }).toList(),
      ),
    );
  }
}
