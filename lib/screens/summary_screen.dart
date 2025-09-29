import 'package:flutter/material.dart';
import 'recommendations_screen.dart';

class SummaryScreen extends StatelessWidget {
  final String serviceName;
  final Map<String, dynamic> formData;
  const SummaryScreen({super.key, required this.serviceName, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("요청 내용 확인")),
      body: ListView(
        children: formData.entries
            .map((e) => ListTile(title: Text(e.key), subtitle: Text(e.value.toString())))
            .toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RecommendationsScreen(serviceName: serviceName)));
          },
          child: const Text("추천 전문가 보기"),
        ),
      ),
    );
  }
}
