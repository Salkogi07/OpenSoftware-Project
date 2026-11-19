import 'package:flutter/material.dart';

class VocabItem {
  final String id;
  final String word;
  final String meaning;
  final String example;
  final String topic;
  int wrongCount;
  bool isStarred;
  bool isReviewed;

  VocabItem({
    required this.id,
    required this.word,
    required this.meaning,
    required this.example,
    required this.topic,
    this.wrongCount = 1,
    this.isStarred = false,
    this.isReviewed = false,
  });
}

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final List<VocabItem> _vocabList = [
    VocabItem(
      id: '1',
      word: '심심한 사과',
      meaning: '마음에서 우러나오는 깊은 사과 (지루하다는 뜻이 아님)',
      example: '이번 일로 불편을 드린 점 심심한 사과의 말씀을 전합니다.',
      topic: '원래 알던 단어에서 뻗어 나온 말',
      wrongCount: 3,
      isStarred: true,
      isReviewed: false,
    ),
    VocabItem(
      id: '2',
      word: '게슈탈트 붕괴',
      meaning: '어떤 말이나 글자를 오래 보아 갑자기 낯설고 이상해지는 현상',
      example: '같은 단어를 계속 적다 보니 게슈탈트 붕괴가 왔다.',
      topic: '요즘 잘 안 쓰는 말',
      wrongCount: 2,
      isStarred: false,
      isReviewed: false,
    ),
    VocabItem(
      id: '3',
      word: '양해',
      meaning: '사정을 헤아려 너그러이 받아들임',
      example: '일정 변경에 대해 미리 양해를 구했습니다.',
      topic: '공식적인 자리에서 쓰는 말',
      wrongCount: 1,
      isStarred: false,
      isReviewed: true,
    ),
    VocabItem(
      id: '4',
      word: '가심비',
      meaning: '가격 대비 심리적 만족도를 뜻하는 말',
      example: '조금 비싸도 기분이 좋아지는 가심비 소비를 했다.',
      topic: '원래 알던 단어에서 뻗어 나온 말',
      wrongCount: 2,
      isStarred: true,
      isReviewed: false,
    ),
  ];

  String _selectedTopic = '전체';
  bool _onlyStarred = false;
  bool _onlyUnreviewed = false;

  List<VocabItem> get _filteredList {
    return _vocabList.where((item) {
      final matchTopic = _selectedTopic == '전체' || item.topic == _selectedTopic;
      final matchStar = !_onlyStarred || item.isStarred;
      final matchUnreviewed = !_onlyUnreviewed || !item.isReviewed;
      return matchTopic && matchStar && matchUnreviewed;
    }).toList();
  }

  void _showRetryDialog(List<VocabItem> targets) {
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다시 풀 단어가 없습니다.')),
      );
      return;
    }

    int currentIndex = 0;
    bool showMeaning = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentWord = targets[currentIndex];
            return AlertDialog(
              title: Text('오답 다시 풀기 (${currentIndex + 1}/${targets.length})'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    currentWord.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (showMeaning) ...[
                    Text(
                      currentWord.meaning,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentWord.example,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ] else
                    OutlinedButton(
                      onPressed: () {
                        setDialogState(() {
                          showMeaning = true;
                        });
                      },
                      child: const Text('뜻 확인하기'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentWord.isReviewed = true;
                    });
                    if (currentIndex < targets.length - 1) {
                      setDialogState(() {
                        currentIndex++;
                        showMeaning = false;
                      });
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('복습을 완료했습니다!')),
                      );
                    }
                  },
                  child: Text(
                    currentIndex < targets.length - 1 ? '외웠어요 (다음)' : '완료',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayList = _filteredList;
    final reviewedCount = _vocabList.where((e) => e.isReviewed).length;
    final topics = [
      '전체',
      '공식적인 자리에서 쓰는 말',
      '원래 알던 단어에서 뻗어 나온 말',
      '요즘 잘 안 쓰는 말',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('어휘장'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => _showRetryDialog(displayList),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 풀기'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '틀린 단어 복습 현황',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총 ${_vocabList.length}개 중 $reviewedCount개 복습 완료',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.menu_book_rounded, size: 32),
              ],
            ),
          ),

          // 주제 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: topics.map((topic) {
                final selected = _selectedTopic == topic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(topic),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedTopic = topic;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 상태 필터(별표 / 미복습)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('⭐ 헷갈리는 단어'),
                  selected: _onlyStarred,
                  onSelected: (val) {
                    setState(() {
                      _onlyStarred = val;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('미복습만'),
                  selected: _onlyUnreviewed,
                  onSelected: (val) {
                    setState(() {
                      _onlyUnreviewed = val;
                    });
                  },
                ),
              ],
            ),
          ),

          // 단어 목록
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text('조건에 맞는 단어가 없습니다.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.isReviewed,
                                onChanged: (val) {
                                  setState(() {
                                    item.isReviewed = val ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          item.word,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            decoration: item.isReviewed
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${item.wrongCount}회 오답',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.topic,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.meaning,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  item.isStarred ? Icons.star : Icons.star_border,
                                  color: item.isStarred ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.isStarred = !item.isStarred;
                                  });
                                },
                              ),
                              OutlinedButton(
                                onPressed: () => _showRetryDialog([item]),
                                child: const Text(
                                  '다시 풀기',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
