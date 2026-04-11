class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final int? capacity;
  final int? signedUpCount;
  final String createdBy;
  final bool isPast;
  final bool isSignedUp;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    this.capacity,
    this.signedUpCount,
    required this.createdBy,
    this.isPast = false,
    this.isSignedUp = false,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        date: DateTime.parse(map['date'] as String),
        location: map['location'] as String,
        imageUrl: map['image_url'] as String?,
        capacity: map['capacity'] as int?,
        signedUpCount: map['signed_up_count'] as int?,
        createdBy: map['created_by'] as String,
        isPast: (map['is_past'] as bool?) ?? false,
      );

  /// Construct from the REST API JSON response.
  /// API fields: id, title, description, location, date, capacity,
  ///              signedUpCount, imageUrl, isPast, isSignedUp
  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
        id: j['id'] as String,
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        date: DateTime.parse(j['date'] as String),
        location: j['location'] as String,
        imageUrl: j['imageUrl'] as String?,
        capacity: (j['capacity'] as num?)?.toInt(),
        signedUpCount: (j['signedUpCount'] as num?)?.toInt(),
        createdBy: (j['createdBy'] as String?) ?? '',
        isPast: (j['isPast'] as bool?) ?? false,
        isSignedUp: (j['isSignedUp'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'image_url': imageUrl,
        'capacity': capacity,
        'signed_up_count': signedUpCount,
        'created_by': createdBy,
        'is_past': isPast,
      };

  double get capacityPercent {
    if (capacity == null || capacity! == 0) return 0;
    return ((signedUpCount ?? 0) / capacity!).clamp(0.0, 1.0);
  }
}
