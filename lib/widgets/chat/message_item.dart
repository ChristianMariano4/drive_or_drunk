import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/conversation_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart';
import 'package:drive_or_drunk_app/widgets/chat/chat_bubble.dart';
import 'package:flutter/material.dart';

Widget buildMessageItem(BuildContext context, Message message,
    FirestoreService db, DocumentReference user1Ref, user_model.User user2) {
  if (message.sender != user1Ref && message.seen == false) {
    db.setMessageSeen(message.id!);
  }
  final alignment =
      message.sender == user1Ref ? Alignment.centerRight : Alignment.centerLeft;
  final dateTime = message.timestamp!.toDate();
  final formattedDateTime = formatChatTimestamp(dateTime);
  return Container(
      alignment: alignment,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: alignment == Alignment.centerRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisAlignment: alignment == Alignment.centerRight
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (alignment != Alignment.centerRight) ...[
                  Text(user2.name,
                      style: Theme.of(context).textTheme.labelMedium)
                ],
                Padding(
                  padding: alignment == Alignment.centerRight
                      ? const EdgeInsets.only(left: 125)
                      : const EdgeInsets.only(right: 125),
                  child: ChatBubble(
                      message: message.text,
                      userNumber: message.sender == user1Ref ? 1 : 2),
                ),
                Text(formattedDateTime,
                    style: Theme.of(context).textTheme.labelMedium)
              ])));
}
