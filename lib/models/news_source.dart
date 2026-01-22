class NewsSource {
  NewsSource({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.enabled,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String sourceType;
  final bool enabled;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'] as int,
      name: json['name'] as String,
      sourceType: json['sourceType'] as String,
      enabled: json['enabled'] as bool,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sourceType': sourceType,
      'enabled': enabled,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
