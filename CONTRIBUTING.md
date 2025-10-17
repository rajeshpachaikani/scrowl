# Contributing to Scrowl

Thank you for your interest in contributing to Scrowl! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0+
- Git
- Firebase account (for backend features)
- Basic knowledge of Dart/Flutter

### Setup Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/scrowl.git
   cd scrowl
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/rajeshpachaikani/scrowl.git
   ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Set up Firebase (see SETUP.md)

## Development Workflow

### Creating a Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### Making Changes

1. **Keep changes focused**: One feature or fix per PR
2. **Write clean code**: Follow the style guide below
3. **Add tests**: Include unit/widget tests for new features
4. **Update documentation**: Keep README and docs current
5. **Test thoroughly**: Ensure all tests pass

### Committing Changes

Use clear, descriptive commit messages:

```bash
# Good commit messages
git commit -m "Add trivia sorting by popularity"
git commit -m "Fix like button state update issue"
git commit -m "Update README with deployment instructions"

# Bad commit messages
git commit -m "Fix bug"
git commit -m "Update"
git commit -m "Changes"
```

### Pushing Changes

```bash
# Push to your fork
git push origin feature/your-feature-name
```

### Creating a Pull Request

1. Go to the original repository on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template:
   - Clear title
   - Description of changes
   - Related issues
   - Screenshots (for UI changes)
   - Testing steps

## Code Style Guide

### Dart/Flutter Style

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// Good
class TriviaCard {
  final String question;
  final String answer;
  
  const TriviaCard({
    required this.question,
    required this.answer,
  });
}

// Use trailing commas for formatting
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Text('Hello'),
  );
}

// Prefer const constructors
const SizedBox(height: 16);

// Use meaningful names
final userRewardPoints = user.rewardPoints;
// Not: final pts = user.rewardPoints;
```

### File Organization

```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trivia_card.dart';
import '../services/trivia_service.dart';

// 2. Class definition
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  
  @override
  State<MyScreen> createState() => _MyScreenState();
}

// 3. Private state class
class _MyScreenState extends State<MyScreen> {
  // Fields
  bool _isLoading = false;
  
  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Private methods
  Future<void> _loadData() async {
    // Implementation
  }
  
  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
```

### Naming Conventions

- **Classes**: `PascalCase` - `TriviaCard`, `UserProfile`
- **Files**: `snake_case` - `trivia_card.dart`, `user_profile.dart`
- **Variables**: `camelCase` - `rewardPoints`, `isLoading`
- **Private**: `_underscore` - `_loadData`, `_isLoading`
- **Constants**: `camelCase` for non-compile-time constants

### Widget Structure

```dart
// Prefer composition over nesting
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
  );
}

Widget _buildAppBar() {
  return AppBar(
    title: const Text('Scrowl'),
  );
}

Widget _buildBody() {
  return ListView(
    children: [
      _buildHeader(),
      _buildContent(),
    ],
  );
}
```

## Testing Guidelines

### Unit Tests

Test models and business logic:

```dart
test('TriviaCard should serialize correctly', () {
  final trivia = TriviaCard(
    id: 'test',
    question: 'Test?',
    answer: 'Answer',
    category: 'science',
    tags: [],
    createdAt: DateTime.now(),
  );
  
  final json = trivia.toJson();
  final recreated = TriviaCard.fromJson(json);
  
  expect(recreated.id, trivia.id);
  expect(recreated.question, trivia.question);
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('TriviaCard displays question', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TriviaCardWidget(
        trivia: testTrivia,
        isLiked: false,
        isSaved: false,
        onLike: () {},
        onSave: () {},
      ),
    ),
  );
  
  expect(find.text('Test question?'), findsOneWidget);
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Documentation

### Code Comments

```dart
/// Generates trivia content using Gemini AI.
///
/// Parameters:
/// - [category]: The trivia category
/// - [count]: Number of items to generate
///
/// Returns a list of generated [TriviaCard] objects.
Future<List<TriviaCard>> generateTrivia({
  required String category,
  int count = 5,
}) async {
  // Implementation
}
```

### README Updates

Update README.md when:
- Adding new features
- Changing setup process
- Updating dependencies
- Modifying architecture

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass locally
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] No console warnings or errors
- [ ] Tested on multiple devices/emulators

### PR Checklist

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed
- [ ] Tested on Android
- [ ] Tested on iOS

## Screenshots (if UI changes)
[Add screenshots here]

## Related Issues
Closes #123
```

### Review Process

1. **Automated checks**: CI/CD runs tests
2. **Code review**: Maintainer reviews code
3. **Feedback**: Address review comments
4. **Approval**: PR approved by maintainer
5. **Merge**: PR merged to main branch

## Feature Requests

### Proposing New Features

1. Check existing issues/discussions
2. Open a new issue with:
   - Clear description
   - Use case
   - Proposed implementation
   - Mockups (for UI features)

### Feature Development

1. Discuss feature in issue first
2. Get maintainer approval
3. Create implementation plan
4. Submit PR with feature

## Bug Reports

### Reporting Bugs

Create an issue with:

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Device: [e.g. Pixel 5]
- OS: [e.g. Android 12]
- App Version: [e.g. 1.0.0]

## Screenshots
[If applicable]

## Additional Context
Any other relevant information
```

## Firebase Functions

### Contributing to Functions

```javascript
// Add JSDoc comments
/**
 * Generates trivia content using Gemini AI
 * @param {Object} data - Function parameters
 * @param {string} data.category - Trivia category
 * @param {number} data.count - Number of items
 * @returns {Promise<Object>} Generation result
 */
exports.generateTrivia = functions.https.onCall(async (data, context) => {
  // Implementation
});
```

### Testing Functions

```bash
# Local testing
firebase emulators:start

# Deploy to test project
firebase use test-project
firebase deploy --only functions
```

## Commit Message Convention

Use conventional commits:

```
feat: add dark mode support
fix: resolve trivia card display issue
docs: update setup instructions
style: format code with prettier
refactor: simplify user service logic
test: add unit tests for trivia model
chore: update dependencies
```

## Getting Help

- **Documentation**: Check README.md and SETUP.md
- **Issues**: Search existing issues
- **Discussions**: Start a discussion for questions
- **Discord**: [If you have a community channel]

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in app about section

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Thank You!

Your contributions make Scrowl better for everyone. We appreciate your time and effort!

---

## Quick Links

- [Setup Guide](SETUP.md)
- [Architecture](ARCHITECTURE.md)
- [Issue Tracker](https://github.com/rajeshpachaikani/scrowl/issues)
- [Pull Requests](https://github.com/rajeshpachaikani/scrowl/pulls)
