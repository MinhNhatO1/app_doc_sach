import 'file_upload.dart';
class Banner_Model {
  final int id;
  final FileUpload? imageBanner;
  Banner_Model({required this.id, this.imageBanner});

  factory Banner_Model.fromJson(Map<String, dynamic> json) {
    return Banner_Model(
      id: json['id'],
      imageBanner: json['image_banner'] != null
          ? FileUpload.fromJson({
        'id': json['id'], // Thêm 'id' vào đây
        ...json['image_banner']['data']?[0]['attributes'] ?? {},
      }) : null,
    );
  }
}