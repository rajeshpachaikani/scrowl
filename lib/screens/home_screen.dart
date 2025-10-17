import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trivia_card.dart';
import '../services/auth_service.dart';
import '../services/trivia_service.dart';
import '../services/user_service.dart';
import '../widgets/trivia_card_widget.dart';
import '../utils/constants.dart';
import 'profile_screen.dart';
import 'submit_trivia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authService = context.read<AuthService>();
    final userId = await authService.getCurrentUserId();
    
    if (userId != null) {
      final userService = context.read<UserService>();
      await userService.fetchUser(userId);
      
      if (userService.currentUser != null) {
        final triviaService = context.read<TriviaService>();
        await triviaService.fetchTriviaByInterests(
          userService.currentUser!.interests,
          refresh: true,
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final triviaService = context.read<TriviaService>();
      final userService = context.read<UserService>();
      
      if (!triviaService.isLoading && 
          triviaService.hasMore &&
          userService.currentUser != null) {
        triviaService.fetchTriviaByInterests(
          userService.currentUser!.interests,
        );
      }
    }
  }

  Future<void> _refreshTrivia() async {
    final userService = context.read<UserService>();
    if (userService.currentUser != null) {
      final triviaService = context.read<TriviaService>();
      await triviaService.fetchTriviaByInterests(
        userService.currentUser!.interests,
        refresh: true,
      );
    }
  }

  Widget _buildHomeFeed() {
    return Consumer2<TriviaService, UserService>(
      builder: (context, triviaService, userService, child) {
        if (triviaService.triviaCards.isEmpty && !triviaService.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No trivia available',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new content',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshTrivia,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: triviaService.triviaCards.length + 
                       (triviaService.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == triviaService.triviaCards.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final trivia = triviaService.triviaCards[index];
              final isLiked = userService.currentUser?.likedTriviaIds
                  .contains(trivia.id) ?? false;
              final isSaved = userService.currentUser?.savedTriviaIds
                  .contains(trivia.id) ?? false;

              return TriviaCardWidget(
                trivia: trivia,
                isLiked: isLiked,
                isSaved: isSaved,
                onLike: () => _handleLike(trivia.id),
                onSave: () => _handleSave(trivia.id),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleLike(String triviaId) async {
    final authService = context.read<AuthService>();
    final userId = await authService.getCurrentUserId();
    
    if (userId != null) {
      final userService = context.read<UserService>();
      final triviaService = context.read<TriviaService>();
      
      await Future.wait([
        userService.likeTrivia(userId, triviaId),
        triviaService.likeTrivia(triviaId),
        userService.addRewardPoints(userId, AppConstants.pointsPerLike),
      ]);
    }
  }

  Future<void> _handleSave(String triviaId) async {
    final authService = context.read<AuthService>();
    final userId = await authService.getCurrentUserId();
    
    if (userId != null) {
      final userService = context.read<UserService>();
      await Future.wait([
        userService.saveTrivia(userId, triviaId),
        userService.addRewardPoints(userId, AppConstants.pointsPerSave),
      ]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trivia saved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrowl'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubmitTriviaScreen(),
                ),
              );
            },
            tooltip: 'Submit Trivia',
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildHomeFeed() : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
