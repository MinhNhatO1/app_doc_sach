import 'package:intl/intl.dart';

class Author {
  int id;
   String authorName;
  DateTime? birthDate;
  String born;
  String telphone;
  String nationality;
  String bio;

  Author({
    required this.id,
    required this.authorName,
    required this.birthDate,
    required this.born,
    required this.telphone,
    required this.nationality,
    required this.bio,
  });
  factory Author.fromJson(Map<String, dynamic> json) {
    DateTime? parsedBirthDate;
    if (json['attributes']['birthDate'] != null) {
      parsedBirthDate = DateTime.parse(json['attributes']['birthDate']);
    }
    return Author(
      id: json['id'],
      authorName: json['attributes']['authorName'] ?? '',
      birthDate: parsedBirthDate, // Điều này sẽ cho phép birthDate có thể là null
      born: json['attributes']['born'] ?? '',
      telphone: json['attributes']['telephone'] ?? '',
      nationality: json['attributes']['nationality'] ?? '',
      bio: json['attributes']['bio'] ?? '',
    );
  }

  @override
  String toString() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formattedBirthDate = birthDate != null ? formatter.format(birthDate!) : 'null';
    return 'Author(id: $id, authorName: $authorName, birthDate: $formattedBirthDate, born: $born, telphone: $telphone, nationality: $nationality, bio: $bio)';
  }

}
