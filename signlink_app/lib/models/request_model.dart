class RequestModel {
  final String id;
  final String studentId;
  final String studentName;
  final String requestType; // 'class' | 'event' | 'meeting'
  final String eventTitle;
  final String location;
  final DateTime requestDate;
  final DateTime requestTime;
  final String status; // 'pending' | 'approved' | 'declined' | 'completed'
  final String? assignedInterpreterId;
  final String? notes;
  final bool isRated;

  const RequestModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.requestType,
    required this.eventTitle,
    required this.location,
    required this.requestDate,
    required this.requestTime,
    required this.status,
    this.assignedInterpreterId,
    this.notes,
    this.isRated = false,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map) => RequestModel(
        id: map['id'] as String,
        studentId: map['student_id'] as String,
        studentName: map['student_name'] as String,
        requestType: map['request_type'] as String,
        eventTitle: map['event_title'] as String,
        location: map['location'] as String,
        requestDate: DateTime.parse(map['request_date'] as String),
        requestTime: DateTime.parse(map['request_time'] as String),
        status: map['status'] as String,
        assignedInterpreterId: map['assigned_interpreter_id'] as String?,
        notes: map['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'student_id': studentId,
        'student_name': studentName,
        'request_type': requestType,
        'event_title': eventTitle,
        'location': location,
        'request_date': requestDate.toIso8601String(),
        'request_time': requestTime.toIso8601String(),
        'status': status,
        'assigned_interpreter_id': assignedInterpreterId,
        'notes': notes,
      };

  /// Construct from the REST API JSON response.
  /// API fields: id, studentId, interpreterId, requestType, eventTitle,
  ///              location, eventDate, eventTime, notes, status, createdAt
  factory RequestModel.fromJson(Map<String, dynamic> j) => RequestModel(
        id: j['id'] as String,
        studentId: j['studentId'] as String,
        studentName: (j['student'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        requestType: j['requestType'] as String,
        eventTitle: j['eventTitle'] as String,
        location: j['location'] as String,
        requestDate:
            DateTime.tryParse(j['eventDate'] as String? ?? '') ?? DateTime.now(),
        requestTime: _parseTime(j['eventTime'] as String?),
        status: j['status'] as String,
        assignedInterpreterId: j['interpreterId'] as String?,
        notes: j['notes'] as String?,
        isRated: (j['isRated'] as bool?) ?? false,
      );

  /// Parses a MySQL TIME string like "09:00:00" into a DateTime on today's date,
  /// or falls back to DateTime.now() if parsing fails.
  static DateTime _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return DateTime.now();
    return DateTime.tryParse('1970-01-01T$timeStr') ?? DateTime.now();
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isCompleted => status == 'completed';
  bool get canRate => isCompleted && !isRated && assignedInterpreterId != null;

  RequestModel copyWith({String? status, bool? isRated}) => RequestModel(
        id: id,
        studentId: studentId,
        studentName: studentName,
        requestType: requestType,
        eventTitle: eventTitle,
        location: location,
        requestDate: requestDate,
        requestTime: requestTime,
        status: status ?? this.status,
        assignedInterpreterId: assignedInterpreterId,
        notes: notes,
        isRated: isRated ?? this.isRated,
      );
}
