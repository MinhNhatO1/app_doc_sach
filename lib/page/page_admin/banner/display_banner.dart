import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_doc_sach/controller/banner_controller.dart';
import 'package:app_doc_sach/model/banner_model.dart';
import 'package:app_doc_sach/page/page_admin/banner/banner_detail.dart';
import 'package:app_doc_sach/page/page_admin/banner/create_banner.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../const.dart';
import '../../../const/constant.dart';

class DisplayBanner extends StatefulWidget {
  const DisplayBanner({Key? key}) : super(key: key);

  @override
  State<DisplayBanner> createState() => _DisplayBannerState();
}

class _DisplayBannerState extends State<DisplayBanner> {
  final BannerController _bannerController = Get.put(BannerController());
  Timer? _timer;
  Future<List<Banner_Model>>? _bannersFuture;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    _bannersFuture = _bannerController.fetchBanners();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        // Update the Future to trigger a rebuild and reload the banners
        _bannersFuture = _bannerController.fetchBanners();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const SideWidgetMenu(),
      appBar: AppBar(
        title: const Text('Quản lý Banner', style: TextStyle(color: Colors.white)),
        elevation: 0.0,
        backgroundColor: backgroundColor,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: secondaryColor,
                backgroundColor: primaryColor, // Using the custom secondaryColor
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateBannerPage()),
                );
                if (result == true) {
                  // If a new banner is created, refresh the list
                  setState(() {
                    _bannersFuture = _bannerController.fetchBanners();
                  });
                }
              },
              child: const Text('Thêm'),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Banner_Model>>(
        future: _bannersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No banners available'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final banner = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BannerDetailPage(banner: banner),
                      ),
                    ).then((result) {
                      if (result == true) {
                        setState(() {
                          _bannersFuture = _bannerController.fetchBanners();
                        });
                      }
                    });
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Colors.grey, // Màu sắc của viền
                        width: 2, // Độ dày của viền
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                            child: CachedNetworkImage(
                              imageUrl: baseUrl + banner.imageBanner!.url ?? '',
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Banner ID: ${banner.id}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image Name: ${banner.imageBanner?.name ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
