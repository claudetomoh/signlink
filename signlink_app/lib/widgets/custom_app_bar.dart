import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(title),
        leading: leading ??
            (showBack && Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  )
                : null),
        actions: actions,
      );
}

class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  // Aliases for backward compatibility
  final VoidCallback? onPressed;
  final int? badgeCount;
  final int? badge;

  const AppBarAction({
    super.key,
    required this.icon,
    this.onTap,
    this.onPressed,
    this.badgeCount,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          icon: (badgeCount ?? badge) != null && (badgeCount ?? badge)! > 0
              ? Badge(
                  label: Text((badgeCount ?? badge)! > 9 ? '9+' : '${badgeCount ?? badge}'),
                  child: Icon(icon),
                )
              : Icon(icon),
          onPressed: onTap ?? onPressed,
        ),
      );
}

// ─── Avatar widget ─────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 22,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Returns the correct [ImageProvider] for a given path:
  ///  • starts with '/' or 'file://' → local file from camera/gallery
  ///  • starts with 'http'           → remote URL
  ImageProvider? _imageProvider() {
    if (imageUrl == null) return null;
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return CachedNetworkImageProvider(imageUrl!);
    }
    // Local file path (camera / gallery pick)
    final path = imageUrl!.startsWith('file://')
        ? imageUrl!.replaceFirst('file://', '')
        : imageUrl!;
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final provider = _imageProvider();
    if (provider != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: provider,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
