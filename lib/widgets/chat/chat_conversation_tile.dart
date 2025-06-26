import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/models/conversation_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final DocumentReference otheruser;
  final Message? message;
  final int unreadCount;

  const ConversationTile({
    super.key,
    required this.otheruser,
    required this.message,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: Future.wait([otheruser.get()]),
      component: (data) {
        final otheruser = user_model.User.fromMap(
            data[0].data() as Map<String, dynamic>, data[0].id);
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.chatpage,
                  arguments: {
                    'otherUserid': otheruser.id,
                  },
                );
              },
              child: Container(
                color: Colors.transparent,
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // importante per usare Baseline
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: otheruser.profilePicture != null
                            ? imageProviderFromBase64(
                                otheruser.profilePicture ?? '')
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            otheruser.name,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 20,
                                ),
                          ),
                          Text(
                            message != null ? message!.text : "",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: unreadCount > 0,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.primaryColor,
                                child: Text(
                                  unreadCount.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: AppColors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                            if (message != null) ...[
                              Text(
                                formatChatTimestamp(
                                    message!.timestamp!.toDate()),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(top: 12, right: 5, left: 5),
                child: Divider(height: 1, color: AppColors.dividerColor)),
          ],
        );
      },
    );
  }
}
