import 'package:flutter/material.dart';

// 기록 탭 화면 (디자인: DOBK23 시안). 데이터는 밖에서 받아서 그리기만 합니다.
// 실제 데이터는 frontend_screens.dart의 기록 탭이 learning_stats.dart의 주간 통계로 채워 줍니다.

class DailyRecord {
  final String day;
  final int solvedCount; // 학습 문제 수
  final int? accuracy; // 정답률 (0~100). 푼 문제가 없는 날은 null

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
  const RecordScreen({
    super.key,
    required this.weeklyRecords,
    required this.topWrongWords,
    required this.accuracyPercent,
    this.status,
    this.appBar,
    this.loading = false,
    this.ranking,
  });

  /// 최근 7일 기록 (오래된 날 → 오늘 순서)
  final List<DailyRecord> weeklyRecords;

  /// 최근 7일 자주 틀린 단어 (최대 3개)
  final List<WrongWordRank> topWrongWords;

  /// 이번 주 정답률(0~100). 푼 문제가 없으면 null
  final int? accuracyPercent;

  /// 불러오는 중·실패·로그인 안 함 안내 (없으면 표시 안 함)
  final String? status;

  /// 다른 탭과 같은 상단바를 쓰려고 밖에서 받음 (없으면 기본 상단바)
  final PreferredSizeWidget? appBar;

  /// 기록을 불러오는 중이면 상단에 얇은 진행 막대를 겹쳐 보여 줌 (내용을 밀지 않음)
  final bool loading;

  /// 상단 '랭킹' 전환으로 보여 줄 랭킹 칸 (없으면 전환 버튼도 표시 안 함)
  final Widget? ranking;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // 'volume'(주간 학습량) 또는 'accuracy'(주간 정답률)
  String _chartMode = 'volume';

  // 첫 화면은 막대 높이 0으로 그리고, 다음 프레임에 실제 높이로 바꿔 차오르게 함
  bool _revealed = false;

  // 위쪽 전환: false면 내 기록, true면 랭킹
  bool _showRanking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _revealed = true);
    });
  }

  static const _tabular = [FontFeature.tabularFigures()];

  int get _totalSolved =>
      widget.weeklyRecords.fold(0, (sum, item) => sum + item.solvedCount);

  @override
  Widget build(BuildContext context) {
    final records = widget.weeklyRecords;
    final maxVolume = records.fold(
      1,
      (m, e) => e.solvedCount > m ? e.solvedCount : m,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          widget.appBar ??
          AppBar(
            title: const Text('기록'),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
      body: Column(
        children: [
          if (widget.ranking != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('내 기록')),
                    ButtonSegment(value: true, label: Text('랭킹')),
                  ],
                  selected: {_showRanking},
                  onSelectionChanged: (selection) =>
                      setState(() => _showRanking = selection.first),
                ),
              ),
            ),
          Expanded(child: _body(records, maxVolume)),
        ],
      ),
    );
  }

  Widget _body(List<DailyRecord> records, int maxVolume) {
    final ranking = widget.ranking;
    return Stack(
      children: [
        // 랭킹은 숨겨져 있어도 살려 둬서, 전환할 때마다 다시 불러오지 않음
        if (ranking == null)
          _content(records, maxVolume)
        else
          IndexedStack(
            index: _showRanking ? 1 : 0,
            children: [
              _content(records, maxVolume),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ranking,
              ),
            ],
          ),
        // 불러오는 중 표시는 내용 위에 겹쳐서: 나타나고 사라져도 아래 내용이 움직이지 않음
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          // 불러오는 동안에만 만들어서, 끝나면 움직이는 막대가 남지 않게
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.loading
                ? const LinearProgressIndicator(
                    minHeight: 3,
                    color: Color(0xFF2E7D32),
                    backgroundColor: Color(0xFFDDEFE3),
                    semanticsLabel: '기록 불러오는 중',
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _content(List<DailyRecord> records, int maxVolume) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.status case final status?) ...[
            Text(
              status,
              style: const TextStyle(fontSize: 13, color: Color(0xFF516477)),
            ),
            const SizedBox(height: 12),
          ],

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
                _SummaryStat(label: '이번 주 풀이', value: '$_totalSolved문제'),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.green.withValues(alpha: 0.25),
                ),
                _SummaryStat(
                  label: '이번 주 정답률',
                  value: widget.accuracyPercent == null
                      ? '-'
                      : '${widget.accuracyPercent}%',
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
                children: records.indexed.map((entry) {
                  final (index, record) = entry;
                  final isVolume = _chartMode == 'volume';
                  final accuracy = record.accuracy;
                  final ratio = isVolume
                      ? record.solvedCount / maxVolume
                      : ((accuracy ?? 0) / 100.0).clamp(0.0, 1.0);
                  final topLabel = isVolume
                      ? '${record.solvedCount}'
                      : (accuracy == null ? '-' : '$accuracy%');
                  // 푼 문제가 없는 날은 막대를 흐리게
                  final empty = record.solvedCount == 0;

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
                            fontFeatures: _tabular,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 탭에 들어오면 0에서 차오름. 오른쪽 막대일수록 조금 늦게 끝나 차례로 차오르는 느낌
                        AnimatedContainer(
                          duration:
                              _revealed &&
                                  !MediaQuery.disableAnimationsOf(context)
                              ? Duration(milliseconds: 500 + index * 70)
                              : Duration.zero,
                          curve: Curves.easeOutCubic,
                          width: 20,
                          height: _revealed
                              ? (125 * ratio).clamp(6.0, 125.0)
                              : 0,
                          decoration: BoxDecoration(
                            color: empty
                                ? const Color(0xFFDDEFE3)
                                : isVolume
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

          if (widget.topWrongWords.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _totalSolved == 0
                    ? '이번 주에 푼 문제가 없어요. 학습 탭에서 5문제를 풀어 보세요.'
                    : '이번 주에 틀린 단어가 없어요.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),

          ...List.generate(widget.topWrongWords.length, (index) {
            final item = widget.topWrongWords[index];
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
                    Text(item.meaning, style: const TextStyle(fontSize: 13)),
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
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          // 민트 배경 위라 회색 대신 초록 계열로 (대비 확보)
          style: const TextStyle(fontSize: 12, color: Color(0xFF3B6B50)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
