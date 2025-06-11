import 'package:cloud_firestore/cloud_firestore.dart'
    show
        DocumentReference,
        FirebaseException,
        FirebaseFirestore,
        QuerySnapshot,
        Timestamp;
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show Collections;
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:rxdart/rxdart.dart';

class Message {
  final String? id;
  final String text;
  final Timestamp? timestamp;
  final DocumentReference sender;
  final bool seen;

  Message(
      {this.id,
      required this.text,
      this.timestamp,
      required this.sender,
      this.seen = false});

  factory Message.fromMap(Map<String, dynamic> data, String documentId) {
    return Message(
      id: documentId,
      text: data['text'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      sender: data['sender'],
      seen: data['seen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': timestamp,
      'sender': sender,
      'seen': seen,
    };
  }
}

Future<void> setMessageSeen(String messageId, FirebaseFirestore db) async {
  await db.collection('Messages').doc(messageId).update({'seen': true});
}

class Conversation {
  final String? id;
  final DocumentReference user1;
  final DocumentReference user2;
  final List<DocumentReference> messageHistory;
  final Timestamp lastMessageTimestamp;

  Conversation(
      {this.id,
      required this.user1,
      required this.user2,
      this.messageHistory = const [],
      required this.lastMessageTimestamp});

  factory Conversation.fromMap(Map<String, dynamic> data, String documentId) {
    return Conversation(
      id: documentId,
      user1: data['user1'],
      user2: data['user2'],
      messageHistory: (data['messages'] as List<dynamic>? ?? [])
          .map((m) => m as DocumentReference)
          .toList(),
      lastMessageTimestamp: data['lastmessagetimestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1': user1,
      'user2': user2,
      'messages': messageHistory,
      'lastmessagetimestamp': lastMessageTimestamp,
    };
  }

  List<DocumentReference> getParticipants() {
    return [user1, user2];
  }
}

Future<void> addConversation(
    Conversation conversation, FirebaseFirestore db) async {
  if (conversation.id == null) {
    db.collection(Collections.conversations).add(conversation.toMap());
  } else {
    throw FirebaseException(
      plugin: 'Firestore',
      message: 'A conversation with that ID already exists.',
    );
  }
}

Future<Conversation?> getConversation(String id, FirebaseFirestore db) async {
  final doc = await db.collection(Collections.conversations).doc(id).get();
  if (doc.exists) {
    return Conversation.fromMap(doc.data()!, doc.id);
  }
  return null;
}

Future<String> getOrCreateConversationId(DocumentReference user1,
    DocumentReference user2, FirebaseFirestore db) async {
  final query = await getConversationbyParticipants(db, user1, user2);

  if (query.docs.isNotEmpty) {
    return query.docs.first.id;
  }

  final reverseQuery = await getConversationbyParticipants(db, user2, user1);

  if (reverseQuery.docs.isNotEmpty) {
    return reverseQuery.docs.first.id;
  }

  final newConversation = Conversation(
      user1: user1, user2: user2, lastMessageTimestamp: Timestamp.now());
  await addConversation(newConversation, db);
  final querySnapshot = await getConversationbyParticipants(db, user1, user2);
  final docRef = querySnapshot.docs.first.reference;
  return docRef.id;
}

Future<QuerySnapshot<Map<String, dynamic>>> getConversationbyParticipants(
    FirebaseFirestore db,
    DocumentReference<Object?> user1,
    DocumentReference<Object?> user2) async {
  final query = await db
      .collection(Collections.conversations)
      .where('user1', isEqualTo: user2)
      .where('user2', isEqualTo: user1)
      .get();
  return query;
}

Stream<List<Conversation>> getConversations(
    FirebaseFirestore db, DocumentReference userReference) {
  final user1Stream = db
      .collection(Collections.conversations)
      .where('user1', isEqualTo: userReference)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Conversation.fromMap(doc.data(), doc.id))
          .toList());

  final user2Stream = db
      .collection(Collections.conversations)
      .where('user2', isEqualTo: userReference)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Conversation.fromMap(doc.data(), doc.id))
          .toList());

  return Rx.combineLatest2<List<Conversation>, List<Conversation>,
      List<Conversation>>(
    user1Stream,
    user2Stream,
    (user1List, user2List) {
      final allConversations = [...user1List, ...user2List];

      // Ordina per timestamp decrescente (dal più recente al meno recente)
      allConversations.sort(
          (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));

      return allConversations;
    },
  );
}

