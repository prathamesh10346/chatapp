class AttachmentModel {
  final String id;
  final String url;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  AttachmentModel({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.thumbnailUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
    };
  }

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'],
      url: json['url'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      thumbnailUrl: json['thumbnailUrl'],
      metadata: json['metadata'],
    );
  }
}