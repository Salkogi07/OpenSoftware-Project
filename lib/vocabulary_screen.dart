import 'package:flutter/material.dart';

// 단어 데이터 모델
class VocabItem {
  final String id;
  final String word;
  final String meaning;
  final String example;
  int wrongCount;
  bool isStarred;
  bool isReviewed;

  VocabItem({
    required this.id,
    required this.word,
    required this.meaning,
    required this.example,
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
  // 임시 샘플 데이터 (추후 실제 퀴즈 오답 데이터와 연동)
  final List<VocabItem> _vocabList = [
    VocabItem(
      id: '1',
      word: 'ubiquitous',
      meaning: '어디에나 있는, 아주 흔한',
      example: 'Smartphones have become ubiquitous in modern society.',
      wrongCount: 3,
      isStarred: true,
      isReviewed: false,
    ),
    VocabItem(
      id: '2',
      word: 'ephemeral',
      meaning: '단명하는, 덧없는',
      example: 'Fame in the digital age is often ephemeral.',
      wrongCount: 2,
      isStarred: false,
      isReviewed: false,
    ),
    VocabItem(
      id: '3',
      word: 'pragmatic',
      meaning: '실용적인, 현실적인',
      example: 'We need a pragmatic approach to solve this issue.',
      wrongCount: 1,
      isStarred: false,
      isReviewed: true,
    ),
    VocabItem(
      id: '4',
      word: 'ambiguous',
      meaning: '모호한, 여러 가지로 해석될 수 있는',
      example: 'His reply to my question was somewhat ambiguous.',
      wrongCount: 2,
      isStarred: true,
      isReviewed: false,
    ),
  ];

  // 필터 상태 ('all', 'starred', 'unreviewed')
  String _selectedFilter = 'all';

  // 필터링된 목록 반환
  List<VocabItem> get _filteredList {
    if (_selectedFilter == 'starred') {
      return _vocabList.where((item) => item.isStarred).toList();
    } else if (_selectedFilter == 'unreviewed') {
      return _vocabList.where((item) => !item.isReviewed).toList();
    }
    return _vocabList;
  }

  // 다시 풀기 다이얼로그(간단 퀴즈 팝업)
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
                  const SizedBox(height: 12),
                  Text(
                    currentWord.word,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showMeaning) ...[
                    Text(
                      currentWord.meaning,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.indigo,
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
    final displayList = _filteredList;
    final reviewedCount = _vocabList.where((e) => e.isReviewed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('나만의 어휘장'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => _showRetryDialog(displayList),
            icon: const Icon(Icons.refresh),
            label: const Text('전체 다시 풀기'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 요약 및 필터 영역
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 ${_vocabList.length}개 중 $reviewedCount개 복습 완료',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('전체', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('⭐ 헷갈리는 단어', 'starred'),
                    const SizedBox(width: 8),
                    _buildFilterChip('미복습', 'unreviewed'),
                  ],
                ),
              ],
            ),
          ),

          // 단어 목록
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text('해당 조건의 단어가 없습니다.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1.5,
                        color: item.isReviewed ? Colors.grey[50] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // 1. 복습 여부 체크박스
                              Checkbox(
                                value: item.isReviewed,
                                onChanged: (val) {
                                  setState(() {
                                    item.isReviewed = val ?? false;
                                  });
                                },
                              ),

                              // 2. 단어 및 뜻 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item.word,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            decoration: item.isReviewed
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: item.isReviewed
                                                ? Colors.grey
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                      item.meaning,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: item.isReviewed
                                            ? Colors.grey
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3. 헷갈리는 단어 별표 버튼
                              IconButton(
                                tooltip: '헷갈리는 단어 표시',
                                icon: Icon(
                                  item.isStarred
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: item.isStarred
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.isStarred = !item.isStarred;
                                  });
                                },
                              ),

                              // 4. 개별 다시 풀기 버튼
                              OutlinedButton(
                                onPressed: () => _showRetryDialog([item]),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  minimumSize: const Size(0, 34),
                                ),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }
}