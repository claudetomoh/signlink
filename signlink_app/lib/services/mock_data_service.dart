import '../models/user_model.dart';
import '../models/schedule_model.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/request_model.dart';

/// Central mock data source — swap methods for real API calls when backend is ready.
class MockDataService {
  // ─── Users ───────────────────────────────────────────────────────────────
  static UserModel get currentStudent => const UserModel(
        id: 'student-01',
        fullName: 'Alex Johnson',
        email: 'alex.johnson@ashesi.edu.gh',
        role: 'student',
        profilePhoto: null,
        phone: '+233 20 123 4567',
      );

  static UserModel get currentInterpreter => const UserModel(
        id: 'interp-01',
        fullName: 'Kofi Mensah',
        email: 'kofi.mensah@ashesi.edu.gh',
        role: 'interpreter',
        phone: '+233 24 987 6543',
      );

  static UserModel get currentAdmin => const UserModel(
        id: 'admin-01',
        fullName: 'Dr. Sarah Asante',
        email: 'sarah.asante@ashesi.edu.gh',
        role: 'admin',
        phone: '+233 30 456 7890',
      );

  static List<UserModel> get allUsers => [
        currentStudent,
        const UserModel(id: 'student-02', fullName: 'Ama Owusu', email: 'ama.owusu@ashesi.edu.gh', role: 'student'),
        const UserModel(id: 'student-03', fullName: 'Kwame Asante', email: 'kwame.asante@ashesi.edu.gh', role: 'student'),
        currentInterpreter,
        const UserModel(id: 'interp-02', fullName: 'Abena Boateng', email: 'abena.boateng@ashesi.edu.gh', role: 'interpreter'),
        currentAdmin,
      ];

  static List<UserModel> get interpreters =>
      allUsers.where((u) => u.role == 'interpreter').toList();

  // ─── Schedules ───────────────────────────────────────────────────────────
  static List<ScheduleModel> get studentSchedules {
    final base = DateTime.now();
    return [
      ScheduleModel(
        id: 'sched-01',
        studentId: 'student-01',
        interpreterId: 'interp-01',
        courseName: 'Business Ethics',
        courseCode: 'BUS 301',
        location: 'Room A12',
        scheduleDate: base,
        startTime: base.copyWith(hour: 8, minute: 0),
        endTime: base.copyWith(hour: 9, minute: 30),
        status: 'confirmed',
        interpreterName: 'Kofi Mensah',
      ),
      ScheduleModel(
        id: 'sched-02',
        studentId: 'student-01',
        interpreterId: 'interp-02',
        courseName: 'Software Engineering',
        courseCode: 'CS 401',
        location: 'ICT Lab 2',
        scheduleDate: base,
        startTime: base.copyWith(hour: 11, minute: 0),
        endTime: base.copyWith(hour: 12, minute: 30),
        status: 'confirmed',
        interpreterName: 'Abena Boateng',
      ),
      ScheduleModel(
        id: 'sched-03',
        studentId: 'student-01',
        courseName: 'Calculus II',
        courseCode: 'MATH 201',
        location: 'Main Hall B',
        scheduleDate: base.add(const Duration(days: 1)),
        startTime: base.add(const Duration(days: 1)).copyWith(hour: 9, minute: 0),
        endTime: base.add(const Duration(days: 1)).copyWith(hour: 10, minute: 30),
        status: 'pending',
      ),
      ScheduleModel(
        id: 'sched-04',
        studentId: 'student-01',
        interpreterId: 'interp-01',
        courseName: 'African Studies',
        courseCode: 'AS 201',
        location: 'Lecture Theatre 1',
        scheduleDate: base.add(const Duration(days: 2)),
        startTime: base.add(const Duration(days: 2)).copyWith(hour: 14, minute: 0),
        endTime: base.add(const Duration(days: 2)).copyWith(hour: 15, minute: 30),
        status: 'confirmed',
        interpreterName: 'Kofi Mensah',
      ),
    ];
  }

  static List<ScheduleModel> get interpreterSchedules {
    return studentSchedules
        .where((s) => s.interpreterId == 'interp-01')
        .toList();
  }

  // ─── Events ──────────────────────────────────────────────────────────────
  static List<EventModel> get events {
    final base = DateTime.now();
    return [
      EventModel(
        id: 'evt-01',
        title: 'Sign Language Workshop',
        description: 'An interactive workshop on basic sign language for the Ashesi community. All are welcome!',
        date: base.add(const Duration(days: 2)),
        location: 'Ashesi Courtyard',
        capacity: 80,
        signedUpCount: 62,
        createdBy: 'admin-01',
        imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
      ),
      EventModel(
        id: 'evt-02',
        title: 'Accessibility Awareness Day',
        description: 'Join us for a day of learning, sharing, and celebrating accessibility at Ashesi.',
        date: base.add(const Duration(days: 7)),
        location: 'Main Auditorium',
        capacity: 200,
        signedUpCount: 120,
        createdBy: 'admin-01',
        imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400',
      ),
      EventModel(
        id: 'evt-03',
        title: 'Career Fair 2025',
        description: 'Connect with top employers. Interpreter support available throughout the event.',
        date: base.add(const Duration(days: 14)),
        location: 'Ashesi Courtyard',
        capacity: 300,
        signedUpCount: 247,
        createdBy: 'admin-01',
        imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=400',
      ),
      EventModel(
        id: 'evt-04',
        title: 'Disability Empowerment Forum',
        description: 'Panel discussion on disability rights in higher education.',
        date: base.subtract(const Duration(days: 14)),
        location: 'Library Conference Room',
        capacity: 60,
        signedUpCount: 58,
        createdBy: 'admin-01',
        isPast: true,
        imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400',
      ),
    ];
  }

