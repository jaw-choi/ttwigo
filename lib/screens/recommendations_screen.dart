import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  final String requestId;
  final String categoryId;
  final String categoryLabel;
  final String locationText;
  const RecommendationsScreen({
    super.key,
    required this.requestId,
    required this.categoryId,
    required this.categoryLabel,
    required this.locationText,
  });

  bool _matchesLocation(String area) {
    final needle = locationText.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return area.toLowerCase().contains(needle);
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('providers')
        .where('categoryIds', arrayContains: categoryId);

    return Scaffold(
      appBar: AppBar(title: const Text("Providers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Failed to load providers: ${snapshot.error}"));
          }
          final docs = snapshot.data?.docs ?? [];
          final filtered = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final details = data["categoryDetails"] as Map<String, dynamic>? ?? {};
            final perCategory = details[categoryId] as Map<String, dynamic>? ?? {};
            final area = (perCategory["area"] ?? data["area"] ?? "").toString();
            return _matchesLocation(area);
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text("No providers found."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: filtered.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = (data["name"] ?? "Provider").toString();
              final details = data["categoryDetails"] as Map<String, dynamic>? ?? {};
              final perCategory = details[categoryId] as Map<String, dynamic>? ?? {};
              final intro = (perCategory["intro"] ?? data["intro"] ?? "").toString();
              final area = (perCategory["area"] ?? data["area"] ?? "").toString();
              final price = (perCategory["price"] ?? data["priceRange"] ?? "").toString();

              final subtitleParts = [
                if (area.isNotEmpty) "Area: $area",
                if (price.isNotEmpty) "Price: $price",
                if (intro.isNotEmpty) "Intro: $intro",
              ];

              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: subtitleParts.isEmpty
                      ? Text("Category: $categoryLabel")
                      : Text(subtitleParts.join(" | ")),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please sign in to chat."),
                          ),
                        );
                        return;
                      }
                      final providerId = doc.id;
                      final chatId = await ChatService.createChat(
                        userId: user.uid,
                        providerId: providerId,
                        requestId: requestId,
                        categoryId: categoryId,
                        categoryLabel: categoryLabel,
                      );
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            senderRole: "user",
                            title: name,
                          ),
                        ),
                      );
                    },
                    child: const Text("Chat"),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
