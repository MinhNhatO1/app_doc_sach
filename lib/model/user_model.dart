import "dart:convert";
import "package:hive/hive.dart";
part 'user_model.g.dart';
Users usersFromJson(String str) => Users.fromJson(json.decode(str));
@HiveType(typeId: 8)
class Users {
  @HiveField(0)
   int? id;
  @HiveField(1)
  String? email;
  @HiveField(2)
   String? fullName;
  @HiveField(3)
  String? phone;
  @HiveField(4)
  String? gender;
  @HiveField(5)
  String? address;
  @HiveField(6)
  DateTime? age;
  @HiveField(7)
  String? avatar;

  Users({
    this.id,
    this.email,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.address,
    required this.age,
    required this.avatar,
  });

  factory Users.fromJson(Map<String, dynamic> data) {
    return Users(
      id: data['id'] != null ? (data['id'] is String ? int.tryParse(data['id']) : data['id']) : null,
      fullName: data['fullName'] != null ? data['fullName'].toString() : 'N/A',
      email: data['email'] != null ? data['email'].toString() : 'N/A',
      phone: data['phone'] != null ? data['phone'].toString() : 'N/A',
      gender: data['gender'] != null ? data['gender'].toString() : 'N/A',
      address: data['address'] != null ? data['address'].toString() : 'N/A',
      age: data['age'] != null ? DateTime.tryParse(data['age']) : null,
      avatar: data['image'] != null ? data['image'].toString() : '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'age': age?.toIso8601String(),
      'avatar': avatar,
      'phone': phone,
      'gender': gender,
      'address': address,
    };
  }
  }
