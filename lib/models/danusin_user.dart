class DanusinUser {
  final String id;
  final String email;
  final String? username;
  final String name;
  final String? phone;
  final bool emailVisibility;
  final bool verified;
  final String? avatar;
  final Location? location;
  final List<String> userOrganization;
  final bool isDanuser;
  final String? bio;
  final String? locationAddress;
  final bool emailNotifications;
  final bool marketingEmails;
  final DateTime created;
  final DateTime updated;

  DanusinUser({
    required this.id,
    required this.email,
    this.username,
    required this.name,
    this.phone,
    required this.emailVisibility,
    required this.verified,
    this.avatar,
    this.location,
    required this.userOrganization,
    required this.isDanuser,
    this.bio,
    this.locationAddress,
    required this.emailNotifications,
    required this.marketingEmails,
    required this.created,
    required this.updated,
  });

  factory DanusinUser.fromJson(Map<String, dynamic> json) {
    return DanusinUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      name: json['name'] ?? '',
      phone: json['phone'],
      emailVisibility: json['emailVisibility'] ?? false,
      verified: json['verified'] ?? false,
      avatar: json['avatar'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      userOrganization: List<String>.from(json['user_organization'] ?? []),
      isDanuser: json['isdanuser'] ?? false,
      bio: json['bio'],
      locationAddress: json['location_address'],
      emailNotifications: json['email_notifications'] ?? false,
      marketingEmails: json['marketing_emails'] ?? false,
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'phone': phone,
      'emailVisibility': emailVisibility,
      'verified': verified,
      'avatar': avatar,
      'location': location?.toJson(),
      'user_organization': userOrganization,
      'isdanuser': isDanuser,
      'bio': bio,
      'location_address': locationAddress,
      'email_notifications': emailNotifications,
      'marketing_emails': marketingEmails,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  String getAvatarUrl(String baseUrl) {
    if (avatar != null && avatar!.isNotEmpty) {
      return '$baseUrl/api/files/danusin_users/$id/$avatar';
    }
    return '';
  }
}

class Location {
  final double lat;
  final double lon;

  Location({
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}
