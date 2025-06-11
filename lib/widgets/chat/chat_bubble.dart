import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final int userNumber;

  const ChatBubble(
      {super.key, required this.message, required this.userNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: userNumber == 1 ? AppColors.white : AppColors.primaryColor,
        ),
        borderRadius: BorderRadius.circular(15),
        color: userNumber == 1 ? AppColors.primaryColor : AppColors.white,
      ),
      child: Text(message,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color:
                  userNumber == 1 ? AppColors.white : AppColors.primaryColor)),
    );
  }
}
