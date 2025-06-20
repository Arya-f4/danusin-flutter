class DanusinReview {
  final String id;
  final String? danuser;
  final String? danus;
  final double? rating;
  final String? comment;
  final DateTime created;
  final DateTime updated;

  DanusinReview({
    required this.id,
    this.danuser,
    this.danus,
    this.rating,
    this.comment,
    required this.created,
    required this.updated,
  });

  factory DanusinReview.fromJson(Map<String, dynamic> json) {
    return DanusinReview(
      id: json['id'] ?? '',
      danuser: json['danuser'],
      danus: json['danus'],
      rating: json['rating']?.toDouble(),
      comment: json['comment'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'danuser': danuser,
      'danus': danus,
      'rating': rating,
      'comment': comment,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
