import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_args.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class SelfHelpQuizScreen extends StatefulWidget {
  const SelfHelpQuizScreen({super.key});

  @override
  State<SelfHelpQuizScreen> createState() => _SelfHelpQuizScreenState();
}

class _SelfHelpQuizScreenState extends State<SelfHelpQuizScreen> {
  int _currentIndex = 0;
  int? _selectedChoice;
  int _score = 0;
  bool _showResult = false;

  void _selectChoice(int index) {
    if (_selectedChoice != null) return;
    setState(() => _selectedChoice = index);
  }

  void _next(QuizArgs args) {
    final q = args.questions[_currentIndex];
    if (_selectedChoice == q.correctIndex) _score++;

    if (_currentIndex < args.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedChoice = null;
      });
    } else {
      _saveCompletion(args);
      setState(() => _showResult = true);
    }
  }

  Future<void> _saveCompletion(QuizArgs args) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(args.prefsKey, true);
  }

  Future<void> _goToContent(QuizArgs args) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(args.prefsKey, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, args.contentRoute);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as QuizArgs;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: _showResult ? _buildResult(args) : _buildQuestion(args),
    );
  }

  Widget _buildQuestion(QuizArgs args) {
    final q = args.questions[_currentIndex];
    final total = args.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDark, AppColors.navyBlue],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(args.categoryIcon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          args.categoryTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${_currentIndex + 1} / $total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.teal),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(q.choices.length, (i) {
                  return _ChoiceTile(
                    label: q.choices[i],
                    state: _choiceState(i, q.correctIndex),
                    onTap: () => _selectChoice(i),
                  );
                }),
                const SizedBox(height: 24),
                if (_selectedChoice != null)
                  SizedBox(
                    width: double.infinity,
                    child: _GradientButton(
                      label:
                          _currentIndex < total - 1
                      ? AppLocalizations.of(context)!.quizNext
                      : AppLocalizations.of(context)!.quizSeeResult,
                      onTap: () => _next(args),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _ChoiceState _choiceState(int choiceIndex, int correctIndex) {
    if (_selectedChoice == null) return _ChoiceState.idle;
    if (choiceIndex == correctIndex) return _ChoiceState.correct;
    if (choiceIndex == _selectedChoice) return _ChoiceState.wrong;
    return _ChoiceState.idle;
  }

  Widget _buildResult(QuizArgs args) {
    final total = args.questions.length;
    final passed = _score > total / 2;

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDark, AppColors.navyBlue],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child:
                          const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed
                          ? Icons.emoji_events_rounded
                          : Icons.menu_book_rounded,
                      size: 44,
                      color: passed ? AppColors.orange : AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed
                        ? AppLocalizations.of(context)!.quizGreatJob
                        : AppLocalizations.of(context)!.quizGoodEffort,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.quizScore(_score, total),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    passed
                        ? AppLocalizations.of(context)!.quizPassMessage
                        : AppLocalizations.of(context)!.quizFailMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: _GradientButton(
                    label: AppLocalizations.of(context)!.quizContinueLearn,
                    onTap: () => _goToContent(args),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _ChoiceState { idle, correct, wrong }

class _ChoiceTile extends StatelessWidget {
  final String label;
  final _ChoiceState state;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;
    Widget? trailingIcon;

    switch (state) {
      case _ChoiceState.correct:
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        trailingIcon =
            const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case _ChoiceState.wrong:
        borderColor = Colors.redAccent;
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        trailingIcon =
            const Icon(Icons.cancel, color: Colors.redAccent, size: 20);
      case _ChoiceState.idle:
        borderColor = Colors.grey.shade200;
        bgColor = Colors.white;
        textColor = AppColors.navyBlue;
        trailingIcon = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.teal, Color(0xFF26C6DA)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
