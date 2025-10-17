import 'package:flutter/material.dart';

class Interest {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Interest({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<Interest> availableInterests = [
    Interest(
      id: 'science',
      name: 'Science',
      icon: Icons.science,
      color: const Color(0xFF4CAF50),
    ),
    Interest(
      id: 'technology',
      name: 'Technology',
      icon: Icons.computer,
      color: const Color(0xFF2196F3),
    ),
    Interest(
      id: 'history',
      name: 'History',
      icon: Icons.history_edu,
      color: const Color(0xFF9C27B0),
    ),
    Interest(
      id: 'geography',
      name: 'Geography',
      icon: Icons.public,
      color: const Color(0xFF00BCD4),
    ),
    Interest(
      id: 'arts',
      name: 'Arts',
      icon: Icons.palette,
      color: const Color(0xFFFF9800),
    ),
    Interest(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_soccer,
      color: const Color(0xFFF44336),
    ),
    Interest(
      id: 'music',
      name: 'Music',
      icon: Icons.music_note,
      color: const Color(0xFF673AB7),
    ),
    Interest(
      id: 'nature',
      name: 'Nature',
      icon: Icons.nature,
      color: const Color(0xFF8BC34A),
    ),
    Interest(
      id: 'space',
      name: 'Space',
      icon: Icons.rocket_launch,
      color: const Color(0xFF3F51B5),
    ),
    Interest(
      id: 'literature',
      name: 'Literature',
      icon: Icons.book,
      color: const Color(0xFF795548),
    ),
    Interest(
      id: 'food',
      name: 'Food',
      icon: Icons.restaurant,
      color: const Color(0xFFE91E63),
    ),
    Interest(
      id: 'movies',
      name: 'Movies',
      icon: Icons.movie,
      color: const Color(0xFF607D8B),
    ),
  ];

  static Color getCategoryColor(String category) {
    final interest = availableInterests.firstWhere(
      (i) => i.id.toLowerCase() == category.toLowerCase(),
      orElse: () => availableInterests[0],
    );
    return interest.color;
  }
}
