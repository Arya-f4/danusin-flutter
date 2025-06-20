class DanusinOrganization {
  final String id;
  final String organizationName;
  final String? organizationImage;
  final String organizationSlug;
  final String? target;
  final double? targetProgress;
  final String? organizationDescription;
  final String? createdBy;
  final String? groupPhone;
  final DateTime created;
  final DateTime updated;

  DanusinOrganization({
    required this.id,
    required this.organizationName,
    this.organizationImage,
    required this.organizationSlug,
    this.target,
    this.targetProgress,
    this.organizationDescription,
    this.createdBy,
    this.groupPhone,
    required this.created,
    required this.updated,
  });

  factory DanusinOrganization.fromJson(Map<String, dynamic> json) {
    return DanusinOrganization(
      id: json['id'] ?? '',
      organizationName: json['organization_name'] ?? '',
      organizationImage: json['organization_image'],
      organizationSlug: json['organization_slug'] ?? '',
      target: json['target'],
      targetProgress: json['target_progress']?.toDouble(),
      organizationDescription: json['organization_description'],
      createdBy: json['created_by'],
      groupPhone: json['group_phone'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_name': organizationName,
      'organization_image': organizationImage,
      'organization_slug': organizationSlug,
      'target': target,
      'target_progress': targetProgress,
      'organization_description': organizationDescription,
      'created_by': createdBy,
      'group_phone': groupPhone,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  String? getImageUrl(String baseUrl) {
    if (organizationImage != null && organizationImage!.isNotEmpty) {
      return '$baseUrl/api/files/danusin_organization/$id/$organizationImage';
    }
    return null;
  }
}
