import 'package:flutter/material.dart';

// 1. 단어 데이터를 안전하게 담아줄 설계도(클래스) 정의
class VocabularyItem {
  final String id;
  final String word;
  final String meaning;
  final String category;
  bool isSolved;

  VocabularyItem({
    required this.id,
    required this.word,
    required this.meaning,
    required this.category,
    required this.isSolved,
  });
}

class VocabularyBookScreen extends StatefulWidget {
  const VocabularyBookScreen({super.key});

  @override
  State<VocabularyBookScreen> createState() => _VocabularyBookScreenState();
}

class _VocabularyBookScreenState extends State<VocabularyBookScreen> {
  // 2. 위에서 만든 설계도 기반으로 리스트 생성
  final List<VocabularyItem> _wrongWords = [
    VocabularyItem(
      id: '1',
      word: '가심비',
      meaning: '가격 대비 심리적 만족도를 뜻하는 신조어',
      category: '세대 용어',
      isSolved: false,
    ),
    VocabularyItem(
      id: '2',
      word: '가스라이팅',
      meaning: '타인의 심리나 마주한 상황을 교묘하게 조작해 통제하는 행위',
      category: '공식 어휘',
      isSolved: false,
    ),
    VocabularyItem(
      id: '3',
      word: '스몰 쿠데타',
      meaning: '조직이나 단체에서 소규모로 일어나는 급격한 변화나 반란',
      category: '시사 상식',
      isSolved: true,
    ),
  ];

  String _selectedCategory = '전체';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 선택된 카테고리에 따라 리스트 필터링
    final filteredList = _selectedCategory == '전체'
        ? _wrongWords
        : _wrongWords.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('오답 어휘장'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 상단 요약 배너
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내가 틀린 단어 모음',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총 ${_wrongWords.where((e) => !e.isSolved).length}개 복습 필요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.bookmark_added_rounded, size: 36, color: Colors.blueAccent),
              ],
            ),
          ),

          // 2. 카테고리 필터 칩 
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['전체', '세대 용어', '공식 어휘', '시사 상식'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 3. 오답 단어 리스트
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('저장된 오답 단어가 없습니다! 🎉'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            children: [
                              Text(
                                item.word, // 👈 맵 키 방식 대신 점(.) 접근 방식으로 변경 완료
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(item.meaning),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              item.isSolved
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: item.isSolved ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                item.isSolved = !item.isSolved;
                              });
                            },
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