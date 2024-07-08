import 'dart:io';

import 'package:app_doc_sach/model/gia_han_goi_model.dart';
import 'package:app_doc_sach/payment_config.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
class GiaHanGoi extends StatefulWidget {
  const GiaHanGoi({super.key});

  @override
  State<GiaHanGoi> createState() => GiaHanGoiState();
}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GiaHanGoi(),
    );
  }
}
class GiaHanGoiState extends State<GiaHanGoi> {
  String os = Platform.operatingSystem;
  var applePayButton = ApplePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
    paymentItems: const[
      PaymentItem(
        label: 'Item A',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      ),
      PaymentItem(
        label: 'Item B',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      ),
      PaymentItem(
        label: 'Total',
        amount: '0.02',
        status: PaymentItemStatus.final_price,
      ),
    ],
    style: ApplePayButtonStyle.black,
    width: double.infinity,
    height: 50,
    type: ApplePayButtonType.buy,
    margin: const EdgeInsets.only(top: 15.0),
    onPaymentResult: (result) => debugPrint('Kết quả thanh toán $result'),
    loadingIndicator: const Center(child: CircularProgressIndicator()),
  );
  var googlePayButton = GooglePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
    paymentItems: const[
      PaymentItem(
        label: 'Item A',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      ),
      PaymentItem(
        label: 'Item B',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      ),
      PaymentItem(
        label: 'Total',
        amount: '0.02',
        status: PaymentItemStatus.final_price,
      ),
    ],
    width: double.infinity,
    type: GooglePayButtonType.pay,
    margin: const EdgeInsets.only(top: 15.0),
    onPaymentResult: (result) => debugPrint('Kết quả thanh toán $result'),
    loadingIndicator: const Center(child: CircularProgressIndicator()),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0),
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
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Image.asset('assets/icon/vip.png',
                  width: 64,
                  height: 64,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent, // Bỏ màu nền của AppBar
        elevation: 0, // Bỏ đổ bóng của AppBar
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: const <TextSpan>[
                          TextSpan(
                            text: 'Mua gói ',
                          ),
                          TextSpan(
                            text: 'Xóa quảng cáo',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                ' để ủng hộ kinh phí duy trì và\nphát triển ứng dụng.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //List Xóa quảng cáo
              const SizedBox(height: 20),
              Column(
                children: subscriptions.map((subscription) => Theme(
                  data: ThemeData(
                    brightness: Brightness.dark,
                  ),
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors
                                        .black // Light mode text color
                                    : Colors
                                        .white, // Dark mode text color
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: subscription.features
                                .map((feature) => Text(
                                  feature,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? Colors
                                            .black // Light mode text color
                                        : Colors
                                            .white, // Dark mode text color
                                  ),
                                )).toList(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              subscription.price,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors
                                        .black // Light mode text color
                                    : Colors
                                        .white, // Dark mode text color
                              ),
                            ),
                            const SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
                                if (Platform.isAndroid) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return googlePayButton;
                                    },
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return applePayButton;
                                    },
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Đăng ký',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? Colors
                                              .black // Light mode text color
                                          : Colors
                                              .white, // Dark mode text color
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? Colors
                                            .black // Light mode icon color
                                        : Colors
                                            .white, // Dark mode icon color
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),

              //Thông tin Xóa quảng cáo
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: const <TextSpan>[
                    TextSpan(
                        text: '* ',
                        style: TextStyle(
                            color: Colors.red)
                    ),
                    TextSpan(
                      text: 'Các gói ',
                    ),
                    TextSpan(
                      text: 'Xóa quảng cáo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' đã bao gồm phí kênh ',
                    ),
                    TextSpan(text: 'thanh toán.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: const <TextSpan>[
                    TextSpan(
                        text: '* ',
                        style: TextStyle(
                            color: Colors.red)
                    ), // Ký hiệu * được đặt màu đỏ
                    TextSpan(
                      text: 'Thanh toán sẽ được tính cho tài khoản ',
                    ),
                    TextSpan(
                      text: 'Google Play',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' của bạn khi bạn xác thực mua hàng. Gia hạn tự động sẽ được thực hiện nếu bạn không hủy ít nhất 24 giờ trước khi chu kỳ hiện tại kết thúc. Tài khoản của bạn sẽ được tính phí gia hạn trong vòng 24 giờ trước khi kết thúc chu kỳ hiện tại. Bạn có thể quản lý và hủy gia hạn bằng cách truy cập mục Cài đặt tài khoản trên ',
                    ),
                    TextSpan(
                      text: 'Google Play',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' sau khi thanh toán.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: const <TextSpan>[
                    TextSpan(
                        text: '* ',
                        style: TextStyle(color: Colors.red)), // Ký hiệu * được đặt màu đỏ
                    TextSpan(
                      text: 'Google có thể hoàn lại tiền cho một số giao dịch mua trên ',
                    ),
                    TextSpan(
                      text: 'Google Play',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ', hãy xem tại ',
                    ),
                    TextSpan(
                      text: 'chính sách hoàn lại tiền',
                      style: TextStyle(
                        color: Colors.orange,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.orange,
                      ),
                    ),
                    TextSpan(
                      text: '. Bạn cũng có thể liên hệ trực tiếp với nhà phát triển.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//Danh sách list Xóa quảng cáo
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

