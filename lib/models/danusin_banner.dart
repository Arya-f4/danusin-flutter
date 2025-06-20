class DanusinBanner {
  final String id;
  final String? title;
  final String? description;
  final String? image;
  final String? link;
  final int? order;
  final bool isActive;
  final DateTime created;
  final DateTime updated;

  DanusinBanner({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.link,
    this.order,
    required this.isActive,
    required this.created,
    required this.updated,
  });

  factory DanusinBanner.fromJson(Map<String, dynamic> json) {
    return DanusinBanner(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      image: json['image'],
      link: json['link'],
      order: json['order']?.toInt(),
      isActive: json['is_active'] ?? false,
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'link': link,
      'order': order,
      'is_active': isActive,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  String getImageUrl(String baseUrl) {
    if (image != null && image!.isNotEmpty) {
      return '$baseUrl/api/files/danusin_banners/$id/$image';
    }
    return '';
  }
}
