import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'summary_screen.dart';

// --- 개선 사항 1: 데이터 모델 클래스 정의 ---
class Question {
  final String questionText;
  final List<String> options;
  final bool isMultiple;

  Question({
    required this.questionText,
    required this.options,
    required this.isMultiple,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    if (json['question'] == null || json['options'] == null || json['multiple'] == null) {
      throw const FormatException("Invalid question format in JSON");
    }
    return Question(
      questionText: json['question'],
      options: List<String>.from(json['options']),
      isMultiple: json['multiple'],
    );
  }
}

class QuoteProcessScreen extends StatefulWidget {
  final String serviceName;
  final String categoryId;
  final String categoryLabel;
  const QuoteProcessScreen({
    super.key,
    required this.serviceName,
    required this.categoryId,
    required this.categoryLabel,
  });

  @override
  State<QuoteProcessScreen> createState() => _QuoteProcessScreenState();
}

class _QuoteProcessScreenState extends State<QuoteProcessScreen> {
  // --- 개선 사항 2: 상태 변수 타입 변경 및 컨트롤러 추가 ---
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0;
  final Map<String, dynamic> _answers = {};
  final _scrollController = ScrollController(); // 스크롤 컨트롤러

  // --- 개선 사항 3: 상수 분리 ---
  static const String _nextButtonText = "다음";
  static const String _completeButtonText = "완료";

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 컨트롤러 메모리 해제
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final String data = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> jsonResult = json.decode(data);
      final List<dynamic> questionData = jsonResult[widget.serviceName] ?? [];

      setState(() {
        _questions = questionData.map((item) => Question.fromJson(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "질문을 불러오는 데 실패했습니다.";
        _isLoading = false;
      });
    }
  }

  void _handleNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _scrollController.jumpTo(0); // 다음 질문 시 스크롤을 맨 위로
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            serviceName: widget.serviceName,
            categoryId: widget.categoryId,
            categoryLabel: widget.categoryLabel,
            formData: _answers,
          ),
        ),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text("재시도"),
            ),
          ],
        ),
      );
    }
    if (_questions.isEmpty) {
      return const Center(child: Text("표시할 질문이 없습니다."));
    }

    final currentQ = _questions[_currentIndex];
    final dynamic selected =
        _answers[currentQ.questionText] ?? (currentQ.isMultiple ? <String>[] : null);
    final bool isAnswered = (currentQ.isMultiple && (selected as List).isNotEmpty) ||
        (!currentQ.isMultiple && selected != null);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: _scrollController, // 스크롤 컨트롤러 연결
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentQ.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 옵션들
            ...currentQ.options.map((opt) {
              if (currentQ.isMultiple) {
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
                      _answers[currentQ.questionText] = selectedList;
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
                      _answers[currentQ.questionText] = val;
                    });
                  },
                );
              }
            }).toList(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: isAnswered ? _handleNext : null,
                child: Text(
                    _currentIndex < _questions.length - 1 ? _nextButtonText : _completeButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.serviceName} 견적 요청합니다.")),
      body: _buildBody(),
    );
  }
}
