import 'package:cloud_firestore/cloud_firestore.dart';

class RequestService {
  static Future<String> createRequest({
    required String userId,
    required String categoryId,
    required String categoryLabel,
    required String serviceName,
    required Map<String, dynamic> answers,
    required String locationText,
  }) async {
    final doc = FirebaseFirestore.instance.collection('requests').doc();
    await doc.set({
      "userId": userId,
      "categoryId": categoryId,
      "categoryLabel": categoryLabel,
      "serviceName": serviceName,
      "answers": answers,
      "locationText": locationText,
      "status": "open",
      "createdAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
