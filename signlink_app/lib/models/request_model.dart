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
        requestTime:
            DateTime.tryParse(j['eventTime'] as String? ?? '') ?? DateTime.now(),
        status: j['status'] as String,
        assignedInterpreterId: j['interpreterId'] as String?,
        notes: j['notes'] as String?,
      );

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';

  RequestModel copyWith({String? status}) => RequestModel(
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
      );
}
