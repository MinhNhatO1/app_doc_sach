import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/product_phobien.dart';

class KhamPhaWidget extends StatefulWidget {
  const KhamPhaWidget({super.key});

  @override
  State<KhamPhaWidget> createState() => _KhamPhaWidgetState();
}

class _KhamPhaWidgetState extends State<KhamPhaWidget> {

  final List<String> imgList = [
    'https://bizweb.dktcdn.net/thumb/grande/100/468/779/themes/883715/assets/slider_3.jpg?1674889023980',
    'https://bizweb.dktcdn.net/thumb/large/100/222/758/articles/fb-tap-noi-tap-doc-1-01-01.jpg?v=1610358102210',
    'https://bizweb.dktcdn.net/100/222/758/themes/549028/assets/slider-img3.jpg?1708567836625'
  ];

  int _current = 0;
  final CarouselController _controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
              children: [
              CarouselSlider(
                items: imgList.map((item) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      item,
                      fit: BoxFit.cover,
                      width: 1000,
                    ),
                  ),
                )).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  height: 180,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
                carouselController: _controller,
              ),
              buildCarouseIndicator(),
              const SizedBox(height: 5,),
              const  Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sách phổ biến',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                slide()
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  buildCarouseIndicator(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: imgList.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _controller.animateToPage(entry.key),
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                    .withOpacity(_current == entry.key ? 0.9 : 0.4)),
          ),
        );
      }).toList(),
    );
  }

}

List<ProductPhobien> listProduct = [
  ProductPhobien(id: '1', tenSach: 'Mat Biec', theLoai: 'Tinh cam', image: 'assets/book/matbiec.png'),
  ProductPhobien(id: '2', tenSach: 'Thuy Kieu', theLoai: 'Tinh cam', image: 'assets/book/thuykieu.png'),
  ProductPhobien(id: '3', tenSach: 'No hoa sen', theLoai: 'Tinh cam', image: 'assets/book/nohoasen.png'),
];
Widget slide() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
    child: Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          autoPlay: true,
        ),
        items: listProduct.map((product) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: [
                  // Lớp mờ trong suốt
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1.0, color: Colors.black45),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  // Nội dung
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    height: 200,
                    width: 280,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.asset(
                                product.image,
                                height: 180,
                                width: 100,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 20, right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.tenSach,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Thể loại: ${product.theLoai}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    ),
  );
}

