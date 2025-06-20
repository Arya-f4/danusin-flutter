class DanusinProductDetail {
  final String id;
  final String? idProduct;
  final double? tinggi;
  final double? lebar;
  final double? berat;
  final String? alatBahan;
  final String? petunjukPenyimpanan;
  final DateTime created;
  final DateTime updated;

  DanusinProductDetail({
    required this.id,
    this.idProduct,
    this.tinggi,
    this.lebar,
    this.berat,
    this.alatBahan,
    this.petunjukPenyimpanan,
    required this.created,
    required this.updated,
  });

  factory DanusinProductDetail.fromJson(Map<String, dynamic> json) {
    return DanusinProductDetail(
      id: json['id'] ?? '',
      idProduct: json['id_product'],
      tinggi: json['tinggi']?.toDouble(),
      lebar: json['lebar']?.toDouble(),
      berat: json['berat']?.toDouble(),
      alatBahan: json['alat_bahan'],
      petunjukPenyimpanan: json['petunjuk_penyimpanan'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_product': idProduct,
      'tinggi': tinggi,
      'lebar': lebar,
      'berat': berat,
      'alat_bahan': alatBahan,
      'petunjuk_penyimpanan': petunjukPenyimpanan,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
