import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/request_service.dart';
import 'recommendations_screen.dart';

class SummaryScreen extends StatefulWidget {
  final String serviceName;
  final String categoryId;
  final String categoryLabel;
  final Map<String, dynamic> formData;
  const SummaryScreen({
    super.key,
    required this.serviceName,
    required this.categoryId,
    required this.categoryLabel,
    required this.formData,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _locationController = TextEditingController();
  bool _saving = false;
  String _error = '';

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _goToProviders() async {
    if (_saving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = "Please sign in to continue.");
      return;
    }
    setState(() {
      _saving = true;
      _error = '';
    });

    try {
      final requestId = await RequestService.createRequest(
        userId: user.uid,
        categoryId: widget.categoryId,
        categoryLabel: widget.categoryLabel,
        serviceName: widget.serviceName,
        answers: widget.formData,
        locationText: _locationController.text.trim(),
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecommendationsScreen(
            requestId: requestId,
            categoryId: widget.categoryId,
            categoryLabel: widget.categoryLabel,
            locationText: _locationController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request summary")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: "Location (city/area)",
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_error, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 8),
          ...widget.formData.entries.map(
            (e) => ListTile(
              title: Text(e.key),
              subtitle: Text(e.value.toString()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saving ? null : _goToProviders,
          child: Text(_saving ? "Saving..." : "See providers"),
        ),
      ),
    );
  }
}
