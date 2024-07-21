import 'dart:io';

import 'package:app_doc_sach/page/page_tab_taikhoanwidget/viptimer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:app_doc_sach/payment_config.dart';
import '../../controller/auth_controller.dart';
import '../../controller/vip_controller.dart';
import '../../controller/vip_controller.dart';
import '../../model/gia_han_goi_model.dart';  // Ensure the correct import here
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../model/user_model.dart';
import '../../model/vip_model.dart';
import '../../service/local_service/local_auth_service.dart';
import '../../service/remote_auth_service.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gia Hạn Gói',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GiaHanGoi(),
    );
  }
}

class GiaHanGoi extends StatefulWidget {
  const GiaHanGoi({Key? key}) : super(key: key);

  @override
  State<GiaHanGoi> createState() => _GiaHanGoiState();
}

class _GiaHanGoiState extends State<GiaHanGoi> {
  String os = Platform.operatingSystem;
  final VipService _vipController = Get.find<VipService>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // Đặt chiều cao của AppBar
          child: AppBar(
            iconTheme: IconThemeData(size: 30),
            title: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Text(
                    'XÓA QUẢNG CÁO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Image.asset(
                      'assets/icon/vip.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.clock),
                onPressed: ()  async {
                  final LocalAuthService _localAuthService = LocalAuthService();
                  AuthController authController = Get.find();
                  await _localAuthService.init(); // Ensure initialization
                  String? token = _localAuthService.getToken();
                  if (token == null) {
                    throw Exception("Token is not available");
                  }

                  String userEmail = authController.user.value?.email ?? '';
                  if (userEmail.isEmpty || token.isEmpty) {
                    print('Email or token is empty.');
                    return;
                  }

                  var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
                  if (userId == null) {
                    print('User not found for email: $userEmail');
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 200, // Chiều cao tùy ý
                          child: VipTimerWidget(userId: userId),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'CHỌN GÓI CỦA BẠN',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: const <TextSpan>[
                            TextSpan(text: 'Mua gói ',style: TextStyle(fontSize: 15)),
                            TextSpan(
                              text: 'Xóa quảng cáo',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                            ),
                            TextSpan(
                              text: ' để ủng hộ kinh phí duy trì và\nphát triển ứng dụng.',style: TextStyle(fontSize: 15)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Column(
                  children: subscriptions.map((subscription) => _buildSubscriptionCard(subscription)).toList(),
                ),
                const SizedBox(height: 20),
                _buildInfoText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: subscription.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.duration,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subscription.features
                      .map((feature) => Text(
                    feature,
                    style: const TextStyle(color: Colors.black),
                  ))
                      .toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  subscription.price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _showPaymentSheet(subscription),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(SubscriptionModel subscription) {
    final LocalAuthService _localAuthService = LocalAuthService();
    AuthController authController = Get.find();
    if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return GooglePayButton(
            paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
            paymentItems: [
              PaymentItem(
                label: subscription.duration,
                amount: subscription.priceAsNumber,
                status: PaymentItemStatus.final_price,
              ),
            ],
            width: double.infinity,
            type: GooglePayButtonType.pay,
            margin: const EdgeInsets.only(top: 15.0),
            onPaymentResult: (result) async {
              debugPrint('Kết quả thanh toán $result');
              // Assume payment is successful
              try {
                // Get the current user (you need to implement this)
                await _localAuthService.init(); // Ensure initialization

                String? token = _localAuthService.getToken();
                if (token == null) {
                  throw Exception("Token is not available");
                }

                String userEmail = authController.user.value?.email ?? '';
                if (userEmail.isEmpty || token.isEmpty) {
                  print('Email or token is empty.');
                  return;
                }

                var userId = await RemoteAuthService().getUserIdByEmail(userEmail, token);
                if (userId == null) {
                  print('User not found for email: $userEmail');
                  return;
                }
                await VipService.extendVip(userId, subscription.duration);

                // Show success dialog
                Future.delayed(Duration(milliseconds: 200), () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.bottomSlide,
                    title: 'Thông báo',
                    desc: 'Gia hạn VIP thành công!',
                    btnOkText: 'Đóng',
                    btnOkOnPress: () {
                      Navigator.pop(context);
                    },
                  ).show();
                });
              } catch (e) {
                print('Error extending VIP: $e');
                // Show error dialog
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.bottomSlide,
                  title: 'Lỗi',
                  desc: 'Có lỗi xảy ra khi gia hạn VIP. Vui lòng thử lại sau.',
                  btnOkText: 'Đóng',
                  btnOkOnPress: () {},
                ).show();
              }
            },
            loadingIndicator: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ApplePayButton(
            paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
            paymentItems: [
              PaymentItem(
                label: subscription.duration,
                amount: subscription.priceAsNumber,
                status: PaymentItemStatus.final_price,
              ),
            ],
            style: ApplePayButtonStyle.black,
            width: double.infinity,
            height: 50,
            type: ApplePayButtonType.buy,
            margin: const EdgeInsets.only(top: 15.0),
            onPaymentResult: (result) {
              debugPrint('Kết quả thanh toán $result');
            },
            loadingIndicator: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
  }

  Widget _buildInfoText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: '* ', style: TextStyle(color: Colors.red, fontSize: 15)),
              TextSpan(text: 'Các gói ',style: TextStyle( fontSize: 15)),
              TextSpan(text: 'Xóa quảng cáo', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              TextSpan(text: ' đã bao gồm phí kênh thanh toán.',style: TextStyle( fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: '* ', style: TextStyle(color: Colors.red,fontSize: 15)),
              TextSpan(text: 'Thanh toán sẽ được tính cho tài khoản ',style: TextStyle( fontSize: 15)),
              TextSpan(text: 'Google Play', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              TextSpan(style: TextStyle( fontSize: 15),text: ' của bạn khi bạn xác thực mua hàng. Gia hạn tự động sẽ được thực hiện nếu bạn không hủy ít nhất 24 giờ trước khi chu kỳ hiện tại kết thúc. Tài khoản của bạn sẽ được tính phí gia hạn trong vòng 24 giờ trước khi kết thúc chu kỳ hiện tại. Bạn có thể quản lý và hủy gia hạn bằng cách truy cập mục Cài đặt tài khoản trên '),
              TextSpan(text: 'Google Play', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              TextSpan(text: ' sau khi thanh toán.',style: TextStyle( fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: '* ', style: TextStyle(color: Colors.red,fontSize: 15)),
              TextSpan(style: TextStyle( fontSize: 15),text: 'Google có thể hoàn lại tiền cho một số giao dịch mua trên '),
              TextSpan(text: 'Google Play', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              TextSpan(style: TextStyle( fontSize: 15),text: ', hãy xem tại '),
              TextSpan(
                text: 'chính sách hoàn lại tiền',
                style: TextStyle(
                  color: Colors.orange,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.orange,
                  fontSize: 15
                ),
              ),
              TextSpan(style: TextStyle( fontSize: 15),text: '. Bạn cũng có thể liên hệ trực tiếp với nhà phát triển.'),
            ],
          ),
        ),
        const SizedBox(height: 30,)
      ],
    );
  }
}

List<SubscriptionModel> subscriptions = [
  SubscriptionModel(
    duration: '1 TUẦN',
    price: '10.000đ',
    color: Colors.teal,
    features: ['✓ Không quảng cáo', '✓ Không giới hạn tính năng'],
  ),
  SubscriptionModel(
    duration: '1 THÁNG',
    price: '49.000đ',
    color: Colors.amber,
    features: ['✓ Không quảng cáo', '✓ Không giới hạn tính năng'],
  ),
  SubscriptionModel(
    duration: '6 THÁNG',
    price: '99.000đ',
    color: Colors.redAccent,
    features: ['✓ Không quảng cáo', '✓ Không giới hạn tính năng'],
  ),
  SubscriptionModel(
    duration: '1 NĂM',
    price: '149.000đ',
    color: Colors.cyan,
    features: ['✓ Không quảng cáo', '✓ Không giới hạn tính năng'],
  ),
];

