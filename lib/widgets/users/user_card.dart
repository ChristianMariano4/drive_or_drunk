import 'dart:convert';
import 'dart:typed_data';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final User user;
  const UserCard({super.key, required this.user});

  ImageProvider _avatarProvider(String? pic) {
    if (pic == null || pic.isEmpty) {
      return const AssetImage('assets/homepage_img2.png');
    }

    final isBase64 = pic.startsWith('data:image') || pic.length > 100;
    if (isBase64) {
      try {
        final raw = pic.contains(',') ? pic.split(',').last : pic;
        final Uint8List bytes = base64Decode(raw);
        return MemoryImage(bytes);
      } catch (_) {
        return const AssetImage('assets/homepage_img2.png');
      }
    }

    return NetworkImage(pic);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.userProfile,
        arguments: user.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppSizes.iconLg / 2,
              backgroundImage: _avatarProvider(user.profilePicture),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
