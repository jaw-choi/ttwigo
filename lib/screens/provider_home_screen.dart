import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/user_role_service.dart';
import '../services/provider_profile_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'request_detail_screen.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    await UserRoleService.clearRole();
    if (context.mounted) context.go('/login');
  }

  Future<void> _openChat(
    BuildContext context,
    String requestId,
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
    final authService = AuthService();
    final user = authService.currentUser;
    final email = (user != null && !user.isAnonymous) ? user.email ?? "Unknown" : "Provider";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider"),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Welcome $email", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My services", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.go('/provider-setup'),
                child: const Text("Edit"),
              ),
            ],
          ),
          FutureBuilder<Map<String, ProviderCategoryInfo>>(
            future: ProviderProfileService.getProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snapshot.data ?? {};
              if (data.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("No services added yet."),
                );
              }
              return Column(
                children: data.entries.map((entry) {
                  final info = entry.value;
                  final label = info["label"]?.trim().isNotEmpty == true
                      ? info["label"]!
                      : entry.key;
                  final area = info["area"]?.trim() ?? '';
                  final price = info["price"]?.trim() ?? '';
                  final intro = info["intro"]?.trim() ?? '';
                  final subtitleParts = [
                    if (area.isNotEmpty) "Area: $area",
                    if (price.isNotEmpty) "Price: $price",
                    if (intro.isNotEmpty) "Intro: $intro",
                  ];
                  return Card(
                    child: ListTile(
                      title: Text(label),
                      subtitle: subtitleParts.isEmpty
                          ? const Text("No details provided.")
                          : Text(subtitleParts.join(" | ")),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text("New requests", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Failed to load requests: ${snapshot.error}"),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("No requests yet."),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final serviceName =
                      (data["serviceName"] ?? "Request").toString();
                  final categoryLabel =
                      (data["categoryLabel"] ?? "Category").toString();
                  final locationText = (data["locationText"] ?? "").toString();
                  final subtitleParts = [
                    "Category: $categoryLabel",
                    if (locationText.isNotEmpty) "Location: $locationText",
                  ];
                  return Card(
                    child: ListTile(
                      title: Text(serviceName),
                      subtitle: Text(subtitleParts.join(" | ")),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RequestDetailScreen(requestId: doc.id),
                          ),
                        );
                      },
                      trailing: TextButton(
                        onPressed: () => _openChat(context, doc.id, data),
                        child: const Text("Chat"),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
