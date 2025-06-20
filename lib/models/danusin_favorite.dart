class DanusinFavorite {
  final String id;
  final String? danusersId;
  final List<String> productsId;
  final DateTime created;
  final DateTime updated;

  DanusinFavorite({
    required this.id,
    this.danusersId,
    required this.productsId,
    required this.created,
    required this.updated,
  });

  factory DanusinFavorite.fromJson(Map<String, dynamic> json) {
    return DanusinFavorite(
      id: json['id'] ?? '',
      danusersId: json['danusers_id'],
      productsId: List<String>.from(json['products_id'] ?? []),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'danusers_id': danusersId,
      'products_id': productsId,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
