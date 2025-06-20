class DanusinKeyword {
  final String id;
  final String? name;
  final String? createdBy;
  final DateTime created;
  final DateTime updated;

  DanusinKeyword({
    required this.id,
    this.name,
    this.createdBy,
    required this.created,
    required this.updated,
  });

  factory DanusinKeyword.fromJson(Map<String, dynamic> json) {
    return DanusinKeyword(
      id: json['id'] ?? '',
      name: json['name'],
      createdBy: json['created_by'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
