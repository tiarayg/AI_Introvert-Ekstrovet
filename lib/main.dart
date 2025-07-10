import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'questions.dart';

void main() {
  runApp(const PersonalityTestApp());
}

class PersonalityTestApp extends StatelessWidget {
  const PersonalityTestApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tes Kepribadian Mini',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const PersonalityTestPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PersonalityTestPage extends StatefulWidget {
  const PersonalityTestPage({super.key});
  @override
  State<PersonalityTestPage> createState() => _PersonalityTestPageState();
}

class _PersonalityTestPageState extends State<PersonalityTestPage> {
  bool started = false;
  int page = 0;
  Map<String, int> responses = {};
  Map<String, dynamic>? result;

  final featureKeys = featureQuestions.keys.toList();
  late final List<String> flatFeatures;
  late final List<String> questions;
  final int qPerPage = 2;

  @override
  void initState() {
    super.initState();
    questions = featureQuestions.values.expand((q) => q).toList();
    flatFeatures = featureQuestions.entries
        .expand((e) => List.filled(e.value.length, e.key))
        .toList();
  }

  void handleChange(int idx, String feat, int val) {
    setState(() {
      responses['q_${idx}_$feat'] = val;
    });
  }

  Future<void> handleSubmit() async {
    Map<String, List<int>> userInputs = {
      for (var feat in featureKeys) feat: [],
    };
    for (int i = 0; i < flatFeatures.length; i++) {
      String feat = flatFeatures[i];
      userInputs[feat]!.add(responses['q_${i}_$feat'] ?? 0);
    }
    List<double> finalInputs = featureKeys.map((feat) {
      var values = userInputs[feat]!;
      double avg = values.isEmpty
          ? 0
          : values.reduce((a, b) => a + b) / values.length;
      return avg;
    }).toList();

    try {
      var res = await http.post(
        Uri.parse(
          'http://10.138.194.71:5000/api/predict',
        ), // <-- Ganti ke IP backend kamu
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': finalInputs}),
      );
      if (res.statusCode == 200) {
        setState(() {
          result = jsonDecode(res.body);
        });
      } else {
        setState(() {
          result = {'label': 'Error', 'msg': 'Gagal memproses'};
        });
      }
    } catch (e) {
      setState(() {
        result = {'label': 'Error', 'msg': 'Terjadi error: $e'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int startQ = page * qPerPage;
    int endQ = (startQ + qPerPage).clamp(0, questions.length);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA7BFFF), Color(0xFFFBC2EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // supaya gradient terlihat
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.97),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.pink.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: !started
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🧠 Tes Kepribadian Mini',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Selamat datang di Tes Kepribadian Mini!\nKlik tombol di bawah ini untuk memulai tes dan ketahui apakah kamu Introvert atau Extrovert.',
                          style: TextStyle(
                            color: Color(0xFFb83280),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => setState(() => started = true),
                          child: const Text(
                            'Mulai Tes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Dibuat dengan ❤️ oleh Latifa Salsabila & Tiara Yoga Pratiwi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFb83280),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🧠 Tes Kepribadian Mini',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Jawab pertanyaan berikut untuk mengetahui apakah kamu Introvert atau Extrovert.',
                          style: TextStyle(
                            color: Color(0xFFb83280),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(endQ - startQ, (i) {
                          int idx = startQ + i;
                          String feat = flatFeatures[idx];
                          String q = questions[idx];
                          int max = q.contains('(0-24)') ? 24 : 10;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 28),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.pink.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFb83280),
                                    fontSize: 16,
                                  ),
                                ),
                                Slider(
                                  value: (responses['q_${idx}_$feat'] ?? 0)
                                      .toDouble(),
                                  min: 0,
                                  max: max.toDouble(),
                                  divisions: max,
                                  label: '${responses['q_${idx}_$feat'] ?? 0}',
                                  activeColor: const Color(0xFFb83280),
                                  onChanged: (val) =>
                                      handleChange(idx, feat, val.round()),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${responses['q_${idx}_$feat'] ?? 0}',
                                    style: const TextStyle(
                                      color: Color(0xFFb83280),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (page > 0)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade100,
                                  foregroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => setState(() => page--),
                                child: const Text('⬅ Kembali'),
                              ),
                            if (endQ < questions.length)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade100,
                                  foregroundColor: Colors.pink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => setState(() => page++),
                                child: const Text('Lanjut ➡'),
                              ),
                            if (endQ >= questions.length)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: handleSubmit,
                                child: const Text('🎯 Prediksi'),
                              ),
                          ],
                        ),
                        if (result != null)
                          Container(
                            margin: const EdgeInsets.only(top: 36),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Hasil Prediksi: ${result!['label']}',
                                  style: TextStyle(
                                    color: result!['label'] == 'Introvert'
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFFF59E42),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  result!['label'] == 'Introvert'
                                      ? Icons.self_improvement
                                      : Icons.emoji_emotions,
                                  color: result!['label'] == 'Introvert'
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFF59E42),
                                  size: 64,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  result!['label'] == 'Introvert'
                                      ? 'Introvert itu keren loh! Kamu nyaman dengan diri sendiri dan reflektif 🧘‍♀️'
                                      : 'Extrovert itu hebat! Kamu suka eksplorasi dan energi kamu nular ke orang lain 🌟',
                                  style: const TextStyle(
                                    color: Color(0xFFb83280),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 40),
                        const Text(
                          'Dibuat dengan ❤️ oleh Latifa Salsabila & Tiara Yoga Pratiwi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFb83280),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
