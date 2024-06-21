import 'package:app_doc_sach/provider/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/product_phobien.dart';
import '../detail_book/detail_book.dart';

class NoiBatWidget extends StatefulWidget {
  const NoiBatWidget({super.key});

  @override
  State<NoiBatWidget> createState() => _NoiBatWidgetState();
}

List<ProductPhobien> listProduct = [
  ProductPhobien(
      id: '1',
      tenSach: 'Mắt biếc',
      theLoai: 'Tinh cam',
      image: 'assets/book/matbiec.png'),
  ProductPhobien(
      id: '2',
      tenSach: 'Truyện Kiều',
      theLoai: 'Tinh cam',
      image: 'assets/book/thuykieu.png'),
  ProductPhobien(
      id: '3',
      tenSach: 'Từng bước nở hoa sen',
      theLoai: 'Tinh cam',
      image: 'assets/book/nohosenbia2.png'),
  ProductPhobien(
      id: '4',
      tenSach: 'Từng bước nở hoa sen',
      theLoai: 'Tinh cam',
      image: 'assets/book/nohosenbia2.png'),
  ProductPhobien(
      id: '5',
      tenSach: 'Từng bước nở hoa sen',
      theLoai: 'Tinh cam',
      image: 'assets/book/nohosenbia2.png'),
  ProductPhobien(
      id: '6',
      tenSach: 'Từng bước nở hoa sen',
      theLoai: 'Tinh cam',
      image: 'assets/book/nohosenbia2.png'),
  ProductPhobien(
      id: '7',
      tenSach: 'Từng bước nở hoa sen',
      theLoai: 'Tinh cam',
      image: 'assets/book/nohosenbia2.png'),
  ProductPhobien(
      id: '8',
      tenSach: 'Từng bước nở hoa sen',
      theLoai: 'Tinh cam',
      image: 'assets/book/nohosenbia2.png'),
];

class _NoiBatWidgetState extends State<NoiBatWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UiProvider>(
      builder: (BuildContext context, UiProvider value, Widget? child) {
        return Scaffold(
          body: Container(
              color: value.isDark
                  ? Colors.black12
                  : const Color.fromRGBO(232, 245, 233, 1.0),
              child: gridview_noibat()),
        );
      },
    );
  }

  Widget gridview_noibat() {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.51,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          itemCount: listProduct.length,
          itemBuilder: (BuildContext context, index) {
            final product = listProduct[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailPage(product: product),
                  ),
                );
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Card(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                product.image,
                                fit: BoxFit.cover,
                                height: 160,
                                width: 120,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              left: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  product.theLoai,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product.tenSach,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tac Gia',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}
