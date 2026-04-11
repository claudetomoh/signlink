import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _muted = false;
  bool _cameraOff = false;
  bool _speakerOn = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Stack(
            children: [
              // Remote video (full screen placeholder)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF16213E),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_rounded, size: 100, color: Color(0xFF444466)),
                      SizedBox(height: 16),
                      Text('Connecting...', style: TextStyle(color: Color(0xFF8888AA), fontSize: 16, fontFamily: 'Inter')),
                    ],
                  ),
                ),
              ),
              // Local camera (PiP)
              Positioned(
                top: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 130,
                    color: const Color(0xFF0F3460),
                    child: _cameraOff
                        ? const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54))
                        : const Center(child: Icon(Icons.person_rounded, size: 48, color: Colors.white54)),
                  ),
                ),
              ),
              // Call timer
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _CallTimer(),
                ),
              ),
              // Controls
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallBtn(icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded, label: _muted ? 'Unmute' : 'Mute', onTap: () => setState(() => _muted = !_muted), active: !_muted),
                    _CallBtn(icon: _cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded, label: _cameraOff ? 'Start Video' : 'Stop Video', onTap: () => setState(() => _cameraOff = !_cameraOff), active: !_cameraOff),
                    _CallBtn(icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded, label: 'Speaker', onTap: () => setState(() => _speakerOn = !_speakerOn), active: _speakerOn),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Column(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                            child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 6),
                          const Text('End', style: TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _CallBtn({required this.icon, required this.label, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: active ? Colors.white.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Inter')),
          ],
        ),
      );
}

class _CallTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('00:00', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter', letterSpacing: 1)),
      );
}
