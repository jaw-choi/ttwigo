import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'summary_screen.dart';

class QuoteProcessScreen extends StatefulWidget {
  final String serviceName;
  const QuoteProcessScreen({super.key, required this.serviceName});

  @override
  State<QuoteProcessScreen> createState() => _QuoteProcessScreenState();
}

class _QuoteProcessScreenState extends State<QuoteProcessScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  Map<String, dynamic> answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String data = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> jsonResult = json.decode(data);

    setState(() {
      questions =
      List<Map<String, dynamic>>.from(jsonResult[widget.serviceName] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("${widget.serviceName} 견적 요청")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQ = questions[currentIndex];
    final String questionText = currentQ["question"];
    final List<String> options = List<String>.from(currentQ["options"]);
    final bool isMultiple = currentQ["multiple"];

    dynamic selected =
        answers[questionText] ?? (isMultiple ? <String>[] : null);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.serviceName} 견적 요청")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(   // 스크롤 가능하게
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questionText,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 옵션들
              ...options.map((opt) {
                if (isMultiple) {
                  final selectedList = (selected as List<String>);
                  return CheckboxListTile(
                    title: Text(opt),
                    value: selectedList.contains(opt),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedList.add(opt);
                        } else {
                          selectedList.remove(opt);
                        }
                        answers[questionText] = selectedList;
                      });
                    },
                  );
                } else {
                  return RadioListTile<String>(
                    title: Text(opt),
                    value: opt,
                    groupValue: selected,
                    onChanged: (val) {
                      setState(() {
                        answers[questionText] = val;
                      });
                    },
                  );
                }
              }).toList(),

              const SizedBox(height: 24),

              // 버튼을 옵션 밑에 붙이기
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // 진한 색
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: (isMultiple && (selected as List).isEmpty) ||
                      (!isMultiple && selected == null)
                      ? null
                      : () {
                    if (currentIndex < questions.length - 1) {
                      setState(() => currentIndex++);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SummaryScreen(
                            serviceName: widget.serviceName,
                            formData: answers,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                      currentIndex < questions.length - 1 ? "다음" : "완료"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
