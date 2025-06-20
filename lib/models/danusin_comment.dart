enum CommentStatus { pending, approved, rejected }

class DanusinComment {
  final String id;
  final String? content;
  final String? byUser;
  final String? product;
  final String? parent;
  final CommentStatus? status;
  final DateTime created;
  final DateTime updated;

  DanusinComment({
    required this.id,
    this.content,
    this.byUser,
    this.product,
    this.parent,
    this.status,
    required this.created,
    required this.updated,
  });

  factory DanusinComment.fromJson(Map<String, dynamic> json) {
    return DanusinComment(
      id: json['id'] ?? '',
      content: json['content'],
      byUser: json['by_user'],
      product: json['product'],
      parent: json['parent'],
      status: _parseStatus(json['status']),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  static CommentStatus? _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return CommentStatus.pending;
      case 'approved':
        return CommentStatus.approved;
      case 'rejected':
        return CommentStatus.rejected;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'by_user': byUser,
      'product': product,
      'parent': parent,
      'status': status?.name,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
