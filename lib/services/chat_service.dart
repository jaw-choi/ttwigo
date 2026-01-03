import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static Future<String> createChat({
    required String userId,
    required String providerId,
    required String requestId,
    String? categoryId,
    String? categoryLabel,
    String? serviceName,
  }) async {
    final chatId = '${requestId}_$providerId';
    final doc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        "userId": userId,
        "providerId": providerId,
        "requestId": requestId,
        if (categoryId != null) "categoryId": categoryId,
        if (categoryLabel != null) "categoryLabel": categoryLabel,
        if (serviceName != null) "serviceName": serviceName,
        "lastMessage": "",
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } else {
      await doc.set(
        {"updatedAt": FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    return chatId;
  }

  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String text,
  }) async {
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final messageDoc = chatDoc.collection('messages').doc();
    await messageDoc.set({
      "senderId": senderId,
      "senderRole": senderRole,
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });
    await chatDoc.set(
      {
        "lastMessage": text,
        "updatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
