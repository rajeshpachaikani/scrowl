import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/interest.dart';
import '../services/trivia_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class SubmitTriviaScreen extends StatefulWidget {
  const SubmitTriviaScreen({super.key});

  @override
  State<SubmitTriviaScreen> createState() => _SubmitTriviaScreenState();
}

class _SubmitTriviaScreenState extends State<SubmitTriviaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _sourceController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _submitTrivia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final triviaService = context.read<TriviaService>();
      await triviaService.submitTrivia(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        category: _selectedCategory!,
        source: _sourceController.text.trim().isNotEmpty
            ? _sourceController.text.trim()
            : null,
      );

      // Award points
      final authService = context.read<AuthService>();
      final userId = await authService.getCurrentUserId();
      if (userId != null) {
        final userService = context.read<UserService>();
        await userService.addRewardPoints(
          userId,
          AppConstants.pointsPerSubmit,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trivia submitted! You earned ${AppConstants.pointsPerSubmit} points',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Trivia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Your Knowledge',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Submit fact-checked trivia to earn ${AppConstants.pointsPerSubmit} reward points',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  hintText: 'Enter an interesting question',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.help_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  if (value.trim().length < 10) {
                    return 'Question is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Enter the answer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lightbulb_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }
                  if (value.trim().length < 5) {
                    return 'Answer is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: Interest.availableInterests.map((interest) {
                  return DropdownMenuItem(
                    value: interest.id,
                    child: Text(interest.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: 'Source (Optional)',
                  hintText: 'Enter the source of information',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTrivia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Trivia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