  // ─── Requests ─────────────────────────────────────────────────────────────
  static List<RequestModel> get requests {
    final base = DateTime.now();
    return [
      RequestModel(
        id: 'req-01',
        studentId: 'student-01',
        studentName: 'Alex Johnson',
        requestType: 'class',
        eventTitle: 'Software Engineering Lecture',
        location: 'ICT Lab 2',
        requestDate: base.add(const Duration(days: 1)),
        requestTime: base.add(const Duration(days: 1)).copyWith(hour: 10),
        status: 'pending',
        notes: 'Needs support for group project presentation',
      ),
      RequestModel(
        id: 'req-02',
        studentId: 'student-02',
        studentName: 'Ama Owusu',
        requestType: 'event',
        eventTitle: 'Career Fair 2025',
        location: 'Ashesi Courtyard',
        requestDate: base.add(const Duration(days: 3)),
        requestTime: base.add(const Duration(days: 3)).copyWith(hour: 9),
        status: 'pending',
      ),
      RequestModel(
        id: 'req-03',
        studentId: 'student-03',
        studentName: 'Kwame Asante',
        requestType: 'class',
        eventTitle: 'Business Ethics Seminar',
        location: 'Faculty Wing, Room 12',
        requestDate: base.add(const Duration(days: 5)),
        requestTime: base.add(const Duration(days: 5)).copyWith(hour: 14),
        status: 'approved',
        assignedInterpreterId: 'interp-01',
      ),
    ];
  }

  // ─── Conversations ────────────────────────────────────────────────────────
  static List<ConversationModel> get conversations => [
        ConversationModel(
          id: 'conv-01',
          participantId: 'interp-01',
          participantName: 'Kofi Mensah',
          participantRole: 'interpreter',
          lastMessage: 'I\'ll be at the lecture hall by 8:45 AM.',
          lastMessageAt: DateTime.now().subtract(const Duration(minutes: 15)),
          unreadCount: 2,
          isOnline: true,
        ),
        ConversationModel(
          id: 'conv-02',
          participantId: 'interp-02',
          participantName: 'Abena Boateng',
          participantRole: 'interpreter',
          lastMessage: 'Your request for Friday has been confirmed.',
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
          isOnline: false,
        ),
        ConversationModel(
          id: 'conv-03',
          participantId: 'admin-01',
          participantName: 'DASS Office',
          participantRole: 'admin',
          lastMessage: 'Please upload your updated timetable.',
          lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 1,
          isOnline: true,
        ),
      ];

  static List<MessageModel> messagesForConversation(String conversationId) {
    final base = DateTime.now();
    return [
      MessageModel(
        id: 'm-01',
        senderId: 'interp-01',
        receiverId: 'student-01',
        conversationId: conversationId,
        messageBody: 'Hi Alex! Just confirming I\'ll be there for your 8 AM class tomorrow.',
        sentAt: base.subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: 'm-02',
        senderId: 'student-01',
        receiverId: 'interp-01',
        conversationId: conversationId,
        messageBody: 'Thanks Kofi! Really appreciate it. It\'s the group presentation, so it might run a bit long.',
        sentAt: base.subtract(const Duration(hours: 1, minutes: 10)),
        isRead: true,
      ),
      MessageModel(
        id: 'm-03',
        senderId: 'interp-01',
        receiverId: 'student-01',
        conversationId: conversationId,
        messageBody: 'No problem at all. I\'ll stay as long as you need. Good luck!',
        sentAt: base.subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
      MessageModel(
        id: 'm-04',
        senderId: 'interp-01',
        receiverId: 'student-01',
        conversationId: conversationId,
        messageBody: 'I\'ll be at the lecture hall by 8:45 AM.',
        sentAt: base.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
    ];
  }

  // ─── Notifications ────────────────────────────────────────────────────────
  static List<NotificationModel> get notifications => [
        NotificationModel(
          id: 'notif-01',
          userId: 'student-01',
          title: 'Interpreter Confirmed',
          content: 'Kofi Mensah has been confirmed for your Business Ethics class on Monday.',
          type: 'schedule',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        NotificationModel(
          id: 'notif-02',
          userId: 'student-01',
          title: 'New Event Posted',
          content: 'Career Fair 2025 has been added to upcoming events. Sign up now!',
          type: 'event',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        NotificationModel(
          id: 'notif-03',
          userId: 'student-01',
          title: 'Request Update',
          content: 'Your interpreter request for CS401 on Thursday has been approved.',
          type: 'request',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NotificationModel(
          id: 'notif-04',
          userId: 'student-01',
          title: 'New Message',
          content: 'Kofi Mensah: I\'ll be at the lecture hall by 8:45 AM.',
          type: 'message',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        ),
        NotificationModel(
          id: 'notif-05',
          userId: 'student-01',
          title: 'Timetable Reminder',
          content: 'Please upload your updated semester timetable to receive proper interpreter support.',
          type: 'system',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

  // ─── Helper: mock login ───────────────────────────────────────────────────
  /// Returns a UserModel if credentials match mock data, null otherwise.
  static Future<UserModel?> mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900)); // simulate network
    final mockCredentials = {
      'alex.johnson@ashesi.edu.gh': currentStudent,
      'kofi.mensah@ashesi.edu.gh': currentInterpreter,
      'sarah.asante@ashesi.edu.gh': currentAdmin,
    };
    return mockCredentials[email.toLowerCase()];
  }
}
