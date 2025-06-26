import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/conversation_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drive_or_drunk_app/widgets/chat/chat_conversation_tile.dart';

class ChatListPage extends StatefulWidget {
  final String id = FirebaseAuth.instance.currentUser!.uid;

  ChatListPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatListPage> {
  final db = FirestoreService();
  DocumentReference? user1Ref;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReferences();
  }

  void loadReferences() async {
    user1Ref = await db.getUserReference(widget.id) as DocumentReference;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    while (isLoading) {
      return const Scaffold(
        body: Center(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
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
      body: CustomStreamBuilder(
          stream: db.getConversations(user1Ref!),
          customListTileBuilder: (conversation) {
            final DocumentReference? lastMsgRef =
                (conversation.messageHistory ?? []).isNotEmpty
                    ? conversation.messageHistory!.last
                    : null;
            return CustomFutureBuilder(
              future: Future.wait([
                conversation.user1.get(),
                lastMsgRef != null
                    ? lastMsgRef.get()
                    : Future.value(), // If no messages, return null
                db.countUnseenMessages(conversation, widget.id)
              ]),
              component: (data) {
                final user1Snapshot = data[0] as DocumentSnapshot;
                final user1 = user_model.User.fromMap(
                    user1Snapshot.data() as Map<String, dynamic>,
                    user1Snapshot.id);
                final messageSnapshot =
                    data[1] != null ? data[1] as DocumentSnapshot : null;
                final message = messageSnapshot != null
                    ? messageSnapshot.exists
                        ? Message.fromMap(
                            messageSnapshot.data() as Map<String, dynamic>,
                            messageSnapshot.id)
                        : null
                    : null;
                final unseenCount = data[2] as int;
                return ConversationTile(
                  otheruser: user1.id == widget.id
                      ? conversation.user2
                      : conversation.user1,
                  message: message,
                  unreadCount: unseenCount,
                );
              },
            );
          }),
    );
  }
}
