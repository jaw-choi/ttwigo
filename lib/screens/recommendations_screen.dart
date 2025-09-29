import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  final String serviceName;
  const RecommendationsScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    final experts = [
      {"name": "김프로", "tags": ["에어컨", "설치"]},
      {"name": "이명장", "tags": ["보일러", "수리"]},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("추천 전문가")),
      body: ListView(
        children: experts.map((e) {
          return ListTile(
            title: Text(e["name"] as String),
            subtitle: Text("전문 분야: ${(e["tags"] as List).join(', ')}"),
            trailing: ElevatedButton(onPressed: () {}, child: const Text("상담")),
          );
        }).toList(),
      ),
    );
  }
}
