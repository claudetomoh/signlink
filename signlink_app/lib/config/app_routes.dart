/// SignLink route names — single source of truth for navigation.
class AppRoutes {
  // Auth
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/signup';
  static const signUp2 = '/signup-2';
  static const signUpSuccess = '/signup-success';
  static const forgotPassword = '/forgot-password';
  static const resetSent = '/reset-sent';

  // Student
  static const studentDashboard = '/student/dashboard';
  static const studentTimetable = '/student/timetable';
  static const studentProfile = '/student/profile';
  static const eventsListStudent = '/student/events';
  static const eventDetail = '/events/detail';
  static const requestStep1 = '/request/step1';
  static const requestStep2 = '/request/step2';
  static const requestStep3 = '/request/step3';
  static const requestEventType = '/request/event-type';
  static const requestDateTime = '/request/datetime';
  static const requestReview = '/request/review';
  static const requestSuccess = '/request/success';
  static const uploadTimetable = '/student/upload-timetable';

  // Interpreter
  static const interpreterDashboard = '/interpreter/dashboard';
  static const interpreterSchedule = '/interpreter/schedule';
  static const interpreterProfile = '/interpreter/profile';
  static const eventRequests = '/interpreter/requests';
  static const confirmAvailability = '/interpreter/availability';

  // Admin
  static const adminDashboard = '/admin/dashboard';
  static const manageUsers = '/admin/users';
  static const assignInterpreter = '/admin/assign';
  static const createEvent = '/admin/create-event';

  // Shared
  static const messagesList = '/messages';
  static const chatDetail = '/messages/chat';
  static const videoCall = '/video-call';
  static const notifications = '/notifications';
  static const accessibilitySettings = '/settings/accessibility';
  static const helpSupport = '/help';

  // Aliases for convenience
  static const eventsList = eventsListStudent;
  static const interpreterRequests = eventRequests;
  static const messages = messagesList;
  static const chat = chatDetail;
  static const accessibility = accessibilitySettings;
  static const help = helpSupport;
}
