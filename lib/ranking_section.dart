part of 'frontend_screens.dart';

// 기록 탭 맨 아래 랭킹: 이번 주/전체 기간 × 맞힌 문제·경험치·출석일 기준
// 숫자는 DB 함수 leaderboard에서, 순위 계산은 learning_stats.dart의 rankEntries가 맡음

const _rankingGreen = Color(0xFF1B5E20);
const _rankingTint = Color(0xFFE8F8F0);
const _rankingShown = 10; // 상위 몇 명까지 보여 줄지 (내가 그 밖이면 내 줄을 따로 붙임)

class _RankingSection extends StatefulWidget {
  const _RankingSection({this.load});

  /// 테스트에서 DB 대신 넣는 불러오기 함수
  final Future<List<RankingEntry>> Function({required bool weekly})? load;

  @override
  State<_RankingSection> createState() => _RankingSectionState();
}

class _RankingSectionState extends State<_RankingSection> {
  bool weekly = true;
  RankingMetric metric = RankingMetric.correct;
  // 기간마다 한 번만 불러옴. 다시 시도하면 지우고 새로 불러옴
  final futures = <bool, Future<List<RankingEntry>>>{};

  Future<List<RankingEntry>> get _future => futures.putIfAbsent(
    weekly,
    () => (widget.load ?? learningRepository.fetchLeaderboard)(weekly: weekly),
  );

  @override
  Widget build(BuildContext context) {
    final loggedIn = widget.load != null || learningRepository.isLoggedIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '랭킹',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('이번 주')),
                ButtonSegment(value: false, label: Text('전체')),
              ],
              selected: {weekly},
              onSelectionChanged: (selection) =>
                  setState(() => weekly = selection.first),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final (value, label) in const [
              (RankingMetric.correct, '맞힌 문제'),
              (RankingMetric.xp, '경험치'),
              (RankingMetric.attendance, '출석일'),
            ])
              ChoiceChip(
                label: Text(label),
                selected: metric == value,
                showCheckmark: false,
                selectedColor: _rankingTint,
                labelStyle: TextStyle(
                  color: metric == value ? _rankingGreen : Colors.grey.shade700,
                  fontWeight: metric == value
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
                side: BorderSide(
                  color: metric == value
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
                ),
                onSelected: (_) => setState(() => metric = value),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (!loggedIn)
          const _RankingMessage('로그인하면 다른 학습자와 순위를 비교할 수 있어요.')
        else
          FutureBuilder<List<RankingEntry>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                      semanticsLabel: '랭킹 불러오는 중',
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return _RankingMessage(
                  '랭킹을 불러오지 못했어요. 인터넷 연결을 확인해 주세요.',
                  action: TextButton(
                    onPressed: () => setState(() {
                      futures.remove(weekly);
                    }),
                    child: const Text('다시 시도'),
                  ),
                );
              }
              return _rankingList(rankEntries(snapshot.data!, metric));
            },
          ),
      ],
    );
  }

  Widget _rankingList(List<(int, RankingEntry)> ranked) {
    // 점수 있는 사람이 아무도 없으면 (0점인 나만 남은 경우) 안내 문구
    if (ranked.every((row) => rankingScore(row.$2, metric) == 0)) {
      return _RankingMessage(
        weekly
            ? '이번 주에는 아직 순위가 없어요. 문제를 풀면 랭킹에 올라가요.'
            : '아직 순위가 없어요. 문제를 풀면 랭킹에 올라가요.',
      );
    }
    final top = ranked.take(_rankingShown).toList();
    final mine = ranked.skip(_rankingShown).where((row) => row.$2.isMe);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (rank, entry) in top) _RankingRow(rank, entry, metric),
          for (final (rank, entry) in mine) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            _RankingRow(rank, entry, metric),
          ],
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow(this.rank, this.entry, this.metric);

  final int rank;
  final RankingEntry entry;
  final RankingMetric metric;

  static const _tabular = [FontFeature.tabularFigures()];

  @override
  Widget build(BuildContext context) {
    final score = rankingScore(entry, metric);
    final scoreText = switch (metric) {
      RankingMetric.correct => '$score문제',
      RankingMetric.xp => 'Lv.${levelFor(score).level} · $score XP',
      RankingMetric.attendance => '$score일',
    };
    // 1~3위는 진한 초록 원, 나머지는 옅은 원
    final podium = rank <= 3 && score > 0;
    return Semantics(
      label: '$rank위, ${entry.nickname}${entry.isMe ? ' (나)' : ''}, $scoreText',
      excludeSemantics: true,
      child: ColoredBox(
        color: entry.isMe ? _rankingTint : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: podium ? const Color(0xFF2E7D32) : null,
                    ),
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: podium ? Colors.white : Colors.grey.shade700,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ProfileAvatar(avatar: entry.avatar, radius: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.nickname,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: entry.isMe
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: entry.isMe ? _rankingGreen : null,
                        ),
                      ),
                    ),
                    if (entry.isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '나',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                scoreText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _rankingGreen,
                  fontFeatures: _tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingMessage extends StatelessWidget {
  const _RankingMessage(this.message, {this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// 테스트용: DB 대신 [load]로 랭킹을 불러오는 랭킹 칸
@visibleForTesting
Widget rankingSectionForTest(
  Future<List<RankingEntry>> Function({required bool weekly}) load,
) => _RankingSection(load: load);
