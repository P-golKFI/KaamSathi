import 'package:flutter/material.dart';
import '../data/rights_at_work_quiz_data.dart';

class QuizArgs {
  final String categoryTitle;
  final IconData categoryIcon;
  final List<QuizQuestion> questions;
  final String prefsKey;
  final String contentRoute;

  const QuizArgs({
    required this.categoryTitle,
    required this.categoryIcon,
    required this.questions,
    required this.prefsKey,
    required this.contentRoute,
  });
}
