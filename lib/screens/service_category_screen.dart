import 'package:flutter/material.dart';
import 'quote_process_screen.dart';

class ServiceCategoryScreen extends StatelessWidget {
  const ServiceCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        "icon": Icons.local_shipping,
        "title": "이사/청소",
        "services": [
          "가정이사(투룸 이상)",
          "국내 이사",
          "사무실/상업공간 이사",
          "원룸/소형 이사",
          "입주/집 청소",
          "가전/가구 청소",
          "철거/폐기"
        ]
      },
      {
        "icon": Icons.build,
        "title": "설치/수리",
        "services": [
          "에어컨 설치",
          "보일러 수리",
          "TV 벽걸이",
          "가전제품 설치",
        ]
      },
      {
        "icon": Icons.chair_alt,
        "title": "인테리어",
        "services": [
          "도배/장판",
          "싱크대 교체",
          "욕실 리모델링",
          "조명 시공",
        ]
      },
      {
        "icon": Icons.event,
        "title": "이벤트/뷰티",
        "services": [
          "웨딩 촬영",
          "돌잔치 행사",
          "헤어/메이크업",
        ]
      },
      {
        "icon": Icons.sports_basketball,
        "title": "취미/자기계발",
        "services": [
          "피아노 레슨",
          "골프 레슨",
          "헬스 PT",
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("서비스 카테고리")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final category = categories[i];
          return ExpansionTile(
            leading: Icon(category["icon"] as IconData, color: Colors.blue),
            title: Text(category["title"] as String,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            children: (category["services"] as List<String>).map((service) {
              return ListTile(
                title: Text(service),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuoteProcessScreen(serviceName: service),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
