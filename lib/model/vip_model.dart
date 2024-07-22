import 'package:app_doc_sach/model/user_model.dart';

class Vip {
  final int id;
  final Users? profile;
  late final DateTime dayStart;
  DateTime dayEnd;
  late final bool status;

  Vip({
    required this.id,
    this.profile,
    required this.dayStart,
    required this.dayEnd,
    required this.status,
  });

  factory Vip.fromJson(Map<String, dynamic> json) {
    return Vip(
      id: json['id'] ?? 0,
      profile: json['profile'] != null ? Users.fromJson(json['profile']) : null,
      dayStart: DateTime.parse(json['dayStart']),
      dayEnd: DateTime.parse(json['dayEnd']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profile': profile?.toJson(),
    'dayStart': dayStart.toIso8601String(),
    'dayEnd': dayEnd.toIso8601String(),
    'status': status,
  };

  void extend(Duration duration) {
    final now = DateTime.now();
    if (!status || dayEnd.isBefore(now)) {
      // If status is false or VIP has expired, reset start date and calculate new end date
      dayStart = now;
      dayEnd = now.add(duration);
      status = true;
    } else {
      // If VIP is still active, just extend the end date
      dayEnd = dayEnd.add(duration);
    }
  }
}