import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  Future<void> _openChat(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final provider = FirebaseAuth.instance.currentUser;
    if (provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to chat.")),
      );
      return;
    }

    final userId = (data["userId"] ?? "").toString();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing user info.")),
      );
      return;
    }

    final chatId = await ChatService.createChat(
      userId: userId,
      providerId: provider.uid,
      requestId: requestId,
      categoryId: data["categoryId"]?.toString(),
      categoryLabel: data["categoryLabel"]?.toString(),
      serviceName: data["serviceName"]?.toString(),
    );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          senderRole: "provider",
          title: "Chat with user",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('requests').doc(requestId);

    return Scaffold(
      appBar: AppBar(title: const Text("Request detail")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Failed to load request: ${snapshot.error}"),
            );
          }
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Request not found."));
          }
          final serviceName = (data["serviceName"] ?? "Request").toString();
          final categoryLabel =
              (data["categoryLabel"] ?? "Category").toString();
          final locationText = (data["locationText"] ?? "").toString();
          final answers = data["answers"] as Map<String, dynamic>? ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(serviceName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text("Category: $categoryLabel"),
              if (locationText.isNotEmpty) Text("Location: $locationText"),
              const SizedBox(height: 12),
              const Text(
                "Answers",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (answers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("No answers provided."),
                )
              else
                ...answers.entries.map(
                  (e) => ListTile(
                    title: Text(e.key),
                    subtitle: Text(e.value.toString()),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _openChat(context, data),
                  child: const Text("Chat"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
