import 'package:flutter/material.dart';

class SubscriptionModel {
  final String duration;
  final String price;
  final Color color;
  final List<String> features;

  SubscriptionModel({
    required this.duration,
    required this.price,
    required this.color,
    required this.features,
  });

  // Thêm phương thức này
  String get priceAsNumber {
    return price.replaceAll('.', '').replaceAll('đ', '');
  }
}
