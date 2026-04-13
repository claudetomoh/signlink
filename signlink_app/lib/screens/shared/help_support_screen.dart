import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    _FAQ(q: 'How do I request a sign language interpreter?', a: 'Go to your dashboard and tap "Request Interpreter". Fill in the request type, event details, and preferred date/time. Your request will be reviewed by the SignLink admin.'),
    _FAQ(q: 'How long does it take to assign an interpreter?', a: 'Requests are typically processed within 24-48 hours. For urgent needs, please contact SignLink directly at dass@ashesi.edu.gh.'),
    _FAQ(q: 'Can I cancel or modify a request?', a: 'Yes. Go to My Schedule or My Requests and tap the request you want to modify. Changes can be made up to 24 hours before the event.'),
    _FAQ(q: 'How do I upload my timetable?', a: 'Tap "Upload Timetable" on your dashboard. You can take a photo, select from gallery, or upload a PDF/Excel file.'),
    _FAQ(q: 'Can I chat with my assigned interpreter?', a: 'Yes, once an interpreter is assigned, a message thread will appear in your Messages tab. You can also initiate a video call.'),
    _FAQ(q: 'What if my interpreter doesn\'t show up?', a: 'Contact SignLink immediately via the help section or call the SignLink office. We will arrange an alternate interpreter as quickly as possible.'),
    _FAQ(q: 'Is my information private?', a: 'Yes. All student disability records are kept strictly confidential in accordance with Ashesi University\'s privacy policy.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Help & Support')),
        body: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          children: [
            // Contact card
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Text('Contact SignLink', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                  ]),
                  const SizedBox(height: 12),
                  _ContactRow(icon: Icons.email_outlined, text: 'dass@ashesi.edu.gh', url: 'mailto:dass@ashesi.edu.gh'),
                  const SizedBox(height: 6),
                  _ContactRow(icon: Icons.phone_outlined, text: '+233 302 610 330', url: 'tel:+233302610330'),
                  const SizedBox(height: 6),
                  _ContactRow(icon: Icons.access_time_rounded, text: 'Mon–Fri, 8:00am – 5:00pm', url: null),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Inter', color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _FAQTile(faq: faq)),
            const SizedBox(height: 20),
          ],
        ),
      );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? url;
  const _ContactRow({required this.icon, required this.text, required this.url});

  Future<void> _launch() async {
    if (url == null) return;
    final uri = Uri.parse(url!);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: url != null ? _launch : null,
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Inter',
                decoration: url != null ? TextDecoration.underline : null,
                decorationColor: Colors.white70,
              ),
            ),
          ],
        ),
      );
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;
  const _FAQTile({required this.faq});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            ListTile(
              title: Text(widget.faq.q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
              trailing: Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              onTap: () => setState(() => _open = !_open),
            ),
            if (_open)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(widget.faq.a, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
              ),
          ],
        ),
      );
}

class _FAQ {
  final String q, a;
  const _FAQ({required this.q, required this.a});
}