Future<void> updateConversation(
    String id, Map<String, dynamic> data, FirebaseFirestore db) async {
  await db.collection(Collections.conversations).doc(id).update(data);
  await updateLastMessageTimestampToLatest(id, db);
}

Future<void> deleteConversation(String id, FirebaseFirestore db) async {
  await db.collection(Collections.conversations).doc(id).delete();
}

Future<void> sendMessage(
    String conversationId, Message message, FirebaseFirestore db) async {
  // Add the message to the 'messages' collection and get its reference
  final messageRef = await db.collection("Messages").add(message.toMap());

  // Get the conversation
  final conversation = await getConversation(conversationId, db);
  if (conversation != null) {
    // Add the message reference to the messageHistory
    final updatedHistory =
        List<DocumentReference>.from(conversation.messageHistory)
          ..add(messageRef);
    // Update the conversation with the new messageHistory
    await updateConversation(
      conversationId,
      {'messages': updatedHistory},
      db,
    );
  }
}

Stream<List<Message>> getMessagesStream(
  String conversationId,
  FirebaseFirestore db,
) {
  return db
      .collection(Collections.conversations)
      .doc(conversationId)
      .snapshots()
      .asyncMap((docSnapshot) async {
    final data = docSnapshot.data();
    if (data == null || data['messages'] == null) return <Message>[];
    final messageRefs = List<DocumentReference>.from(data['messages']);
    final messages = await Future.wait(
      messageRefs.map((ref) async {
        final msgDoc = await ref.get();
        if (msgDoc.exists) {
          final msgData = msgDoc.data() as Map<String, dynamic>;
          return Message.fromMap(msgData, msgDoc.id);
        }
        return null;
      }),
    );
    return messages.whereType<Message>().toList();
  });
}

Future<void> updateLastMessageTimestampToLatest(
    String conversationId, FirebaseFirestore db) async {
  final conversationDoc =
      await db.collection(Collections.conversations).doc(conversationId).get();
  final data = conversationDoc.data();
  if (data == null || data['messages'] == null) return;

  final messageRefs = List<DocumentReference>.from(data['messages']);
  if (messageRefs.isEmpty) return;

  final messages = await Future.wait(
    messageRefs.map((ref) async {
      final msgDoc = await ref.get();
      if (msgDoc.exists) {
        final msgData = msgDoc.data() as Map<String, dynamic>;
        return msgData['timestamp'] as Timestamp?;
      }
      return null;
    }),
  );

  final timestamps = messages.whereType<Timestamp>().toList();
  if (timestamps.isEmpty) return;

  timestamps.sort((a, b) => b.compareTo(a));
  final latestTimestamp = timestamps.first;

  await db
      .collection(Collections.conversations)
      .doc(conversationId)
      .update({'lastMessageTimestamp': latestTimestamp});
}

Future<int> countUnseenMessages(
    Conversation conversation, String currentUser, FirebaseFirestore db) async {
  int unseenCount = 0;
  final DocumentReference? currentUserRef = await user_model.getUserReference(
    currentUser,
    db,
  );
  for (final msgRef in conversation.messageHistory) {
    final msgDoc = await msgRef.get();
    if (msgDoc.exists) {
      final msgData = msgDoc.data() as Map<String, dynamic>;
      final isSeen = msgData['seen'] == true;
      final sender = msgData['sender'] as DocumentReference;
      if (!isSeen && sender != currentUserRef) {
        unseenCount++;
      }
    }
  }
  return unseenCount;
}

Future<Message?> getMostRecentMessageFromConversation(
    Conversation conversation, FirebaseFirestore db) async {
  if (conversation.messageHistory.isEmpty) return null;
  final messages = await Future.wait(
    conversation.messageHistory.map((ref) async {
      final msgDoc = await ref.get();
      if (msgDoc.exists) {
        final msgData = msgDoc.data() as Map<String, dynamic>;
        return Message.fromMap(msgData, msgDoc.id);
      }
      return null;
    }),
  );
  final validMessages = messages.whereType<Message>().toList();
  if (validMessages.isEmpty) return null;
  validMessages.sort((a, b) => (b.timestamp ?? Timestamp(0, 0))
      .compareTo(a.timestamp ?? Timestamp(0, 0)));
  return validMessages.first;
}
