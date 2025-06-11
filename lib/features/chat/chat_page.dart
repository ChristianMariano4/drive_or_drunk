import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/models/conversation_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:drive_or_drunk_app/widgets/chat/message_item.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String id = FirebaseAuth.instance.currentUser!.uid;
  final String otherUserid;

  ChatPage({super.key, required this.otherUserid});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final FirestoreService db = FirestoreService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late String? conversationId;
  DocumentReference? user1Ref;
  DocumentReference? user2Ref;
  user_model.User? user1;
  user_model.User? user2;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadConversation();
  }

  Future<void> loadConversation() async {
    final user1ref = await db.getUserReference(widget.id);
    final user2ref = await db.getUserReference(widget.otherUserid);
    final user1 = await db.getUser(widget.id);
    final user2 = await db.getUser(widget.otherUserid);

    final chatid = await db.getOrCreateConversationId(user1ref!, user2ref!);

    user1Ref = user1ref;
    user2Ref = user2ref;
    this.user1 = user1;
    this.user2 = user2;
    conversationId = chatid;

    setState(() {
      isLoading = false;
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final text = _messageController.text.trim();
      final message = Message(
        sender: (await db
            .getUserReference(FirebaseAuth.instance.currentUser!.uid))!,
        text: text,
        timestamp: Timestamp.now(),
      );
      await db.sendMessage(conversationId!, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || conversationId == null) {
      return const Scaffold(
        body: Center(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 10,
          children: [
            CircleAvatar(
                radius: 15,
                backgroundImage: user2!.profilePicture != null
                    ? imageProviderFromBase64(user2!.profilePicture ?? '')
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider),
            Text(user2?.name ?? '',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontSize: 21)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          IconButton(
            icon: Icon(
                context.watch<ThemeProvider>().themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
            child: CustomStreamBuilder(
                scrollController: scrollController,
                stream: db.getMessageStream(conversationId!),
                customListTileBuilder: (message) {
                  return buildMessageItem(
                      context, message, db, user1Ref!, user2!);
                })),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
          child: Row(children: [
            Expanded(
                child: CustomTextFormField(
              controller: _messageController,
              labelText: "Message...",
              isChatForm: true,
              sufIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: FilledButton(
                  onPressed: _sendMessage,
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(11)),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 30,
                    color: AppColors.white,
                  ),
                ),
              ),
            )),
          ]),
        )
      ]),
    );
  }
}
