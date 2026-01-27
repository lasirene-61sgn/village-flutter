class AppNotification {
  final String type;
  final String title;
  final String message;
  final NotificationData? data;
  final DateTime? createdAt;

  const AppNotification({
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.createdAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? NotificationData.fromJson(json['data'])
          : null,
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class NotificationData {
  final int id;
  final int adminId;
  final String name;
  final String description;
  final List<String> imagePaths;
  final DateTime? postedDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationData({
    required this.id,
    required this.adminId,
    required this.name,
    required this.description,
    required this.imagePaths,
    required this.status,
    this.postedDate,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imagePaths: (json['image_paths'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      postedDate: _parseDate(json['posted_date']),
      status: json['status']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

