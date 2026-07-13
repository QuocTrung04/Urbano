class VaiTro {
  final int id;
  final String tenVaiTro;

  VaiTro({required this.id, required this.tenVaiTro});

  factory VaiTro.fromJson(Map<String, dynamic> json) {
    return VaiTro(
      id: json['id'] ?? 0,
      tenVaiTro: json['tenVaiTro'] ?? '',
    );
  }
}
