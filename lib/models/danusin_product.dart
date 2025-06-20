class DanusinProduct {
  final String id;
  final List<String> productImage;
  final String? productName;
  final String? description;
  final List<String> catalog;
  final String? slug;
  final String? byOrganization;
  final String? addedBy;
  final double? price;
  final double? discount;
  final DateTime created;
  final DateTime updated;

  DanusinProduct({
    required this.id,
    required this.productImage,
    this.productName,
    this.description,
    required this.catalog,
    this.slug,
    this.byOrganization,
    this.addedBy,
    this.price,
    this.discount,
    required this.created,
    required this.updated,
  });

  factory DanusinProduct.fromJson(Map<String, dynamic> json) {
    return DanusinProduct(
      id: json['id'] ?? '',
      productImage: List<String>.from(json['product_image'] ?? []),
      productName: json['product_name'],
      description: json['description'],
      catalog: List<String>.from(json['catalog'] ?? []),
      slug: json['slug'],
      byOrganization: json['by_organization'],
      addedBy: json['added_by'],
      price: json['price']?.toDouble(),
      discount: json['discount']?.toDouble(),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_image': productImage,
      'product_name': productName,
      'description': description,
      'catalog': catalog,
      'slug': slug,
      'by_organization': byOrganization,
      'added_by': addedBy,
      'price': price,
      'discount': discount,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  List<String> getImageUrls(String baseUrl) {
    return productImage.map((image) => '$baseUrl/api/files/danusin_product/$id/$image').toList();
  }

  String? getFirstImageUrl(String baseUrl) {
    if (productImage.isNotEmpty) {
      return '$baseUrl/api/files/danusin_product/$id/${productImage.first}';
    }
    return null;
  }

  double get finalPrice {
    if (price == null) return 0.0;
    if (discount == null || discount == 0) return price!;
    return price! - (price! * discount! / 100);
  }
}
