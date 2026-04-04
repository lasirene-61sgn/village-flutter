class Staff {
  final int supportCategoryId;
  final String name;
  final String phone;
  final String image;

  Staff({
    required this.supportCategoryId,
    required this.name,
    required this.phone,
    required this.image,
  });

  /// JSON → Model
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      supportCategoryId: json['support_category_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'support_category_id': supportCategoryId,
      'name': name,
      'phone': phone,
      'image': image,
    };
  }

  /// copyWith
  Staff copyWith({
    int? supportCategoryId,
    String? name,
    String? phone,
    String? image,
  }) {
    return Staff(
      supportCategoryId: supportCategoryId ?? this.supportCategoryId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }
}
