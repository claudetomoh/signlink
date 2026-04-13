class ScheduleModel {
  final String id;
  final String studentId;
  final String? interpreterId;
  final String courseName;
  final String courseCode;
  final String location;
  final DateTime scheduleDate;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending' | 'confirmed' | 'cancelled' | 'completed'
  final String? interpreterName;
  final bool isRated;

  const ScheduleModel({
    required this.id,
    required this.studentId,
    this.interpreterId,
    required this.courseName,
    required this.courseCode,
    required this.location,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.interpreterName,
    this.isRated = false,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) => ScheduleModel(
        id: map['id'] as String,
        studentId: map['student_id'] as String,
        interpreterId: map['interpreter_id'] as String?,
        courseName: map['course_name'] as String,
        courseCode: map['course_code'] as String,
        location: map['location'] as String,
        scheduleDate: DateTime.parse(map['schedule_date'] as String),
        startTime: DateTime.parse(map['start_time'] as String),
        endTime: DateTime.parse(map['end_time'] as String),
        status: map['status'] as String,
        interpreterName: map['interpreter_name'] as String?,
        isRated: (map['is_rated'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'student_id': studentId,
        'interpreter_id': interpreterId,
        'course_name': courseName,
        'course_code': courseCode,
        'location': location,
        'schedule_date': scheduleDate.toIso8601String(),
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'status': status,
        'interpreter_name': interpreterName,
        'is_rated': isRated ? 1 : 0,
      };

  ScheduleModel copyWith({bool? isRated}) => ScheduleModel(
        id: id,
        studentId: studentId,
        interpreterId: interpreterId,
        courseName: courseName,
        courseCode: courseCode,
        location: location,
        scheduleDate: scheduleDate,
        startTime: startTime,
        endTime: endTime,
        status: status,
        interpreterName: interpreterName,
        isRated: isRated ?? this.isRated,
      );

  /// Construct from the REST API JSON response (requests used as schedule source).
  factory ScheduleModel.fromJson(Map<String, dynamic> j) {
    // event_date is DATE (YYYY-MM-DD), event_time is TIME (HH:MM:SS).
    // Combine them into a full DateTime for startTime/endTime.
    final dateStr = j['eventDate'] as String? ?? '';
    final timeStr = j['eventTime'] as String? ?? '';
    final scheduleDate = DateTime.tryParse(dateStr) ?? DateTime.now();
    DateTime startTime;
    if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
      startTime = DateTime.tryParse('${dateStr}T$timeStr') ?? scheduleDate;
    } else {
      startTime = scheduleDate;
    }
    return ScheduleModel(
      id: j['id'] as String,
      studentId: j['studentId'] as String,
      interpreterId: j['interpreterId'] as String?,
      courseName: j['eventTitle'] as String,
      courseCode: (j['requestType'] as String?) ?? '',
      location: j['location'] as String,
      scheduleDate: scheduleDate,
      startTime: startTime,
      endTime: startTime.add(const Duration(hours: 1)),
      status: j['status'] as String,
      interpreterName:
          (j['interpreter'] as Map<String, dynamic>?)?['name'] as String?,
      isRated: (j['is_rated'] as int? ?? 0) == 1,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduleDate.year == now.year &&
        scheduleDate.month == now.month &&
        scheduleDate.day == now.day;
  }

  bool get hasInterpreter => interpreterId != null;

  bool get canRate => status == 'completed' && hasInterpreter && !isRated;
}
