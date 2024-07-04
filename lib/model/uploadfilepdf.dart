class MediaFile {
  int? id;
  String name;
  String? alternativeText;
  String? caption;
  int? width;
  int? height;
  Map<String, dynamic>? formats;
  String hash;
  String ext;
  String mime;
  double size;
  String url;
  String? previewUrl;
  String provider;
  dynamic providerMetadata;
  DateTime createdAt;
  DateTime updatedAt;

  MediaFile({
    this.id,
    required this.name,
    this.alternativeText,
    this.caption,
    this.width,
    this.height,
    this.formats,
    required this.hash,
    required this.ext,
    required this.mime,
    required this.size,
    required this.url,
    this.previewUrl,
    required this.provider,
    this.providerMetadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'],
      name: json['name'] ?? '', // Giả sử 'name' là thuộc tính ở mức cao nhất trong JSON
      alternativeText: json['alternativeText'],
      caption: json['caption'],
      width: json['width'],
      height: json['height'],
      formats: json['formats'],
      hash: json['hash'] ?? '',
      ext: json['ext'] ?? '',
      mime: json['mime'] ?? '',
      size: json['size'] ?? 0.0,
      url: json['url'] ?? '',
      previewUrl: json['previewUrl'],
      provider: json['provider'] ?? '',
      providerMetadata: json['provider_metadata'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alternativeText': alternativeText,
      'caption': caption,
      'width': width,
      'height': height,
      'formats': formats,
      'hash': hash,
      'ext': ext,
      'mime': mime,
      'size': size,
      'url': url,
      'previewUrl': previewUrl,
      'provider': provider,
      'provider_metadata': providerMetadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  @override
  String toString() {
    return 'MediaFile(id: $id, name: $name, url: $url)';
  }
}
