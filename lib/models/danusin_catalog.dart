class DanusinCatalog {
  final String id;
  final String name;
  final String? description;
  final String? createdBy;
  final DateTime created;
  final DateTime updated;

  DanusinCatalog({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    required this.created,
    required this.updated,
  });

  factory DanusinCatalog.fromJson(Map<String, dynamic> json) {
    return DanusinCatalog(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdBy: json['created_by'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
