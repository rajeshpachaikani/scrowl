class TriviaCard {
  final String id;
  final String question;
  final String answer;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final bool isSponsored;
  final String? sponsorName;
  final DateTime createdAt;
  final int likes;
  final String? source;
  
  TriviaCard({
    required this.id,
    required this.question,
    required this.answer,
    this.imageUrl,
    required this.category,
    required this.tags,
    this.isSponsored = false,
    this.sponsorName,
    required this.createdAt,
    this.likes = 0,
    this.source,
  });

  factory TriviaCard.fromJson(Map<String, dynamic> json) {
    return TriviaCard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      isSponsored: json['isSponsored'] as bool? ?? false,
      sponsorName: json['sponsorName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
      'isSponsored': isSponsored,
      'sponsorName': sponsorName,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'source': source,
    };
  }
}
