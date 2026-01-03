import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/provider_profile_service.dart';

class ProviderProfileSetupScreen extends StatefulWidget {
  const ProviderProfileSetupScreen({super.key});

  @override
  State<ProviderProfileSetupScreen> createState() =>
      _ProviderProfileSetupScreenState();
}

class _ProviderProfileSetupScreenState
    extends State<ProviderProfileSetupScreen> {
  final Map<String, bool> _selected = {};
  final Map<String, TextEditingController> _introControllers = {};
  final Map<String, TextEditingController> _areaControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  bool _loading = true;
  String _error = '';

  static final List<Map<String, Object>> _categories = [
    {"id": "moving_cleaning", "icon": Icons.local_shipping, "label": "Moving / Cleaning"},
    {"id": "install_repair", "icon": Icons.build, "label": "Install / Repair"},
    {"id": "interior", "icon": Icons.chair_alt, "label": "Interior"},
    {"id": "event_beauty", "icon": Icons.event, "label": "Event / Beauty"},
    {"id": "hobby_fitness", "icon": Icons.sports_basketball, "label": "Hobby / Fitness"},
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadProfile();
  }

  void _initControllers() {
    for (final category in _categories) {
      final categoryId = category["id"] as String;
      _selected.putIfAbsent(categoryId, () => false);
      _introControllers[categoryId] = TextEditingController();
      _areaControllers[categoryId] = TextEditingController();
      _priceControllers[categoryId] = TextEditingController();
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ProviderProfileService.getProfile();
    for (final entry in profile.entries) {
      final categoryId = entry.key;
      final info = entry.value;
      if (_selected.containsKey(categoryId)) {
        _selected[categoryId] = true;
        _introControllers[categoryId]?.text = info["intro"] ?? '';
        _areaControllers[categoryId]?.text = info["area"] ?? '';
        _priceControllers[categoryId]?.text = info["price"] ?? '';
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (mounted) {
      setState(() => _error = '');
    }
    final data = <String, ProviderCategoryInfo>{};
    final labelById = {
      for (final category in _categories)
        category["id"] as String: category["label"] as String,
    };
    final categoryIds = <String>[];
    final categoryLabels = <String>[];
    for (final entry in _selected.entries) {
      if (!entry.value) continue;
      final categoryId = entry.key;
      final label = labelById[categoryId] ?? categoryId;
      categoryIds.add(categoryId);
      categoryLabels.add(label);
      data[categoryId] = {
        "label": label,
        "intro": _introControllers[categoryId]?.text.trim() ?? '',
        "area": _areaControllers[categoryId]?.text.trim() ?? '',
        "price": _priceControllers[categoryId]?.text.trim() ?? '',
      };
    }

    if (data.isEmpty) {
      setState(() => _error = "Select at least one category.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = "Please sign in to save your profile.");
      return;
    }

    try {
      await ProviderProfileService.saveProfile(data);
      await FirebaseFirestore.instance.collection('providers').doc(user.uid).set(
        {
          "userId": user.uid,
          "name": user.displayName ?? user.email ?? "Provider",
          "categoryIds": categoryIds,
          "categories": categoryLabels,
          "categoryDetails": data,
          "active": true,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (mounted) {
        context.go('/provider-home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _introControllers.values) {
      controller.dispose();
    }
    for (final controller in _areaControllers.values) {
      controller.dispose();
    }
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Provider Setup")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Add your service info by category.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_error.isNotEmpty) ...[
            Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
          ],
          ..._categories.map((category) {
            final categoryId = category["id"] as String;
            final label = category["label"] as String;
            final icon = category["icon"] as IconData;
            final isSelected = _selected[categoryId] ?? false;
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() => _selected[categoryId] = value);
                      },
                      title: Text(label),
                      secondary: Icon(icon),
                    ),
                    if (isSelected) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _introControllers[categoryId],
                              decoration: const InputDecoration(
                                labelText: "Intro / Experience",
                              ),
                              maxLines: 2,
                            ),
                            TextField(
                              controller: _areaControllers[categoryId],
                              decoration: const InputDecoration(
                                labelText: "Service Area",
                              ),
                            ),
                            TextField(
                              controller: _priceControllers[categoryId],
                              decoration: const InputDecoration(
                                labelText: "Price Range",
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save and Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
