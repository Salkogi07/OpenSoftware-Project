import 'package:flutter/material.dart';

class DailyRecord {
  final String day;
  final int solvedCount; // 학습 문제 수
  final int accuracy; // 정답률 (0~100)

  const DailyRecord({
    required this.day,
    required this.solvedCount,
    required this.accuracy,
  });
}

class WrongWordRank {
  final String word;
  final String topic;
  final String meaning;
  final int wrongCount;

  const WrongWordRank({
    required this.word,
    required this.topic,
    required this.meaning,
    required this.wrongCount,
  });
}

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // 'volume'(주간 학습량) 또는 'accuracy'(주간 정답률)
  String _chartMode = 'volume';

  final List<DailyRecord> _weeklyRecords = const [
    DailyRecord(day: '월', solvedCount: 5, accuracy: 80),
    DailyRecord(day: '화', solvedCount: 10, accuracy: 90),
    DailyRecord(day: '수', solvedCount: 5, accuracy: 60),
    DailyRecord(day: '목', solvedCount: 15, accuracy: 87),
    DailyRecord(day: '금', solvedCount: 10, accuracy: 100),
    DailyRecord(day: '토', solvedCount: 5, accuracy: 80),
    DailyRecord(day: '일', solvedCount: 10, accuracy: 90),
  ];

  final List<WrongWordRank> _topWrongWords = const [
    WrongWordRank(
      word: '심심한 사과',
      topic: '원래 알던 단어에서 뻗어 나온 말',
      meaning: '마음에서 우러나오는 깊은 사과',
      wrongCount: 4,
    ),
    WrongWordRank(
      word: '게슈탈트 붕괴',
      topic: '요즘 잘 안 쓰는 말',
      meaning: '글자나 모양이 갑자기 낯설어지는 현상',
      wrongCount: 3,
    ),
    WrongWordRank(
      word: '양해',
      topic: '공식적인 자리에서 쓰는 말',
      meaning: '사정을 헤아려 너그러이 받아들임',
      wrongCount: 2,
    ),
  ];

  int get _totalSolved =>
      _weeklyRecords.fold(0, (sum, item) => sum + item.solvedCount);

  int get _avgAccuracy {
    if (_weeklyRecords.isEmpty) return 0;
    final total = _weeklyRecords.fold(0, (sum, item) => sum + item.accuracy);
    return (total / _weeklyRecords.length).round();
  }

  @override
  Widget build(BuildContext context) {
    final maxVolume = _weeklyRecords
        .map((e) => e.solvedCount)
        .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('기록'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 요약 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    label: '이번 주 풀이',
                    value: '$_totalSolved문제',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.green.withValues(alpha: 0.25),
                  ),
                  _SummaryStat(
                    label: '평균 정답률',
                    value: '$_avgAccuracy%',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 그래프 전환 토글 (학습량 / 정답률)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '주간 학습 추이',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'volume', label: Text('학습량')),
                    ButtonSegment(value: 'accuracy', label: Text('정답률')),
                  ],
                  selected: {_chartMode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _chartMode = selection.first;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 초록 막대그래프 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SizedBox(
                height: 190,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _weeklyRecords.map((record) {
                    final isVolume = _chartMode == 'volume';
                    final ratio = isVolume
                        ? (maxVolume == 0 ? 0.0 : record.solvedCount / maxVolume)
                        : (record.accuracy / 100.0).clamp(0.0, 1.0);
                    final topLabel = isVolume
                        ? '${record.solvedCount}'
                        : '${record.accuracy}%';

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            topLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 20,
                            height: (125 * ratio).clamp(6.0, 125.0),
                            decoration: BoxDecoration(
                              color: isVolume
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            record.day,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 자주 틀리는 단어 TOP 3
            const Text(
              '자주 틀리는 단어 TOP 3',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...List.generate(_topWrongWords.length, (index) {
              final item = _topWrongWords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5E9),
                    foregroundColor: const Color(0xFF1B5E20),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    item.word,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        item.topic,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.meaning,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.wrongCount}회',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}